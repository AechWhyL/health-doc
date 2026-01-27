import { Binding, promptAction, SymbolGlyphModifier, UIUtils } from '@kit.ArkUI';
import { InterventionService } from '../../../common/api/InterventionService';
import dayjs from 'dayjs';
import {
  InterventionPlanResponse,
  InterventionPlanStatus,
  PlanItemResponse,
  PlanTaskInstanceResponse,
  QueryInterventionPlanRequest,
} from '../../../models/DTO/intervention';
import { PlanFormRouteParams } from './InterventionPlanForm'
import { PlanItemFormRouteParams } from './PlanItemFormPage'
import { PlanItemDetailRouteParams } from './PlanItemDetailPage'
import { CardContainer } from '../../../components/common/CardContainer'
import { MedicalHealthDataParams } from '../data/MedicalHealthDataPage';
import { IUser } from '../../../models/DTO/UserModels';
import { JSON } from '@kit.ArkTS';

interface PlanViewModel extends InterventionPlanResponse {
  isExpanded: boolean;
  isLoadingItems: boolean;
  items: PlanItemResponse[];
  todayTasks: PlanTaskInstanceResponse[];
  completedTaskCount: number;
  totalTaskCount: number;
  editable:boolean;
}

@Component
export struct InterventionPlanListComp {
  @Prop elderUserId: number
  @Prop showTabs: boolean = false
  @Prop @Watch('onRefreshChanged') refreshId: number = 0

  @State plans: PlanViewModel[] = []
  @State private isLoading: boolean = false
  @State private errorMsg: string = ''
  @State @Watch('onRefreshChanged') private currentTabIndex: number = 0
  @State private currentUser: IUser | null = null

  @Consume('navPathStack') navPathStack: NavPathStack;

  aboutToAppear() {
    this.currentUser = AppStorage.get<IUser>('currentUser') || null;
    this.loadPlans();
  }

  onRefreshChanged() {
    this.loadPlans();
  }

  private formatDate(dateStr: string | null | undefined): string {
    if (!dateStr) {
      return '--'
    }
    return dayjs(dateStr).format('YYYY年M月D日')
  }

  private openItemForm(planId: number) {
    const params: PlanItemFormRouteParams = { planId }
    this.navPathStack.pushPathByName('Medical_Intervention_PlanItemForm', params)
  }

  private openItemDetail(item: PlanItemResponse) {
    const params: PlanItemDetailRouteParams = { item }
    this.navPathStack.pushPathByName('Medical_Intervention_PlanItemDetail', params)
  }

  private async loadPlans() {
    if (!this.elderUserId) {
      return;
    }
    this.isLoading = true;
    try {
      const query: QueryInterventionPlanRequest = {
        page: 1, 
        pageSize: 100, 
        orderBy: 'created_at desc'
      };
      
      if (this.currentTabIndex === 1 && this.currentUser) {
        query.createdByUserId = this.currentUser.id;
      }

      const response = await InterventionService.getPlansByElderUserId(this.elderUserId, query);
      if (response.code === 200 && response.data) {
        this.plans = response.data.records.map(plan => {
          let vm: PlanViewModel = {
            id: plan.id,
            elder_user_id: plan.elder_user_id,
            title: plan.title,
            description: plan.description,
            status: plan.status,
            start_date: plan.start_date,
            end_date: plan.end_date,
            created_by_user_id: plan.created_by_user_id,
            created_at: plan.created_at,
            updated_at: plan.updated_at,
            isExpanded: false,
            isLoadingItems: false,
            items: [],
            todayTasks: [],
            completedTaskCount: 0,
            totalTaskCount: 0,
            editable: plan.created_by_user_id === this.currentUser?.id
          };
          return vm;
        });
        this.loadActivePlansDetails();
      } else {
        this.errorMsg = response.message || '获取计划列表失败';
      }
    } catch (err) {
      this.errorMsg = '网络异常';
    } finally {
      this.isLoading = false;
    }
  }

  private async loadActivePlansDetails() {
    for (let i = 0; i < this.plans.length; i++) {
      if (this.plans[i].status === 'ACTIVE') {
        await this.loadPlanItemsAndTasks(i);
      }
    }
  }

  private async loadPlanItemsAndTasks(index: number) {
    const plan = this.plans[index];
    try {
      const itemsResp = await InterventionService.getPlanItemsByPlanId(plan.id);
      if (itemsResp.code === 200 && itemsResp.data) {
        const today = new Date().toISOString().split('T')[0];
        let totalTasks: PlanTaskInstanceResponse[] = [];
        for (const item of itemsResp.data) {
          const tasksResp =
            await InterventionService.getTaskInstancesByItemId(item.id, { startDate: today, endDate: today });
          if (tasksResp.code === 200 && tasksResp.data) {
            totalTasks = totalTasks.concat(tasksResp.data);
          }
        }

        const updated: PlanViewModel = {
          id: plan.id,
          elder_user_id: plan.elder_user_id,
          title: plan.title,
          description: plan.description,
          status: plan.status,
          start_date: plan.start_date,
          end_date: plan.end_date,
          created_by_user_id: plan.created_by_user_id,
          created_at: plan.created_at,
          updated_at: plan.updated_at,
          isExpanded: plan.isExpanded,
          editable:plan.editable,
          isLoadingItems: false,
          items: itemsResp.data,
          todayTasks: totalTasks,
          completedTaskCount: totalTasks.filter(t => t.status === 'COMPLETED').length,
          totalTaskCount: totalTasks.length
        };
        const newPlans = this.plans.slice();
        newPlans[index] = updated;
        this.plans = newPlans;
      }
    } catch (e) {
      console.error('Failed to load plan items');
    }
  }

  private toggleExpand(planId: number) {
    const index = this.plans.findIndex(p => p.id === planId);
    console.log("[InterventionPlanListComp] "+ `toggleExpand ${index}`)
    if (index === -1) return;
    
    const plan = this.plans[index];
    const updated: PlanViewModel = {
      id: plan.id,
      elder_user_id: plan.elder_user_id,
      title: plan.title,
      description: plan.description,
      status: plan.status,
      start_date: plan.start_date,
      end_date: plan.end_date,
      created_by_user_id: plan.created_by_user_id,
      created_at: plan.created_at,
      updated_at: plan.updated_at,
      isExpanded: !plan.isExpanded,
      isLoadingItems: plan.isLoadingItems,
      items: plan.items,
      todayTasks: plan.todayTasks,
      completedTaskCount: plan.completedTaskCount,
      totalTaskCount: plan.totalTaskCount,
      editable: plan.editable
    };

    const copy = this.plans.slice();
    copy[index] = updated
    this.plans = copy
    console.log("[InterventionPlanListComp] " + "is copy == this.plans?: " + (this.plans == copy).valueOf())
    console.log("[InterventionPlanListComp] " + "length:" + this.plans.length + " " + JSON.stringify(this.plans))
    if (this.plans[index].isExpanded && this.plans[index].items.length === 0 && !this.plans[index].isLoadingItems) {
      this.loadPlanItemsAndTasks(index);
    }
  }

  private handleStopPlan(plan: PlanViewModel) {
    promptAction.showDialog({
      title: '停止计划',
      message: '确定要停止该干预计划吗？\n停止后，该计划及其下的所有计划项和待执行任务都将变为已停止状态。',
      buttons: [
        { text: '取消', color: '#666666' },
        { text: '确定', color: '#dc2626' }
      ]
    }).then(async (resp) => {
      if (resp.index === 1) {
        this.isLoading = true;
        try {
          const res = await InterventionService.stopPlan(plan.id);
          if (res.code === 200) {
            promptAction.showToast({ message: '计划已停止' });
            this.loadPlans(); // 刷新列表
          } else {
            promptAction.showToast({ message: res.message || '操作失败' });
          }
        } catch (error) {
          promptAction.showToast({ message: '网络异常，请重试' });
        } finally {
          this.isLoading = false;
        }
      }
    });
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'ACTIVE':
        return '进行中';
      case 'STOPPED':
        return '已停止';
      default:
        return status;
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'ACTIVE':
        return '#2563eb';
      case 'STOPPED':
        return '#ef4444';
      default:
        return '#6b7280';
    }
  }

  private getStatusBgColor(status: string): string {
    switch (status) {
      case 'ACTIVE':
        return '#eff6ff';
      case 'STOPPED':
        return '#fef2f2';
      default:
        return '#f3f4f6';
    }
  }

  @Builder
  buildPlanCard(plan: PlanViewModel) {

  }

  @Builder
  buildListContent(plans: Binding<PlanViewModel[]>) {
    if (this.isLoading && plans.value.length === 0) {
      LoadingProgress().width(40).height(40).margin({ top: 50 }).color('#2563eb')
    } else if (this.errorMsg) {
      Text(this.errorMsg).fontSize(14).fontColor('#dc2626').margin({ top: 50 })
    } else if (plans.value.length === 0) {
      Column() {
        Text('📋').fontSize(48)
        Text('暂无干预计划').fontSize(14).fontColor('#64748b')
      }.width('100%').margin({ top: 80 }).alignItems(HorizontalAlign.Center)
    } else {
      List() {
        ForEach(plans.value, (plan: PlanViewModel, index: number) => {
          ListItem() {
            CardContainer() {
              Column() {
                Row() {
                  Column() {
                    Text(plan.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1e293b')
                    if (plan.description) {
                      Text(plan.description).fontSize(13).fontColor('#64748b').margin({ top: 4 }).maxLines(1)
                    }
                  }.alignItems(HorizontalAlign.Start).layoutWeight(1)

                  if (plan.status === 'ACTIVE' && plan.editable) {
                    Button('停止计划')
                      .type(ButtonType.Normal)
                      .fontSize(12)
                      .fontColor('#dc2626')
                      .backgroundColor('#fee2e2')
                      .borderRadius(12)
                      .height(24)
                      .onClick(() => {
                        this.handleStopPlan(plan)
                      })
                  }
                }.width('100%')

                Row() {
                  Text(`${this.formatDate(plan.start_date)} ~ ${plan.end_date ? this.formatDate(plan.end_date) : '长期'}`)
                    .fontSize(12)
                    .fontColor('#94a3b8')

                  Text(this.getStatusText(plan.status))
                    .fontSize(12)
                    .fontColor(this.getStatusColor(plan.status))
                    .padding({
                      left: 8,
                      right: 8,
                      top: 2,
                      bottom: 2
                    })
                    .backgroundColor(this.getStatusBgColor(plan.status))
                    .borderRadius(4)
                    .margin({ left: 8 })

                  if (plan.totalTaskCount > 0) {
                    Text(`今日 ${plan.completedTaskCount}/${plan.totalTaskCount}`)
                      .fontSize(12)
                      .fontColor('#2563eb')
                      .margin({ left: 12 })
                  }
                }.width('100%').margin({ top: 8 })

                Row() {
                  Text(plan.isExpanded ? '收起 ▲' : '展开 ▼').fontSize(13).fontColor('#2563eb')
                }.width('100%').margin({ top: 12 }).justifyContent(FlexAlign.Center)
                .onClick(() => {
                  this.toggleExpand(plan.id)
                })

                if (plan.isExpanded) {
                  Divider().margin({ top: 12, bottom: 12 })
                  if (plan.isLoadingItems) {
                    LoadingProgress().width(24).height(24).color('#2563eb')
                  } else if (plan.items.length === 0) {
                    Text('暂无计划项').fontSize(13).fontColor('#9ca3af')
                  } else {
                    ForEach(plan.items, (item: PlanItemResponse) => {
                      Row() {
                        Text(item.item_type === 'MEDICATION' ? '💊' : '🏃').fontSize(20).margin({ right: 10 })
                        Column() {
                          Text(item.name).fontSize(14).fontColor('#1e293b')
                          Text(item.item_type === 'MEDICATION' ? item.drug_name || '' : item.exercise_name || '')
                            .fontSize(12).fontColor('#64748b').margin({ top: 2 })
                        }.alignItems(HorizontalAlign.Start).layoutWeight(1)

                        Text('→').fontSize(16).fontColor('#cbd5e1')
                      }
                      .width('100%')
                      .padding(10)
                      .backgroundColor('#f8fafc')
                      .borderRadius(8)
                      .margin({ bottom: 8 })
                      .onClick(() => {
                        this.openItemDetail(item)
                      })
                    })
                  }
                  if(plan.editable){
                    Button('+ 添加计划项')
                      .type(ButtonType.Normal)
                      .fontSize(13)
                      .height(36)
                      .width('100%')
                      .backgroundColor('#eff6ff')
                      .fontColor('#2563eb')
                      .borderRadius(8)
                      .margin({ top: 8 })
                      .onClick(() => {
                        this.openItemForm(plan.id)
                      })
                  }
                }
              }
            }
          }
        })
      }.width('100%').height('100%').padding({ left: 16, right: 16, top: 12 })
    }
  }

  build() {
    Column() {
      if (this.showTabs) {
        Tabs({ barPosition: BarPosition.Start, index: 0 }) {
          TabContent() {
            this.buildListContent(UIUtils.makeBinding(()=>this.plans))
          }.tabBar('全部计划')
          
          TabContent() {
            this.buildListContent(UIUtils.makeBinding(()=>this.plans))
          }.tabBar('由我创建的')
        }
        .barWidth('100%')
        .barMode(BarMode.Fixed)
        .backgroundColor(Color.White)
        .onChange((index: number) => {
          this.currentTabIndex = index
          this.loadPlans()
        })
      } else {
        this.buildListContent(UIUtils.makeBinding(()=>this.plans))
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}
