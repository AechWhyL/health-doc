import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';

import { AddHealthDataParams } from './AddHealthDataPage';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

interface ElderResponse {
  id: number;
  name: string;
  gender: number;
  age: number;
  phone: string;
}

interface UserElderRelationItem {
  relation_id: number;
  elder_id: number;
  relation_name: string | null;
  elder: ElderResponse;
}

interface MyEldersListData {
  items: UserElderRelationItem[];
  total: number;
}

type HealthStatusLevel = 'NORMAL' | 'MILD' | 'MODERATE' | 'SEVERE';

interface HealthJudgment {
  bp_level?: HealthStatusLevel;
  fpg_level?: HealthStatusLevel;
  ppg_level?: HealthStatusLevel;
}

interface HealthMeasurement {
  id: number;
  elder_id: number;
  measured_at: string;
  sbp?: number;
  dbp?: number;
  fpg?: number;
  ppg_2h?: number;
  weight?: number;
  steps?: number;
  source: string;
  judgment?: HealthJudgment;
}

interface HealthMeasurementListData {
  records: HealthMeasurement[];
  total: number;
  current: number;
  size: number;
}

type HealthDataType = 'bp' | 'fpg' | 'weight';

interface TypeOption {
  key: HealthDataType;
  label: string;
}

interface PaginationParams {
  page: number;
  pageSize: number;
}

interface ElderIdParams extends PaginationParams {
  elder_id: number;
  include_judgment?: boolean;
}

@Component
export struct HealthDataTab {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State elders: UserElderRelationItem[] = [];
  @State selectedElderId: number = -1;
  @State selectedElderName: string = ''
  @State healthRecords: HealthMeasurement[] = [];
  @State isLoadingElders: boolean = false;
  @State isLoadingHealth: boolean = false;
  @State selectedType: HealthDataType = 'bp';

  private typeOptions: TypeOption[] = [
    { key: 'bp', label: '血压' } as TypeOption,
    { key: 'fpg', label: '血糖' } as TypeOption,
    { key: 'weight', label: '体重' } as TypeOption
  ];

  aboutToAppear(): void {
    this.loadElders();
  }

  private async loadElders(): Promise<void> {
    this.isLoadingElders = true;
    try {
      const params: PaginationParams = { page: 1, pageSize: 20 };
      const response = await httpRequest<ApiResponse<MyEldersListData>, PaginationParams>({
        url: '/api/v1/users/me/elders',
        method: RequestEnum.GET,
        params: params
      });

      if (response.code === 200 && response.data) {
        this.elders = response.data.items || [];
        if (this.elders.length > 0) {
          this.selectedElderId = this.elders[0].elder_id;
          this.selectedElderName = this.elders[0].elder.name;
          this.loadHealthData();
        }
      }
    } catch (error) {
      console.error('加载老人列表失败:', error);
    } finally {
      this.isLoadingElders = false;
    }
  }

  private async loadHealthData(): Promise<void> {
    if (this.selectedElderId < 0) {
      return;
    }

    this.isLoadingHealth = true;
    try {
      const healthParams: ElderIdParams = { elder_id: this.selectedElderId, page: 1, pageSize: 30, include_judgment: true };
      const response = await httpRequest<ApiResponse<HealthMeasurementListData>, ElderIdParams>({
        url: '/api/v1/elder-health/daily-health/list',
        method: RequestEnum.GET,
        params: healthParams
      });

      if (response.code === 200 && response.data) {
        // 按时间倒序排列
        this.healthRecords = (response.data.records || []).sort((a, b) => {
          return new Date(b.measured_at).getTime() - new Date(a.measured_at).getTime();
        });
      }
    } catch (error) {
      console.error('加载健康数据失败:', error);
      promptAction.showToast({ message: '加载健康数据失败' });
    } finally {
      this.isLoadingHealth = false;
    }
  }

  private selectElder(item: UserElderRelationItem): void {
    this.selectedElderId = item.elder_id;
    this.selectedElderName = item.elder.name;
    this.loadHealthData();
  }

  private formatDate(dateStr: string): string {
    const d = new Date(dateStr);
    return (d.getMonth() + 1) + '/' + d.getDate();
  }

  private getLevelColor(level?: HealthStatusLevel): string {
    if (!level) {
      return '#9ca3af'; // 灰色 - 无数据
    }
    switch (level) {
      case 'NORMAL':
        return '#16a34a'; // 绿色 - 正常
      case 'MILD':
        return '#f59e0b'; // 橙色 - 轻度异常
      case 'MODERATE':
      case 'SEVERE':
        return '#dc2626'; // 红色 - 中度/严重
      default:
        return '#9ca3af';
    }
  }

  private getBpStatusColor(record: HealthMeasurement): string {
    if (record.judgment?.bp_level) {
      return this.getLevelColor(record.judgment.bp_level);
    }
    // 后备：无判断结果时用灰色
    if (record.sbp === undefined || record.dbp === undefined) {
      return '#9ca3af';
    }
    return '#1e293b'; // 默认文字颜色
  }

  private getFpgStatusColor(record: HealthMeasurement): string {
    if (record.judgment?.fpg_level) {
      return this.getLevelColor(record.judgment.fpg_level);
    }
    // 后备：无判断结果时用灰色
    if (record.fpg === undefined) {
      return '#9ca3af';
    }
    return '#1e293b'; // 默认文字颜色
  }

  private isAbnormalLevel(level?: HealthStatusLevel): boolean {
    return level === 'MODERATE' || level === 'SEVERE';
  }

  @Builder
  private ElderSelector() {
    Row() {
      Text('选择老人：')
        .fontSize(14)
        .fontColor('#64748b')

      if (this.elders.length > 0) {
        Select(this.elders.map((item) => {
          const v: SelectOption = { value: item.elder.name };
          return v;
        }))
          .selected(0)
          .value(this.selectedElderName)
          .font({ size: 14 })
          .fontColor('#1e293b')
          .onSelect((index: number) => {
            this.selectElder(this.elders[index]);
          })
          .layoutWeight(1)
      } else {
        Text('暂无关联老人')
          .fontSize(14)
          .fontColor('#9ca3af')
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
  }

  @Builder
  private TypeTabs() {
    Row() {
      ForEach(this.typeOptions, (option: TypeOption) => {
        Text(option.label)
          .fontSize(14)
          .fontWeight(this.selectedType === option.key ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.selectedType === option.key ? '#ffffff' : '#64748b')
          .backgroundColor(this.selectedType === option.key ? '#2563eb' : '#f1f5f9')
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .borderRadius(20)
          .margin({ right: 10 })
          .onClick(() => {
            this.selectedType = option.key;
          })
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }

  @Builder
  private HealthRecordList() {
    if (this.isLoadingHealth) {
      Column() {
        LoadingProgress().width(32).height(32)
        Text('加载中...').fontSize(13).fontColor('#64748b').margin({ top: 8 })
      }
      .width('100%')
      .height(200)
      .justifyContent(FlexAlign.Center)
    } else if (this.healthRecords.length === 0) {
      Column() {
        Text('📊')
          .fontSize(40)
        Text('暂无健康数据记录')
          .fontSize(14)
          .fontColor('#9ca3af')
          .margin({ top: 12 })
      }
      .width('100%')
      .height(200)
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.healthRecords, (record: HealthMeasurement) => {
          ListItem() {
            this.RecordItem(record)
          }
        }, (record: HealthMeasurement) => record.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  private RecordItem(record: HealthMeasurement) {
    Row() {
      // 日期
      Column() {
        Text(this.formatDate(record.measured_at))
          .fontSize(12)
          .fontColor('#64748b')
      }
      .width(50)

      // 数据值
      if (this.selectedType === 'bp') {
        Row() {
          if (record.sbp !== undefined && record.dbp !== undefined) {
            Text(record.sbp + '/' + record.dbp)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getBpStatusColor(record))
            Text(' mmHg')
              .fontSize(12)
              .fontColor('#9ca3af')
          } else {
            Text('—')
              .fontSize(18)
              .fontColor('#9ca3af')
          }
        }
        .layoutWeight(1)
      } else if (this.selectedType === 'fpg') {
        Row() {
          if (record.fpg !== undefined) {
            Text(Number(record.fpg).toFixed(1))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getFpgStatusColor(record))
            Text(' mmol/L')
              .fontSize(12)
              .fontColor('#9ca3af')
          } else {
            Text('—')
              .fontSize(18)
              .fontColor('#9ca3af')
          }
        }
        .layoutWeight(1)
      } else if (this.selectedType === 'weight') {
        Row() {
          if (record.weight !== undefined) {
            Text(Number(record.weight).toFixed(1))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1e293b')
            Text(' kg')
              .fontSize(12)
              .fontColor('#9ca3af')
          } else {
            Text('—')
              .fontSize(18)
              .fontColor('#9ca3af')
          }
        }
        .layoutWeight(1)
      }

      // 状态标签 - 使用后端判断结果
      if (this.selectedType === 'bp' && this.isAbnormalLevel(record.judgment?.bp_level)) {
        Text('⚠️ 偏高')
          .fontSize(11)
          .fontColor('#b91c1c')
          .backgroundColor('#fee2e2')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(10)
      } else if (this.selectedType === 'fpg' && this.isAbnormalLevel(record.judgment?.fpg_level)) {
        Text('⚠️ 偏高')
          .fontSize(11)
          .fontColor('#b91c1c')
          .backgroundColor('#fee2e2')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(10)
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 8 })
  }

  build() {
    Column() {
      // 页面标题
      Row() {
        Column() {
          Text('健康数据')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e293b')
          Text('查看老人健康指标趋势')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (this.selectedElderId > 0) {
          Button('+ 添加')
            .type(ButtonType.Capsule)
            .backgroundColor('#2563eb')
            .fontSize(13)
            .height(34)
            .onClick(() => {
              this.navPathStack.pushPath({
                name: 'Family_AddHealthData',
                  param: {
                    elderId: this.selectedElderId,
                    elderName: this.selectedElderName
                  } as AddHealthDataParams,
                  onPop: () => {
                    this.loadHealthData();
                  }
                });
            })
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })

      // 老人选择器
      this.ElderSelector()

      // 类型切换
      this.TypeTabs()

      // 数据列表
      this.HealthRecordList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}

