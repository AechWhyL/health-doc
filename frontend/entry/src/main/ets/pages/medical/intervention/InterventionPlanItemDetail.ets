import { InterventionService } from '../../../common/api/InterventionService';
import {
  MedicationPlanItemResponse,
  PlanItemResponse,
  PlanTaskInstanceResponse,
  RehabPlanItemResponse
} from '../../../models/DTO/intervention';

@Builder
export function InterventionPlanItemDetailBuilder() {
  InterventionPlanItemDetail()
}

@Component
export struct InterventionPlanItemDetail {
  @State  item: PlanItemResponse | null = null
  @State  tasks: PlanTaskInstanceResponse[] = []
  @State  isLoadingTasks: boolean = false
  interventionPathStack: NavPathStack | null = null;

  private async loadTodayTasks() {
    if (!this.item) {
      return;
    }
    this.isLoadingTasks = true;
    try {
      const today = new Date().toISOString().split('T')[0];
      const response = await InterventionService.getTaskInstancesByItemId(this.item.id, {
        startDate: today,
        endDate: today
      });
      if (response.code === 200 && response.data) {
        this.tasks = response.data;
      }
    } catch (e) {
      console.error('Failed to load tasks');
    } finally {
      this.isLoadingTasks = false;
    }
  }

  @Builder
  private buildDetailRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#6b7280')
        .width(100)
      Text(value)
        .fontSize(14)
        .fontColor('#111827')
        .layoutWeight(1)
    }
    .padding({ top: 8, bottom: 8 })
    .alignItems(VerticalAlign.Top)
  }

  build() {
    NavDestination() {
      Column() {
        // Header
        Row() {
          Text('计划项详情')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#ffffff')
        .border({ width: { bottom: 1 }, color: '#e5e7eb' })

        if (this.item) {
          Scroll() {
            Column() {
              // Basic Info
              Column() {
                Text('基本信息')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 12 })

                this.buildDetailRow('名称', this.item.name)
                this.buildDetailRow('类型', this.item.item_type === 'MEDICATION' ? '用药' : '康复')
                this.buildDetailRow('状态', this.item.status)
                this.buildDetailRow('开始日期', this.item.start_date)
                if (this.item.end_date) {
                  this.buildDetailRow('结束日期', this.item.end_date)
                }
                if (this.item.description) {
                  this.buildDetailRow('说明', this.item.description)
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#ffffff')
              .margin({ bottom: 12 })

              // Specific Info
              Column() {
                Text(this.item.item_type === 'MEDICATION' ? '用药详情' : '训练详情')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 12 })

                if (this.item.item_type === 'MEDICATION') {
                  this.buildDetailRow('药品名称', (this.item as MedicationPlanItemResponse).drug_name)
                  this.buildDetailRow('剂量', (this.item as MedicationPlanItemResponse).dosage)
                  this.buildDetailRow('频次', (this.item as MedicationPlanItemResponse).frequency_type)
                  if ((this.item as MedicationPlanItemResponse).instructions) {
                    this.buildDetailRow('用药指示', (this.item as MedicationPlanItemResponse).instructions || '-')
                  }
                } else {
                  this.buildDetailRow('训练名称', (this.item as RehabPlanItemResponse).exercise_name)
                  if ((this.item as RehabPlanItemResponse).exercise_type) {
                    this.buildDetailRow('训练类型', (this.item as RehabPlanItemResponse).exercise_type || '-')
                  }
                  if ((this.item as RehabPlanItemResponse).guide_resource_url) {
                    this.buildDetailRow('资源链接', (this.item as RehabPlanItemResponse).guide_resource_url || '-')
                  }
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#ffffff')
              .margin({ bottom: 12 })

              // Today's Tasks
              Column() {
                Text('今日任务实例')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 12 })

                if (this.isLoadingTasks) {
                  LoadingProgress().width(20).height(20)
                } else if (this.tasks.length === 0) {
                  Text('今日无任务')
                    .fontSize(14)
                    .fontColor('#9ca3af')
                } else {
                  ForEach(this.tasks, (task: PlanTaskInstanceResponse) => {
                    Row() {
                      Column() {
                        Text(task.task_time ? task.task_time.substring(0, 5) : '全天')
                          .fontSize(16)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#1f2937')
                        Text(task.status)
                          .fontSize(12)
                          .fontColor(task.status === 'COMPLETED' ? '#16a34a' : '#ca8a04')
                          .margin({ top: 4 })
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                    }
                    .padding({ top: 8, bottom: 8 })
                    .border({ width: { bottom: 1 }, color: '#f3f4f6' })
                    .width('100%')
                  })
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#ffffff')
            }
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f9fafb')
    }
    .onReady((ctx: NavDestinationContext) => {
      console.log("PlanItem onReady")
      // this.item = ctx.pathInfo.param as PlanItemResponse
      // this.loadTodayTasks()
    })
  }
}
