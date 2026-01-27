import { promptAction, SymbolGlyphModifier } from '@kit.ArkUI';
import { InterventionService } from '../../../common/api/InterventionService';
import dayjs from 'dayjs';
import {
  InterventionPlanResponse,
  InterventionPlanStatus,
  PlanItemResponse,
  MedicationPlanItemResponse,
  RehabPlanItemResponse,
  PlanTaskInstanceResponse,
  UserElderRelationItem
} from '../../../models/DTO/intervention';
import { PlanFormRouteParams } from './InterventionPlanForm'
import { PlanItemFormRouteParams } from './PlanItemFormPage'
import { PlanItemDetailRouteParams } from './PlanItemDetailPage'
import { CardContainer } from '../../../components/common/CardContainer'
import { MedicalHealthDataParams } from '../data/MedicalHealthDataPage';

interface PlanViewModel extends InterventionPlanResponse {
  isExpanded: boolean;
  isLoadingItems: boolean;
  items: PlanItemResponse[];
  todayTasks: PlanTaskInstanceResponse[];
  completedTaskCount: number;
  totalTaskCount: number;
}

@Builder
export function ElderInterventionPlanListBuilder (){
  ElderInterventionPlanList()
}

@Component
export struct ElderInterventionPlanList {
  @State private elderRelation: UserElderRelationItem | null = null
  @State private plans: PlanViewModel[] = []
  @State private isLoading: boolean = false
  @State private errorMsg: string = ''
  @Consume('navPathStack') navPathStack: NavPathStack;

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
    if (!this.elderRelation) {
      return;
    }
    this.isLoading = true;
    try {
      // FIX: Use elder_user_id (user account ID) instead of elder_id (elder_basic_info.id)
      const elderUserId = this.elderRelation.elder_user_id ?? this.elderRelation.elder_id
      const response = await InterventionService.getPlansByElderUserId(elderUserId, {
        page: 1, pageSize: 100, orderBy: 'created_at desc'
      });
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
            totalTaskCount: 0
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

  private toggleExpand(index: number) {
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
      totalTaskCount: plan.totalTaskCount
    };
    const newPlans = this.plans.slice();
    newPlans[index] = updated;
    this.plans = newPlans;

    if (this.plans[index].isExpanded && this.plans[index].items.length === 0 && !this.plans[index].isLoadingItems) {
      this.loadPlanItemsAndTasks(index);
    }
  }

  private goToAddPlan() {
    if (!this.elderRelation) {
      return;
    }
    // FIX: Use elder_user_id (user account ID) instead of elder_id (elder_basic_info.id)
    const elderUserId = this.elderRelation.elder_user_id ?? this.elderRelation.elder_id
    const param: PlanFormRouteParams = { elderUserId: elderUserId };
    this.navPathStack.pushPathByName('Medical_Intervention_PlanForm', param);
  }

  private goToHealthData() {
    if (!this.elderRelation) {
      return;
    }
    const param: MedicalHealthDataParams = {
      elderId: this.elderRelation.elder_user_id ?? this.elderRelation.elder_id,
      elderName: this.elderRelation.elder.name
    };
    this.navPathStack.pushPathByName('Medical_HealthDataPage', param);
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
        return '进行的';
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
  buildPlanCard(plan: PlanViewModel, index: number) {
    CardContainer() {
      Column() {
        Row() {
          Column() {
            Text(plan.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1e293b')
            if (plan.description) {
              Text(plan.description).fontSize(13).fontColor('#64748b').margin({ top: 4 }).maxLines(1)
            }
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)

          if (plan.status === 'ACTIVE') {
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
          this.toggleExpand(index)
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

  build() {
    NavDestination() {
      Column() {
        if (this.isLoading && this.plans.length === 0) {
          LoadingProgress().width(40).height(40).margin({ top: 50 }).color('#2563eb')
        } else if (this.errorMsg) {
          Text(this.errorMsg).fontSize(14).fontColor('#dc2626').margin({ top: 50 })
        } else if (this.plans.length === 0) {
          Column() {
            Text('📋').fontSize(48)
            Text('暂无干预计划').fontSize(14).fontColor('#64748b')
          }.width('100%').margin({ top: 80 }).alignItems(HorizontalAlign.Center)
        } else {
          List() {
            ForEach(this.plans, (plan: PlanViewModel, index: number) => {
              ListItem() {
                this.buildPlanCard(plan, index)
              }
            })
          }.width('100%').height('100%').padding({ left: 16, right: 16, top: 12 })
        }
      }.width('100%').height('100%').backgroundColor('#f8fafc')
    }
    .title(this.elderRelation ? `${this.elderRelation.elder.name}的干预计划` : '干预计划')
    .menus([
      {
        value: $r('sys.symbol.heart'), action: () => {
          this.goToHealthData()
        }
      },
      {
        value: $r('sys.symbol.plus'), action: () => {
          this.goToAddPlan()
        }
      }
    ])
    .onReady((ctx: NavDestinationContext) => {
      console.info('[ElderInterventionPlanList] onReady called, param:', JSON.stringify(ctx.pathInfo.param))
      const param = ctx.pathInfo.param as UserElderRelationItem
      if (param && param.elder_id) {
        this.elderRelation = param
        this.loadPlans()
      } else {
        console.error('[ElderInterventionPlanList] Invalid param received')
        this.errorMsg = '参数错误，请返回重试'
      }
    })
    .onShown(() => {
      // Reload plans when returning to this page (e.g., after creating a plan item)
      if (this.elderRelation) {
        this.loadPlans()
      }
    })
  }
}
