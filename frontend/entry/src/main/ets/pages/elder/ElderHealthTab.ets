import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

interface ElderResponse {
  id: number;
  name: string;
}

interface UserElderRelationItem {
  relation_id: number;
  elder_id: number;
  elder: ElderResponse;
}

interface MyEldersListData {
  items: UserElderRelationItem[];
  total: number;
}

interface HealthMeasurement {
  id: number;
  elder_id: number;
  measured_at: string;
  sbp?: number;
  dbp?: number;
  fpg?: number;
  weight?: number;
  source: string;
}

interface HealthMeasurementListData {
  items: HealthMeasurement[];
  total: number;
}

interface CreateHealthRequest {
  elder_id: number;
  measured_at: string;
  sbp?: number;
  dbp?: number;
  fpg?: number;
  weight?: number;
  source: string;
}

interface PaginationParams {
  page: number;
  pageSize: number;
}

interface ElderIdParams extends PaginationParams {
  elder_id: number;
}

@Component
export struct ElderHealthTab {
  @State elderId: number = -1;
  @State elderName: string = '';
  @State sbpValue: string = '';
  @State dbpValue: string = '';
  @State fpgValue: string = '';
  @State weightValue: string = '';
  @State isSubmitting: boolean = false;
  @State healthRecords: HealthMeasurement[] = [];
  @State isLoadingRecords: boolean = false;
  @State showInputForm: boolean = true;

  aboutToAppear(): void {
    this.loadElderInfo();
  }

  private async loadElderInfo(): Promise<void> {
    try {
      const params: PaginationParams = { page: 1, pageSize: 1 };
      const response = await httpRequest<ApiResponse<MyEldersListData>, PaginationParams>({
        url: '/api/v1/users/me/elders',
        method: RequestEnum.GET,
        params: params
      });

      if (response.code === 200 && response.data && response.data.items.length > 0) {
        const elder = response.data.items[0].elder;
        this.elderId = elder.id;
        this.elderName = elder.name;
        this.loadHealthRecords();
      }
    } catch (error) {
      console.error('加载老人信息失败:', error);
    }
  }

  private async loadHealthRecords(): Promise<void> {
    if (this.elderId < 0) return;

    this.isLoadingRecords = true;
    try {
      const healthParams: ElderIdParams = { elder_id: this.elderId, page: 1, pageSize: 10 };
      const response = await httpRequest<ApiResponse<HealthMeasurementListData>, ElderIdParams>({
        url: '/api/v1/elder-health/daily-health/list',
        method: RequestEnum.GET,
        params: healthParams
      });

      if (response.code === 200 && response.data) {
        this.healthRecords = response.data.items || [];
      }
    } catch (error) {
      console.error('加载健康记录失败:', error);
    } finally {
      this.isLoadingRecords = false;
    }
  }

  private async submitHealthData(): Promise<void> {
    if (this.elderId < 0) {
      promptAction.showToast({ message: '未找到您的老人档案' });
      return;
    }

    if (this.sbpValue === '' && this.fpgValue === '' && this.weightValue === '') {
      promptAction.showToast({ message: '请至少填写一项健康数据' });
      return;
    }

    this.isSubmitting = true;

    try {
      const data: CreateHealthRequest = {
        elder_id: this.elderId,
        measured_at: new Date().toISOString(),
        source: 'MANUAL'
      };

      if (this.sbpValue !== '' && this.dbpValue !== '') {
        data.sbp = parseFloat(this.sbpValue);
        data.dbp = parseFloat(this.dbpValue);
      }
      if (this.fpgValue !== '') {
        data.fpg = parseFloat(this.fpgValue);
      }
      if (this.weightValue !== '') {
        data.weight = parseFloat(this.weightValue);
      }

      const response = await httpRequest<ApiResponse<HealthMeasurement>, CreateHealthRequest>({
        url: '/api/v1/elder-health/daily-health',
        method: RequestEnum.POST,
        params: data
      });

      if (response.code === 200 || response.code === 201) {
        promptAction.showToast({ message: '数据已保存' });
        this.sbpValue = '';
        this.dbpValue = '';
        this.fpgValue = '';
        this.weightValue = '';
        this.loadHealthRecords();
      } else {
        promptAction.showToast({ message: response.message || '保存失败' });
      }
    } catch (error) {
      console.error('保存健康数据失败:', error);
      promptAction.showToast({ message: '保存失败，请重试' });
    } finally {
      this.isSubmitting = false;
    }
  }

  private formatDate(dateStr: string): string {
    const d = new Date(dateStr);
    return (d.getMonth() + 1) + '月' + d.getDate() + '日 ' +
      String(d.getHours()).padStart(2, '0') + ':' + String(d.getMinutes()).padStart(2, '0');
  }

  @Builder
  private InputForm() {
    Column() {
      Row() {
        Text('📝 录入健康数据')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#166534')
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 血压输入
      Column() {
        Text('血压 (mmHg)')
          .fontSize(13)
          .fontColor('#64748b')
          .alignSelf(ItemAlign.Start)
        Row() {
          TextInput({ text: this.sbpValue, placeholder: '收缩压' })
            .type(InputType.Number)
            .height(44)
            .fontSize(16)
            .backgroundColor('#f0fdf4')
            .borderRadius(10)
            .layoutWeight(1)
            .onChange((value: string) => {
              this.sbpValue = value;
            })
          Text('/')
            .fontSize(20)
            .fontColor('#9ca3af')
            .margin({ left: 8, right: 8 })
          TextInput({ text: this.dbpValue, placeholder: '舒张压' })
            .type(InputType.Number)
            .height(44)
            .fontSize(16)
            .backgroundColor('#f0fdf4')
            .borderRadius(10)
            .layoutWeight(1)
            .onChange((value: string) => {
              this.dbpValue = value;
            })
        }
        .margin({ top: 6 })
      }
      .margin({ bottom: 16 })

      // 血糖输入
      Column() {
        Text('空腹血糖 (mmol/L)')
          .fontSize(13)
          .fontColor('#64748b')
          .alignSelf(ItemAlign.Start)
        TextInput({ text: this.fpgValue, placeholder: '如 5.6' })
          .type(InputType.Number)
          .height(44)
          .fontSize(16)
          .backgroundColor('#f0fdf4')
          .borderRadius(10)
          .margin({ top: 6 })
          .onChange((value: string) => {
            this.fpgValue = value;
          })
      }
      .margin({ bottom: 16 })

      // 体重输入
      Column() {
        Text('体重 (kg)')
          .fontSize(13)
          .fontColor('#64748b')
          .alignSelf(ItemAlign.Start)
        TextInput({ text: this.weightValue, placeholder: '如 65.5' })
          .type(InputType.Number)
          .height(44)
          .fontSize(16)
          .backgroundColor('#f0fdf4')
          .borderRadius(10)
          .margin({ top: 6 })
          .onChange((value: string) => {
            this.weightValue = value;
          })
      }
      .margin({ bottom: 20 })

      Button(this.isSubmitting ? '保存中...' : '💾 保存数据')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(48)
        .backgroundColor('#16a34a')
        .fontSize(16)
        .enabled(!this.isSubmitting)
        .onClick(() => {
          this.submitHealthData();
        })
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 6, color: '#0f172a0a', offsetY: 2 })
    .margin({ bottom: 14 })
  }

  @Builder
  private HistoryList() {
    Column() {
      Row() {
        Text('📊 历史记录')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#166534')
      }
      .width('100%')
      .margin({ bottom: 14 })

      if (this.isLoadingRecords) {
        Row() {
          LoadingProgress().width(24).height(24)
          Text('加载中...').fontSize(13).fontColor('#64748b').margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding(20)
      } else if (this.healthRecords.length === 0) {
        Column() {
          Text('📋')
            .fontSize(32)
          Text('暂无健康记录')
            .fontSize(14)
            .fontColor('#9ca3af')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(20)
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(this.healthRecords, (record: HealthMeasurement) => {
          Column() {
            Row() {
              Text(this.formatDate(record.measured_at))
                .fontSize(12)
                .fontColor('#64748b')
            }
            .width('100%')
            .margin({ bottom: 8 })

            Row() {
              if (record.sbp !== undefined && record.dbp !== undefined) {
                Column() {
                  Text('血压')
                    .fontSize(11)
                    .fontColor('#9ca3af')
                  Text(record.sbp + '/' + record.dbp)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(record.sbp >= 140 ? '#dc2626' : '#1e293b')
                }
                .layoutWeight(1)
              }

              if (record.fpg !== undefined) {
                Column() {
                  Text('血糖')
                    .fontSize(11)
                    .fontColor('#9ca3af')
                  Text(record.fpg.toFixed(1))
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(record.fpg >= 7.0 ? '#dc2626' : '#1e293b')
                }
                .layoutWeight(1)
              }

              if (record.weight !== undefined) {
                Column() {
                  Text('体重')
                    .fontSize(11)
                    .fontColor('#9ca3af')
                  Text(record.weight.toFixed(1) + 'kg')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1e293b')
                }
                .layoutWeight(1)
              }
            }
            .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#f8fafc')
          .borderRadius(12)
          .margin({ bottom: 8 })
        }, (record: HealthMeasurement) => record.id.toString())
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 6, color: '#0f172a0a', offsetY: 2 })
  }

  build() {
    Column() {
      // 页面标题
      Row() {
        Column() {
          Text('健康数据')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#166534')
          Text('记录您的日常健康指标')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })

      Scroll() {
        Column() {
          this.InputForm()
          this.HistoryList()
        }
        .padding({ left: 16, right: 16, bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}
