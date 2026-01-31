import { promptAction } from '@kit.ArkUI';
import { InterventionService } from '../../common/api/InterventionService';
import dayjs from 'dayjs';
import {
  PlanItemResponse,
  MedicationPlanItemResponse,
  RehabPlanItemResponse,
  PlanTaskInstanceResponse
} from '../../models/DTO/intervention';
import { CheckInNavParam } from './ElderTaskCheckInPage';

export interface PlanItemDetailRouteParams {
  item: PlanItemResponse;
  editable:boolean;
}

@Builder
export function PlanItemDetailPageBuilder() {
  PlanItemDetailPage()
}

@Component
export struct PlanItemDetailPage {
  @State private detailItem: PlanItemResponse | null = null
  @State private detailTasks: PlanTaskInstanceResponse[] = []
  @State private detailLoading: boolean = false
  @State editable:boolean = false
  @Consume('navPathStack') navPathStack: NavPathStack;

  private formatDate(dateStr: string | null | undefined): string {
    if (!dateStr) {
      return '--'
    }
    return dayjs(dateStr).format('YYYY年M月D日')
  }

  private async loadTodayTasks() {
    if (!this.detailItem) {
      return;
    }
    this.detailLoading = true;
    try {
      const today = dayjs().format('YYYY-MM-DD')
      const resp = await InterventionService.getTaskInstancesByItemId(this.detailItem.id, {
        startDate: today,
        endDate: today
      })
      if (resp.code === 200 && resp.data) {
        this.detailTasks = resp.data
      }
    } catch (e) {
      console.error('Failed to load tasks', e)
    } finally {
      this.detailLoading = false
    }
  }

  private async stopPlanItem() {
    if (!this.detailItem) {
      return;
    }
    try {
      const resp = await InterventionService.updatePlanItemStatus(this.detailItem.id, 'STOPPED');
      if (resp.code === 200) {
        promptAction.showToast({ message: '计划项已停止' });
        this.navPathStack.pop();
      } else {
        promptAction.showToast({ message: resp.message || '操作失败' });
      }
    } catch (e) {
      promptAction.showToast({ message: '操作失败' });
      console.error('stopPlanItem error', e);
    }
  }

  private getTaskStatusText(status: string): string {
    switch (status) {
      case 'PENDING':
        return '待执行';
      case 'COMPLETED':
        return '已完成';
      case 'SKIPPED':
        return '已跳过';
      case 'MISSED':
        return '已错过';
      default:
        return status;
    }
  }

  private getTaskStatusColor(status: string): string {
    switch (status) {
      case 'COMPLETED':
        return '#059669';
      case 'PENDING':
        return '#6b7280';
      case 'SKIPPED':
        return '#d97706';
      case 'MISSED':
        return '#dc2626';
      default:
        return '#6b7280';
    }
  }

  build() {
    NavDestination() {
      Column() {
        if (this.detailItem) {
          Scroll() {
            Column() {
              Text(this.detailItem.item_type === 'MEDICATION' ? '💊 用药计划' : '🏃 康复计划')
                .fontSize(14).fontColor('#64748b').margin({ bottom: 8 })
              Text(this.detailItem.name).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#1e293b')

              if (this.detailItem.description) {
                Text(this.detailItem.description).fontSize(14).fontColor('#64748b').margin({ top: 8 })
              }

              Divider().margin({ top: 16, bottom: 16 })

              if (this.detailItem.item_type === 'MEDICATION') {
                Row() {
                  Text('药品名称').fontSize(14).fontColor('#374151').width(90)
                  Text((this.detailItem as MedicationPlanItemResponse).drug_name || '--').fontSize(14).fontColor('#1e293b')
                }.width('100%').margin({ bottom: 12 })
                Row() {
                  Text('剂量').fontSize(14).fontColor('#374151').width(90)
                  Text((this.detailItem as MedicationPlanItemResponse).dosage || '--').fontSize(14).fontColor('#1e293b')
                }.width('100%').margin({ bottom: 12 })
                Row() {
                  Text('频次').fontSize(14).fontColor('#374151').width(90)
                  Text((this.detailItem as MedicationPlanItemResponse).frequency_type || '--').fontSize(14).fontColor('#1e293b')
                }.width('100%').margin({ bottom: 12 })
              } else {
                Row() {
                  Text('训练名称').fontSize(14).fontColor('#374151').width(90)
                  Text((this.detailItem as RehabPlanItemResponse).exercise_name || '--').fontSize(14).fontColor('#1e293b')
                }.width('100%').margin({ bottom: 12 })
                if ((this.detailItem as RehabPlanItemResponse).exercise_type) {
                  Row() {
                    Text('训练类型').fontSize(14).fontColor('#374151').width(90)
                    Text((this.detailItem as RehabPlanItemResponse).exercise_type || '').fontSize(14).fontColor('#1e293b')
                  }.width('100%').margin({ bottom: 12 })
                }
              }

              Divider().margin({ top: 4, bottom: 16 })
              Row() {
                Text('开始日期').fontSize(14).fontColor('#374151').width(90)
                Text(this.formatDate(this.detailItem.start_date)).fontSize(14).fontColor('#1e293b')
              }.width('100%').margin({ bottom: 12 })
              Row() {
                Text('预计结束').fontSize(14).fontColor('#374151').width(90)
                Text(this.detailItem.end_date ? this.formatDate(this.detailItem.end_date) : '长期').fontSize(14).fontColor('#1e293b')
              }.width('100%')

              // 今日任务列表
              Divider().margin({ top: 16, bottom: 16 })
              if (this.detailItem.status === 'STOPPED') {
                Column() {
                  Text('🚫 计划项已停止').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#94a3b8').margin({ bottom: 8 })
                  // Text('该计划已停止，不再生成今日任务').fontSize(14).fontColor('#cbd5e1')
                }.width('100%').padding({ top: 20, bottom: 20 }).alignItems(HorizontalAlign.Center)
              } else {
                Row() {
                  Text('今日任务').fontSize(15).fontWeight(FontWeight.Medium).fontColor('#1e293b')
                  Blank()
                  Text(`${this.detailTasks.filter(t => t.status === 'COMPLETED').length}/${this.detailTasks.length}`)
                    .fontSize(13).fontColor('#2563eb')
                }.width('100%').margin({ bottom: 12 })

                if (this.detailLoading) {
                  Row() {
                    LoadingProgress().width(20).height(20).color('#2563eb')
                    Text('加载中...').fontSize(13).fontColor('#64748b').margin({ left: 8 })
                  }.width('100%').justifyContent(FlexAlign.Center).padding(16)
                } else if (this.detailTasks.length === 0) {
                  Text('今日暂无任务').fontSize(13).fontColor('#9ca3af').padding(16).textAlign(TextAlign.Center).width('100%')
                } else {
                  ForEach(this.detailTasks, (task: PlanTaskInstanceResponse) => {
                    Row() {
                      Column() {
                        Text(task.task_time || '--').fontSize(16).fontWeight(FontWeight.Medium)
                          .fontColor(task.status === 'COMPLETED' ? '#059669' : '#1e293b')
                        Text(this.getTaskStatusText(task.status)).fontSize(12)
                          .fontColor(this.getTaskStatusColor(task.status)).margin({ top: 2 })
                      }.alignItems(HorizontalAlign.Start).layoutWeight(1)

                      if (task.status === 'COMPLETED') {
                        Text('✓').fontSize(20).fontColor('#059669')
                      } else if (task.status === 'PENDING') {
                        Text('○').fontSize(20).fontColor('#d1d5db')
                      } else if (task.status === 'MISSED') {
                        Text('✗').fontSize(20).fontColor('#dc2626')
                      } else {
                        Text('—').fontSize(20).fontColor('#94a3b8')
                      }
                    }.width('100%').padding(12).backgroundColor('#f8fafc').borderRadius(8).margin({ bottom: 8 })
                    .onClick(() => {
                      if (task.status === 'COMPLETED' && this.navPathStack) {
                        // Prepare params for check-in page
                        const param:CheckInNavParam ={
                          taskInstanceId: task.id,
                          taskName: '任务详情'
                        }
                        const params: object = param
                        this.navPathStack.pushPathByName('Elder_TaskCheckIn', params);
                      }
                    })
                  })
                }
              }

              // 底部操作按钮
              if (this.detailItem && this.detailItem.status === 'ACTIVE' && this.editable) {
                Row() {
                  Button('停止计划项')
                    .type(ButtonType.Capsule)
                    .width('100%')
                    .height(44)
                    .backgroundColor('#dc2626')
                    .fontSize(15)
                    .onClick(() => {
                      this.stopPlanItem()
                    })
                }
                .width('100%')
                .padding({ left: 16, right: 16, bottom: 24, top: 8 })
              }
            }.padding(16)
            .constraintSize({
              minHeight:'100%'
            })
          }.layoutWeight(1)

        }
      }.width('100%').height('100%').backgroundColor('#f8fafc')
    }
    .title('计划项详情')
    .onReady((ctx: NavDestinationContext) => {
      const params = ctx.pathInfo.param as PlanItemDetailRouteParams
      if (params && params.item) {
        this.detailItem = params.item
        this.editable = params.editable
        this.loadTodayTasks()
      }
    })
  }
}
