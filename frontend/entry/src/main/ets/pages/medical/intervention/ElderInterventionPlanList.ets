import { promptAction } from '@kit.ArkUI';
import { InterventionService } from '../../../common/api/InterventionService';
import {
  InterventionPlanResponse,
  InterventionPlanStatus,
  PlanItemResponse,
  PlanTaskInstanceResponse,
  UserElderRelationItem,
} from '../../../models/DTO/intervention';
import { PlanItemFormRouteParams } from './InterventionPlanItemForm'
import { PlanFormRouteParams } from './InterventionPlanForm'
import { InterventionPlanItemDetail } from '../intervention/InterventionPlanItemDetail'
import { InterventionPlanItemForm } from '../intervention/InterventionPlanItemForm'

interface PlanViewModel extends InterventionPlanResponse {
  isExpanded: boolean;
  isLoadingItems: boolean;
  items: PlanItemResponse[];
  todayTasks: PlanTaskInstanceResponse[]; // Tasks for all items in this plan for today
  completedTaskCount: number;
  totalTaskCount: number;
}

interface PlanItemBuilderParams {
  plan: PlanViewModel,
  index: number
}

@CustomDialog
struct AddPlanItemDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: () => {
    }
  })
  @Prop planId: number = -1

  build() {
    Column() {
      InterventionPlanItemForm({
        planId: this.planId
      })
    }
    .height('100%')
    .width('100%')
  }
}

@CustomDialog
struct PlanItemDetailDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: () => {
    }
  })
  @Prop item: PlanItemResponse | null = null

  build() {
    Column() {
      InterventionPlanItemDetail({
        item: this.item,
      })
    }

    .height
    ('100%'
    )
    .width
    ('100%'
    )
  }
}

@Component
export struct ElderInterventionPlanList {
  @State private elderRelation: UserElderRelationItem | null = null
  @State private plans: PlanViewModel[] = []
  @State private isLoading: boolean = false
  @State private errorMsg: string = ''
  @Consume('navPathStack') navPathStack: NavPathStack;
  addPlanItemDialogController: CustomDialogController | null = null
  planItemDetailController: CustomDialogController | null = null

  private async loadPlans() {
    if (!this.elderRelation) {
      return;
    }
    this.isLoading = true;
    try {
      const response = await InterventionService.getPlansByElderUserId(this.elderRelation.elder_id, {
        page: 1,
        pageSize: 100, // Load all for now
        orderBy: 'created_at desc'
      });

      if (response.code === 200 && response.data) {
        // Initialize ViewModels
        this.plans = response.data.records.map(plan => {
          let viewModel: PlanViewModel = {
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
          return viewModel;
        });
        console.log(`got plans${this.plans.length}`)

        // Eagerly load items and tasks for "ACTIVE" plans to show today's status
        this.loadActivePlansDetails();
      } else {
        this.errorMsg = response.message || '获取计划列表失败';
      }
    } catch (err) {
      this.errorMsg = '网络异常';
      console.log(err)
    } finally {
      this.isLoading = false;
    }
  }

  private async loadActivePlansDetails() {
    // For each plan, load items and then tasks
    // This might be slow, so we do it progressively or in parallel
    const promises = this.plans.map(async (plan, index) => {
      // Only load for active plans to save bandwidth, or load all if required. 
      // User said "show elder's all plan items' today's task items". So we should try to load all.
      // But 'FINISHED' plans might not have tasks today.
      if (plan.status !== 'ACTIVE' && plan.status !== 'PENDING') {
        return;
      }

      await this.loadPlanItemsAndTasks(index);
    });
    await Promise.all(promises);
  }

  private async loadPlanItemsAndTasks(index: number) {
    const plan = this.plans[index];
    this.plans[index].isLoadingItems = true;

    try {
      // 1. Get Items
      const itemsResp = await InterventionService.getPlanItemsByPlanId(plan.id);
      if (itemsResp.code === 200 && itemsResp.data) {
        console.log("got planItem info")
        const newPlanItem = this.plans[index]
        newPlanItem.items = itemsResp.data
        this.plans.splice(index, 1, newPlanItem);

        // 2. Get Today's Tasks for each item
        const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
        let totalTasks: PlanTaskInstanceResponse[] = [];

        const taskPromises = itemsResp.data.map(async (item) => {
          const tasksResp = await InterventionService.getTaskInstancesByItemId(item.id, {
            startDate: today,
            endDate: today
          });
          if (tasksResp.code === 200 && tasksResp.data) {
            return tasksResp.data;
          }
          return [];
        });

        const tasksArrays = await Promise.all(taskPromises);
        totalTasks = tasksArrays.flat();

        this.plans[index].todayTasks = totalTasks;
        this.plans[index].totalTaskCount = totalTasks.length;
        this.plans[index].completedTaskCount = totalTasks.filter(t => t.status === 'COMPLETED').length;
      }
    } catch (e) {
      console.error('Failed to load details for plan', plan.id);
    } finally {
      this.plans[index].isLoadingItems = false;
      // Trigger update
      // this.plans = [...this.plans]; // ArkTS array state update might need reassignment
      // But changing properties of object in array might not trigger UI update if not using @Observed/@ObjectLink. 
      // For simplicity in this structure, I'll reassign the element or the array.
      let p = this.plans[index];
      this.plans[index] = p; // This usually works for @State array index assignment
    }
  }

  private toggleExpand(index: number) {
    const newPlan = this.plans[index]
    newPlan.isExpanded = !this.plans[index].isExpanded
    this.plans.splice(index, 1, newPlan);
    console.log(`plan ${index}:`)
    console.log(`is expanded:${this.plans[index].isExpanded}`)
    // If expanding and no items, load them (if not already loaded by eager load)
    if (this.plans[index].isExpanded && this.plans[index].items.length === 0 && !this.plans[index].isLoadingItems) {
      this.loadPlanItemsAndTasks(index);
    }
  }

  private goToAddPlan() {
    if (!this.elderRelation) {
      return;
    }
    const param: PlanFormRouteParams = { elderUserId: this.elderRelation.elder_id };
    this.navPathStack.pushPath({
      name: 'Medical_Intervention_PlanForm',
      param: param as Object
    });
  }

  private goToAddItem(planId: number) {
    const param: PlanItemFormRouteParams = { planId: planId };
    // this.navPathStack.pushPath({
    //   name: 'Medical_Intervention_PlanItemForm', // User requested "Add Plan Item" form
    //   param: param as Object
    // });
    this.addPlanItemDialogController = new CustomDialogController({
      builder: AddPlanItemDialog({
        planId
      }),
      customStyle: true
    })
    this.addPlanItemDialogController.open()
  }

  private goToItemDetail(item: PlanItemResponse) {
    // this.navPathStack.pushPath({
    //   name: 'Medical_Intervention_PlanItemDetail',
    //   param: item as Object
    // });
    this.planItemDetailController = new CustomDialogController({
      builder: PlanItemDetailDialog({
        item: item
      })
    })
    this.planItemDetailController.open()
  }

  @Builder
  private buildPlanItem(plan: PlanViewModel, index: number) {
    Column() {
      // Plan Header
      Row() {
        Column() {
          Text(plan.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          Row() {
            Text(plan.status)
              .fontSize(12)
              .fontColor(this.getStatusColor(plan.status))
              .backgroundColor(this.getStatusBgColor(plan.status))
              .padding({
                left: 6,
                right: 6,
                top: 2,
                bottom: 2
              })
              .borderRadius(4)
              .margin({ right: 8 })

            Text(`今日任务: ${plan.completedTaskCount}/${plan.totalTaskCount}`)
              .fontSize(12)
              .fontColor('#6b7280')
          }
          .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // Expand Icon
        Text(plan.isExpanded ? '▲' : '▼')
          .fontSize(12)
          .fontColor('#9ca3af')
          .padding(10)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#ffffff')
      .borderRadius(8)
      .onClick(() => {
        this.toggleExpand(index);
      })

      // Expanded Content
      if (plan.isExpanded) {
        Column() {
          if (plan.isLoadingItems) {
            LoadingProgress().width(30).height(30).margin({ top: 10, bottom: 10 })
          } else if (plan.items.length === 0) {
            Text('暂无干预项')
              .fontSize(14)
              .fontColor('#9ca3af')
              .padding(10)
          } else {
            List() {
              ForEach(plan.items, (item: PlanItemResponse) => {
                ListItem() {
                  Row() {
                    Column() {
                      Text(item.name)
                        .fontSize(14)
                        .fontColor('#374151')
                      Text(item.item_type === 'MEDICATION' ? '用药' : '康复')
                        .fontSize(12)
                        .fontColor('#6b7280')
                    }
                    .alignItems(HorizontalAlign.Start)

                    Blank()

                    Button('详情')
                      .fontSize(12)
                      .height(24)
                      .backgroundColor('#e5e7eb')
                      .fontColor('#374151')
                      .onClick(() => {
                        this.goToItemDetail(item);
                      })
                  }
                  .width('100%')
                  .padding({
                    top: 8,
                    bottom: 8,
                    left: 12,
                    right: 12
                  })
                  .border({ width: { bottom: 1 }, color: '#f3f4f6' })
                }
              })
            }
            .width('100%')
          }

          // Add Item Button
          Button('+ 添加干预项')
            .width('100%')
            .height(36)
            .fontSize(14)
            .backgroundColor('#eff6ff')
            .fontColor('#3b82f6')
            .margin({ top: 8 })
            .onClick(() => {
              this.goToAddItem(plan.id);
            })
        }
        .width('100%')
        .backgroundColor('#f9fafb')
        .padding({ bottom: 12 })
        .borderRadius({ bottomLeft: 8, bottomRight: 8 })
      }
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isLoading && this.plans.length === 0) {
          LoadingProgress().width(50).height(50).margin({ top: 50 })
        } else if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize(16)
            .fontColor(Color.Red)
            .margin({ top: 50 })
        } else {
          List() {
            ForEach(this.plans, (plan: PlanViewModel, index: number) => {
              ListItem() {
                this.buildPlanItem(plan, index)
              }
            })
          }
          .width('100%')
          .height('100%')
          .padding(16)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f3f4f6')
    }
    .title(this.elderRelation ? `${this.elderRelation.elder.name}的干预计划` : '干预计划')
    .menus([
      {
        value: '新建',
        action: () => {
          this.goToAddPlan();
        }
      }
    ])
    .onReady((ctx: NavDestinationContext) => {
      this.elderRelation = (ctx.pathInfo.param) as UserElderRelationItem
      console.log("PlanList onReady")
      this.loadPlans()
    })
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'ACTIVE':
        return '#2563eb';
      case 'FINISHED':
        return '#059669';
      case 'STOPPED':
        return '#dc2626';
      default:
        return '#6b7280';
    }
  }

  private getStatusBgColor(status: string): string {
    switch (status) {
      case 'ACTIVE':
        return '#dbeafe';
      case 'FINISHED':
        return '#d1fae5';
      case 'STOPPED':
        return '#fee2e2';
      default:
        return '#f3f4f6';
    }
  }
}
