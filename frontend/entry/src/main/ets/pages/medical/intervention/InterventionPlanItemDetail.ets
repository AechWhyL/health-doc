import { InterventionService } from '../../../common/api/InterventionService';
import {
  MedicationPlanItemResponse,
  PlanItemResponse,
  PlanTaskInstanceResponse,
  RehabPlanItemResponse
} from '../../../models/DTO/intervention';
import { CardContainer } from '../../../components/common/CardContainer';

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
        .fontColor('#64748b')
        .width(80)
      Text(value)
        .fontSize(14)
        .fontColor('#1e293b')
        .layoutWeight(1)
        .fontWeight(FontWeight.Medium)
    }
    .padding({ top: 6, bottom: 6 })
    .alignItems(VerticalAlign.Top)
    .width('100%')
  }

  build() {
    NavDestination() {
      Column() {
        if (this.item) {
          Scroll() {
            Column() {
              // Basic Info
              CardContainer({ title: '基本信息' }) {
                Column() {
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
              }

              // Specific Info
              CardContainer({ title: this.item.item_type === 'MEDICATION' ? '用药详情' : '训练详情' }) {
                Column() {
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
              }

              // Today's Tasks
              CardContainer({ title: '今日任务' }) {
                Column() {
                  if (this.isLoadingTasks) {
                    LoadingProgress().width(20).height(20).color('#2563eb')
                  } else if (this.tasks.length === 0) {
                    Text('今日无任务')
                      .fontSize(14)
                      .fontColor('#9ca3af')
                  } else {
                    ForEach(this.tasks, (task: PlanTaskInstanceResponse, index: number) => {
                      Row() {
                        Column() {
                          Text(task.task_time ? task.task_time.substring(0, 5) : '全天')
                            .fontSize(16)
                            .fontWeight(FontWeight.Bold)
                            .fontColor('#1f2937')
                          Text(this.getStatusText(task.status))
                            .fontSize(12)
                            .fontColor(this.getStatusColor(task.status))
                            .margin({ top: 4 })
                        }
                        .layoutWeight(1)
                        .alignItems(HorizontalAlign.Start)
                        
                        // Check icon for completed
                        if (task.status === 'COMPLETED') {
                            Text('✅')
                                .fontSize(20)
                        } else if (task.status === 'SKIPPED') {
                             Text('⏭️')
                                .fontSize(20)
                        } else {
                            Text('⚪')
                                .fontSize(20)
                                .opacity(0.3)
                        }
                      }
                      .padding({ top: 12, bottom: 12 })
                      .border(index < this.tasks.length - 1 ? { width: { bottom: 1 }, color: '#f1f5f9' } : undefined)
                      .width('100%')
                    })
                  }
                }
              }
            }
            .constraintSize({
              minHeight:'100%'
            })
            .padding(16)
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f8fafc')
    }
    .title('计划项详情')
    .onReady((ctx: NavDestinationContext) => {
      this.item = ctx.pathInfo.param as PlanItemResponse
      this.loadTodayTasks()
    })
  }

  private getStatusText(status: string): string {
    switch (status) {
        case 'PENDING': return '待执行';
        case 'COMPLETED': return '已完成';
        case 'SKIPPED': return '已跳过';
        case 'MISSED': return '未完成';
        default: return status;
    }
  }

  private getStatusColor(status: string): string {
     switch (status) {
        case 'COMPLETED': return '#16a34a';
        case 'SKIPPED': return '#9ca3af';
        case 'MISSED': return '#dc2626';
        default: return '#ca8a04';
    }
  }
}
