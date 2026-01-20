import { TaskDetailNavParam, ElderTaskInstanceInfo, ElderPlanItemInfo, ElderPlanInfo } from './ElderHomeTab';
import { CheckInNavParam } from './ElderTaskCheckInPage';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';
import { promptAction } from '@kit.ArkUI';
import { data } from '@kit.TelephonyKit';
import dayjs from 'dayjs';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

interface TaskInstanceResponse {
  id: number;
  item_id: number;
  schedule_id: number | null;
  task_date: string;
  task_time: string | null;
  status: string;
  complete_time: string | null;
  remark: string | null;
  proof_image_url: string | null;
  created_at: string;
  updated_at: string;
}

@Builder
export function ElderTaskDetailPageBuilder() {
  ElderTaskDetailPage()
}

@Component
export struct ElderTaskDetailPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State task: ElderTaskInstanceInfo | null = null;
  @State planItem: ElderPlanItemInfo | null = null;
  @State plan: ElderPlanInfo | null = null;
  @State isRefreshing: boolean = false;

  aboutToAppear(): void {
    const params = this.navPathStack.getParamByName('Elder_TaskDetail') as TaskDetailNavParam[];
    if (params && params.length > 0) {
      const param = params[params.length - 1];
      this.task = param.task;
      this.planItem = param.plan_item;
      this.plan = param.plan;
    }
    console.log("[check in page] about to appear");
  }

  private async refreshTaskStatus(): Promise<void> {
    if (!this.task || this.isRefreshing) {
      return;
    }
    console.log("[check in page] refreshing task status");

    this.isRefreshing = true;
    try {
      // 调用API获取最新的任务实例状态
      const params: Record<string, Object> = {};
      const response = await httpRequest<ApiResponse<TaskInstanceResponse>, Record<string, Object>>({
        url: `/api/v1/intervention/tasks/${this.task.id}`,
        method: RequestEnum.GET,
        params: params
      });

      if (response.code === 200 && response.data) {
        // 直接更新task state的属性以触发UI响应
        this.task = {
          id:response.data.id,
          item_id:response.data.item_id,
          schedule_id:response.data.item_id,
          task_time:response.data.task_time,
          task_date:response.data.task_date,
          status: response.data.status,
          complete_time: response.data.complete_time,
          remark: response.data.remark,
          proof_image_url: response.data.proof_image_url
        };
      }
    } catch (error) {
      console.error('刷新任务状态失败:', error);
    } finally {
      this.isRefreshing = false;
    }
  }

  private formatDate(dateStr: string | null): string {
    if (!dateStr) return '未定';
    const date = new Date(dateStr);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'ACTIVE': return '进行中';
      case 'PAUSED': return '已暂停';
      case 'STOPPED': return '已停止';
      case 'PENDING': return '待完成';
      case 'COMPLETED': return '已完成';
      case 'SKIPPED': return '已跳过';
      case 'MISSED': return '已错过';
      case 'DRAFT': return '草稿';
      case 'FINISHED': return '已完成';
      case 'CANCELLED': return '已取消';
      default: return status;
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'ACTIVE': return '#16a34a';
      case 'PENDING': return '#f59e0b';
      case 'COMPLETED': return '#16a34a';
      case 'FINISHED': return '#16a34a';
      case 'PAUSED': return '#6b7280';
      case 'STOPPED': return '#dc2626';
      case 'SKIPPED': return '#9ca3af';
      case 'MISSED': return '#dc2626';
      case 'CANCELLED': return '#dc2626';
      default: return '#64748b';
    }
  }

  @Builder
  private PlanCard() {
    if (this.plan) {
      Column() {
        Row() {
          Text('📋')
            .fontSize(18)
          Text('所属计划')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#166534')
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ bottom: 16 })

        Column() {
          Row() {
            Text(this.plan.title)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              . fontColor('#1e293b')
              .layoutWeight(1)

            Text(this.getStatusText(this.plan.status))
              .fontSize(12)
              .fontColor(Color.White)
              .backgroundColor(this.getStatusColor(this.plan.status))
              .borderRadius(4)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          }
          .width('100%')
 
          if (this.plan.description) {
            Text(this.plan.description)
              .fontSize(14)
              .fontColor('#64748b')
              .margin({ top: 8 })
              .width('100%')
          }

          Divider()
            .strokeWidth(1)
            .color('#e5e7eb')
            .margin({ top: 12, bottom: 12 })

          Row() {
            Column() {
              Text('开始日期')
                .fontSize(12)
                .fontColor('#9ca3af')
              Text(this.formatDate(this.plan.start_date))
                .fontSize(14)
                .fontColor('#374151')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Column() {
              Text('结束日期')
                .fontSize(12)
                .fontColor('#9ca3af')
              Text(this.formatDate(this.plan.end_date))
                .fontSize(14)
                .fontColor('#374151')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
      }
      .width('100%')
      .padding(18)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 6, color: '#0f172a0a', offsetY: 2 })
      .margin({ bottom: 14 })
    }
  }

  @Builder
  private PlanItemCard() {
    if (this.planItem) {
      Column() {
        Row() {
          Text(this.planItem.item_type === 'MEDICATION' ? '💊' : '🏃')
            .fontSize(18)
          Text('计划项详情')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#166534')
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ bottom: 16 })

        Column() {
          Row() {
            Text(this.planItem.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1e293b')
              .layoutWeight(1)

            Text(this.getStatusText(this.planItem.status))
              .fontSize(12)
              .fontColor(Color.White)
              .backgroundColor(this.getStatusColor(this.planItem.status))
              .borderRadius(4)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          }
          .width('100%')

          Row() {
            Text(this.planItem.item_type === 'MEDICATION' ? '用药提醒' : '康复训练')
              .fontSize(12)
              .fontColor('#3b82f6')
              .backgroundColor('#eff6ff')
              .borderRadius(4)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .margin({ top: 8 })
          }
          .width('100%')

          if (this.planItem.description) {
            Text(this.planItem.description)
              .fontSize(14)
              .fontColor('#64748b')
              .margin({ top: 8 })
              .width('100%')
          }

          Divider()
            .strokeWidth(1)
            .color('#e5e7eb')
            .margin({ top: 12, bottom: 12 })

          // 用药详情
          if (this.planItem.item_type === 'MEDICATION') {
            Column() {
              if (this.planItem.drug_name) {
                Row() {
                  Text('药品名称：')
                    .fontSize(14)
                    .fontColor('#6b7280')
                  Text(this.planItem.drug_name)
                    .fontSize(14)
                    .fontColor('#1e293b')
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
                .margin({ bottom: 8 })
              }

              if (this.planItem.dosage) {
                Row() {
                  Text('剂量：')
                    .fontSize(14)
                    .fontColor('#6b7280')
                  Text(this.planItem.dosage)
                    .fontSize(14)
                    .fontColor('#1e293b')
                }
                .width('100%')
                .margin({ bottom: 8 })
              }

              if (this.planItem.frequency_type) {
                Row() {
                  Text('用药频次：')
                    .fontSize(14)
                    .fontColor('#6b7280')
                  Text(this.planItem.frequency_type)
                    .fontSize(14)
                    .fontColor('#1e293b')
                }
                .width('100%')
                .margin({ bottom: 8 })
              }

              if (this.planItem.instructions) {
                Column() {
                  Text('用药指示：')
                    .fontSize(14)
                    .fontColor('#6b7280')
                  Text(this.planItem.instructions)
                    .fontSize(14)
                    .fontColor('#1e293b')
                    .margin({ top: 4 })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }
            }
            .width('100%')
          }

          // 康复详情
          if (this.planItem.item_type === 'REHAB') {
            Column() {
              if (this.planItem.exercise_name) {
                Row() {
                  Text('训练名称：')
                    .fontSize(14)
                    .fontColor('#6b7280')
                  Text(this.planItem.exercise_name)
                    .fontSize(14)
                    .fontColor('#1e293b')
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
                .margin({ bottom: 8 })
              }

              if (this.planItem.exercise_type) {
                Row() {
                  Text('训练类型：')
                    .fontSize(14)
                    .fontColor('#6b7280')
                  Text(this.planItem.exercise_type)
                    .fontSize(14)
                    .fontColor('#1e293b')
                }
                .width('100%')
                .margin({ bottom: 8 })
              }

              if (this.planItem.guide_resource_url) {
                Row() {
                  Text('训练指导：')
                    .fontSize(14)
                    .fontColor('#6b7280')
                  Text('查看资源')
                    .fontSize(14)
                    .fontColor('#3b82f6')
                    .decoration({ type: TextDecorationType.Underline })
                }
                .width('100%')
              }
            }
            .width('100%')
          }

          Divider()
            .strokeWidth(1)
            .color('#e5e7eb')
            .margin({ top: 12, bottom: 12 })

          Row() {
            Column() {
              Text('开始日期')
                .fontSize(12)
                .fontColor('#9ca3af')
              Text(this.formatDate(this.planItem.start_date))
                .fontSize(14)
                .fontColor('#374151')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Column() {
              Text('结束日期')
                .fontSize(12)
                .fontColor('#9ca3af')
              Text(this.formatDate(this.planItem.end_date))
                .fontSize(14)
                .fontColor('#374151')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
      }
      .width('100%')
      .padding(18)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 6, color: '#0f172a0a', offsetY: 2 })
      .margin({ bottom: 14 })
    }
  }

  @Builder
  private TaskStatusCard() {
    if (this.task) {
      Column() {
        Row() {
          Row() {
            Text('📝')
              .fontSize(18)
            Text('今日任务')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#166534')
              .margin({ left: 8 })
          }
          .layoutWeight(1)

          // 签到按钮或已完成标识
          if (this.task.status === 'COMPLETED') {
            Text('✓ 已完成')
              .fontSize(13)
              .fontColor('#16a34a')
              .fontWeight(FontWeight.Medium)
          } else if (this.task.status === 'PENDING') {
            Button('签到')
              .fontSize(13)
              .fontColor(Color.White)
              .backgroundColor('#16a34a')
              .borderRadius(16)
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .onClick(() => {
                const navParam: CheckInNavParam = {
                  taskInstanceId: this.task!.id,
                  taskName: this.planItem!.name
                };
                this.navPathStack.pushPathByName('Elder_TaskCheckIn', navParam);
              })
          }
        }
        .width('100%')
        .margin({ bottom: 16 })

        Column() {
          Row() {
            Text('任务状态')
              .fontSize(14)
              .fontColor('#6b7280')
            Blank()
            Text(this.getStatusText(this.task.status))
              .fontSize(14)
              .fontColor(this.getStatusColor(this.task.status))
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text('任务日期')
              .fontSize(14)
              .fontColor('#6b7280')
            Blank()
            Text(this.formatDate(this.task.task_date))
              .fontSize(14)
              .fontColor('#374151')
          }
          .width('100%')
          .margin({ bottom: 12 })

          if (this.task.task_time) {
            Row() {
              Text('任务时间')
                .fontSize(14)
                .fontColor('#6b7280')
              Blank()
              Text(this.task.task_time)
                .fontSize(14)
                .fontColor('#374151')
            }
            .width('100%')
            .margin({ bottom: 12 })
          }

          if (this.task.complete_time) {
            Row() {
              Text('完成时间')
                .fontSize(14)
                .fontColor('#6b7280')
              Blank()
              Text(dayjs(this.task.complete_time).format('YYYY-MM-DD,HH:mm:ss'))
                .fontSize(14)
                .fontColor('#16a34a')
            }
            .width('100%')
            .margin({ bottom: 12 })
          }

          if (this.task.remark) {
            Column() {
              Text('备注')
                .fontSize(14)
                .fontColor('#6b7280')
              Text(this.task.remark)
                .fontSize(14)
                .fontColor('#374151')
                .margin({ top: 4 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
      }
      .width('100%')
      .padding(18)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 6, color: '#0f172a0a', offsetY: 2 })
    }
  }

  build() {
    NavDestination() {
      Column() {
        if (!this.task || !this.planItem || !this.plan) {
          Column() {
            Text('加载中...')
              .fontSize(16)
              .fontColor('#64748b')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column() {
              this.TaskStatusCard()
              this.PlanItemCard()
              this.PlanCard()
            }
            .padding({ left: 16, right: 16, top: 16, bottom: 20 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f0fdf4')
    }
    .title('任务详情')
    .backgroundColor('#f0fdf4')
    .onResult(()=>{
      this.refreshTaskStatus()
    })
  }
}
