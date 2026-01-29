import { HealthRecordHistory } from '../../models/HealthArchiveModels';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';
import dayjs from 'dayjs';
import { HealthRecordHistoryDetailPageParams } from './HealthRecordHistoryDetailPage';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

@Builder
export function HealthRecordHistoryPageBuilder() {
  HealthRecordHistoryPage()
}

@ComponentV2
export struct HealthRecordHistoryPage {
  @Local private recordId: number = 0;
  @Local private historyList: HealthRecordHistory[] = [];
  @Local private isLoading: boolean = true;
  @Local private loadError: string = '';
  private navPathStack: NavPathStack = new NavPathStack();

  private async loadHistory(): Promise<void> {
    this.isLoading = true;
    this.loadError = '';

    try {
      const response = await httpRequest<ApiResponse<HealthRecordHistory[]>, null>({
        url: '/api/v1/elder-health/health-record/' + this.recordId.toString() + '/history',
        method: RequestEnum.GET,
        token: 'auth'
      });

      if (response.code !== 200) {
        this.loadError = response.message || '加载历史记录失败';
        this.isLoading = false;
        return;
      }

      this.historyList = response.data || [];
      this.isLoading = false;
    } catch (_error) {
      this.loadError = '网络异常，加载历史记录失败';
      this.isLoading = false;
    }
  }

  private formatDate(dateStr: string): string {
    return dayjs(dateStr).format('YYYY-MM-DD HH:mm:ss');
  }

  private getOperationTypeLabel(type: string): string {
    return type === 'ADD' ? '新增档案' : '修改档案';
  }

  private getOperationTypeColor(type: string): string {
    return type === 'ADD' ? '#0ea5e9' : '#f59e0b'; // Sky blue for add, Amber for modify
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(48)
              .height(48)
              .color('#2563eb')
            Text('加载中...')
              .fontSize(14)
              .fontColor('#64748b')
              .margin({ top: 12 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.loadError) {
          Column() {
            Text('😕')
              .fontSize(48)
            Text(this.loadError)
              .fontSize(14)
              .fontColor('#64748b')
              .margin({ top: 12 })
            Button('重试')
              .type(ButtonType.Capsule)
              .backgroundColor('#2563eb')
              .fontColor(Color.White)
              .fontSize(14)
              .height(40)
              .margin({ top: 20 })
              .onClick(() => {
                this.loadHistory();
              })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.historyList.length === 0) {
          Column() {
            Text('📭')
              .fontSize(48)
            Text('暂无操作记录')
              .fontSize(14)
              .fontColor('#64748b')
              .margin({ top: 12 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.historyList, (item: HealthRecordHistory) => {
              ListItem() {
                Row() {
                  // Icon
                  Column() {
                    Text(item.operation_type === 'ADD' ? '➕' : '✏️')
                      .fontSize(20)
                  }
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .backgroundColor(item.operation_type === 'ADD' ? '#e0f2fe' : '#fef3c7')
                  .justifyContent(FlexAlign.Center)
                  .margin({ right: 12 })

                  // Content
                  Column() {
                    Text(this.getOperationTypeLabel(item.operation_type))
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#1e293b')
                    
                    Text(this.formatDate(item.created_at))
                      .fontSize(12)
                      .fontColor('#94a3b8')
                      .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  // Operator
                  Column() {
                    Text(item.operator_name || '未知用户')
                      .fontSize(14)
                      .fontColor('#64748b')
                  }
                  .margin({ right: 8 })

                  // Arrow
                  Text('›')
                    .fontSize(24)
                    .fontColor('#cbd5e1')
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 4 }) // Adjust visual center
                }
                .width('100%')
                .padding(16)
                .backgroundColor(Color.White)
                .borderRadius(12)
                .margin({ bottom: 12 })
                .shadow({
                    radius: 2,
                    color: '#0f172a08',
                    offsetY: 1
                })
                .onClick(() => {
                  const params:HealthRecordHistoryDetailPageParams = { history: item }
                  this.navPathStack.pushPath({
                    name: 'Common_HealthRecordHistoryDetail',
                    param: params
                  });
                })
              }
            })
          }
          .width('100%')
          .height('100%')
          .padding(16)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f8fafc')
    }
    .title('操作历史')
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack;
      this.recordId = ctx.pathInfo.param as number;
      this.loadHistory();
    })
  }
}
