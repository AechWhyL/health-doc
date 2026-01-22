import { httpRequest } from '../common/api/HttpUtil';
import { RequestEnum } from '../common/api/httpEnum';
import { promptAction } from '@kit.ArkUI';
import { ElderHealthChart } from './ElderHealthChart';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

export type HealthStatusLevel = 'NORMAL' | 'MILD' | 'MODERATE' | 'SEVERE';

export interface HealthRuleResult {
  id: string;
  name: string;
  level: 'NORMAL' | 'MILD' | 'MODERATE' | 'SEVERE';
  message: string;
}

export interface HealthJudgment {
  bp_level?: HealthStatusLevel;
  fpg_level?: HealthStatusLevel;
  ppg_level?: HealthStatusLevel;
}

export interface HealthMeasurement {
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

export type HealthDataType = 'bp' | 'fpg' | 'weight';

interface TypeOption {
  key: HealthDataType;
  label: string;
}

interface ElderIdParams {
  page: number;
  pageSize: number;
  elder_id: number;
  include_judgment?: boolean;
}

interface HealthRulesParams {
  elder_id: number;
  windowDays: number;
}

@Component
export struct DailyHealthDataView {
  @Prop @Watch('onElderIdChange') elderId: number = -1;
  @Prop @Watch('onRefreshTriggerChange') refreshTrigger: number = 0;
  @State healthRecords: HealthMeasurement[] = [];
  @State healthRules: HealthRuleResult[] = [];
  @State isLoadingHealth: boolean = false;
  @State isLoadingRules: boolean = false;
  @State selectedType: HealthDataType = 'bp';
  @State currentTabIndex: number = 0;
  
  // Callback for "Add" button
  onAddClick?: () => void;

  private typeOptions: TypeOption[] = [
    { key: 'bp', label: '血压' } as TypeOption,
    { key: 'fpg', label: '血糖' } as TypeOption,
    { key: 'weight', label: '体重' } as TypeOption
  ];

  aboutToAppear(): void {
    if (this.elderId > 0) {
      this.loadHealthData();
      this.loadHealthRules();
    }
  }

  onElderIdChange() {
    if (this.elderId > 0) {
      this.loadHealthData();
      this.loadHealthRules();
    } else {
      this.healthRecords = [];
      this.healthRules = [];
    }
  }

  onRefreshTriggerChange() {
    this.loadHealthData();
    this.loadHealthRules();
  }
  
  // Public method to allow parent to trigger refresh
  public refresh(): void {
    this.loadHealthData();
    this.loadHealthRules();
  }

  private async loadHealthData(): Promise<void> {
    if (this.elderId <= 0) {
      return;
    }

    this.isLoadingHealth = true;
    try {
      const healthParams: ElderIdParams = { elder_id: this.elderId, page: 1, pageSize: 30, include_judgment: true };
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

  private async loadHealthRules(): Promise<void> {
    if (this.elderId <= 0) {
      return;
    }

    this.isLoadingRules = true;
    try {
      const params: HealthRulesParams = { elder_id: this.elderId, windowDays: 7 };
      const response = await httpRequest<ApiResponse<HealthRuleResult[]>, HealthRulesParams>({
        url: '/api/v1/elder-health/rules/evaluate',
        method: RequestEnum.GET,
        params: params
      });

      if (response.code === 200 && response.data) {
        this.healthRules = response.data;
      } else {
        this.healthRules = [];
      }
    } catch (error) {
      console.error('加载健康规则失败:', error);
      this.healthRules = [];
    } finally {
      this.isLoadingRules = false;
    }
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
      
      Blank()
      
      if (this.onAddClick) {
        Button('+ 添加')
          .type(ButtonType.Capsule)
          .backgroundColor('#2563eb')
          .fontSize(12)
          .height(28)
          .onClick(() => {
            if (this.onAddClick) {
              this.onAddClick();
            }
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }



  @Builder
  private DetailRecordItem(record: HealthMeasurement) {
    Column() {
      // Header: Time and Source
      Row() {
        Text(this.formatDate(record.measured_at))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1e293b')
        
        Blank()
        
        // Text(record.source === 'DEVICE' ? '设备上传' : '手动记录')
        //   .fontSize(12)
        //   .fontColor('#9ca3af')
      }
      .width('100%')
      .margin({ bottom: 12 })

      // Grid for Metrics
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        // BP
        Row(){
          Text('血压')
            .fontSize(12)
            .fontColor('#64748b')
            .width(40)

          if (record.sbp !== undefined && record.dbp !== undefined) {
            Text(`${record.sbp}/${record.dbp}`)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getBpStatusColor(record))
            Text(' mmHg')
              .fontSize(12)
              .fontColor('#9ca3af')
              .margin({ left: 4 })
          } else {
            Text('--')
              .fontSize(16)
              .fontColor('#cbd5e1')
          }
        }.width("100%")

        Row(){
          Text('血糖')
            .fontSize(12)
            .fontColor('#64748b')
            .width(40)

          if (record.fpg !== undefined) {
            Text(`${Number(record.fpg).toFixed(1)}`)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getFpgStatusColor(record))
            Text(' mmol/L')
              .fontSize(12)
              .fontColor('#9ca3af')
              .margin({ left: 4 })
          } else if (record.ppg_2h !== undefined) {
            Text(`${Number(record.ppg_2h).toFixed(1)}`)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1e293b') // PPG color logic if needed
            Text(' mmol/L')
              .fontSize(12)
              .fontColor('#9ca3af')
              .margin({ left: 4 })
          } else {
            Text('--')
              .fontSize(16)
              .fontColor('#cbd5e1')
          }
        }.width("100%")

        Row(){
          // Weight
          Row() {
            Text('体重')
              .fontSize(12)
              .fontColor('#64748b')
              .width(40)

            if (record.weight !== undefined) {
              Text(`${Number(record.weight).toFixed(1)}`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1e293b')
              Text(' kg')
                .fontSize(12)
                .fontColor('#9ca3af')
                .margin({ left: 4 })
            } else {
              Text('--')
                .fontSize(16)
                .fontColor('#cbd5e1')
            }
          }
        }.width("100%")

        // Steps (Optional)
        if (record.steps !== null) {
          Row() {
            Text('步数')
              .fontSize(12)
              .fontColor('#64748b')
              .width(40)
             Text(`${record.steps}`)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1e293b')
          }
          .width('48%')
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 10 })
    .shadow({ radius: 4, color: '#05000000', offsetY: 2 })
  }

  @Builder
  private HealthAnalysisSection() {
    Column() {
      Row() {
        Text('健康分析')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1e293b')
        Blank()
        // Optional: Date range hint
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.isLoadingRules) {
        Row() {
          LoadingProgress().width(24).height(24)
          Text(' 分析中...').fontSize(14).fontColor('#64748b')
        }.width('100%').justifyContent(FlexAlign.Center).padding(20)
      } else if (!this.isLoadingHealth && this.healthRecords.length < 7) {
        // Insufficient data hint
         Column() {
           Text('📊 数据较少')
             .fontSize(16)
             .fontWeight(FontWeight.Medium)
             .fontColor('#64748b')
             .margin({ bottom: 4 })
           Text('建议连续记录7天以上数据，以获取更准确的健康评估')
             .fontSize(12)
             .fontColor('#94a3b8')
         }
         .width('100%')
         .padding(24)
         .backgroundColor('#f8fafc')
         .borderRadius(12)
         .alignItems(HorizontalAlign.Center)
      } else if (this.healthRules.length > 0) {
        Column({ space: 8 }) {
          ForEach(this.healthRules, (rule: HealthRuleResult) => {
              Row() {
                if (this.isAbnormalLevel(rule.level)) {
                  Text('⚠️')
                    .fontSize(16)
                    .margin({ right: 8 })
                } else {
                  Text('✅')
                    .fontSize(16)
                    .margin({ right: 8 })
                }
                
                Text(rule.message)
                  .fontSize(14)
                  .fontColor(this.isAbnormalLevel(rule.level) ? '#b91c1c' : '#1e293b')
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.isAbnormalLevel(rule.level) ? '#fef2f2' : '#f0fdf4')
              .borderRadius(8)
              .alignItems(VerticalAlign.Top)
          })
        }
      } else {
        // Logic reached if enough data but no rules returned (unlikely if rules cover normal range)
        Text('暂无分析结果').fontSize(14).fontColor('#94a3b8').width('100%').textAlign(TextAlign.Center).padding(20)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ top: 12 })
  }

  @Builder
  private DataAnalysisTab() {
    Column() {
      // Type Selector
      this.TypeTabs()

      // Chart
      if (this.healthRecords.length > 0) {
        ElderHealthChart({
          healthRecords: this.healthRecords,
          selectedType: this.selectedType
        })
      } else {
        Column() {
          Text('暂无数据图表').fontSize(14).fontColor('#94a3b8')
        }.height(200).width('100%').justifyContent(FlexAlign.Center)
      }

      // Analysis
      this.HealthAnalysisSection()
    }
    .width('100%')
    .constraintSize({
      minHeight:"100%"
    })
    .padding({ top: 4, bottom: 20 })
  }

  @Builder
  private RecordListTab() {
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
        Text('📝')
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
            this.DetailRecordItem(record)
          }
        }, (record: HealthMeasurement) => record.id.toString())
      }
      .width('100%')
      .height("100%")
      .padding({ left: 16, right: 16, top: 8, bottom: 12 })
    }
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.Start, index: this.currentTabIndex }) {
        TabContent() {
          Column(){
            Scroll() {
              this.DataAnalysisTab()
            }
            .scrollable(ScrollDirection.Vertical)
            .scrollBar(BarState.Off)
            .width('100%')
            .layoutWeight(1)
          }
          .width('100%')
          .layoutWeight(1)
        }
        .tabBar('数据展示')

        TabContent() {
          this.RecordListTab()
        }
        .tabBar('记录列表')
      }
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barWidth('100%')
      .barHeight('auto')
      .animationDuration(300)
      .layoutWeight(1) // Fix: Occupy remaining space to prevent overflow
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
      
      // Floating Add Button (if needed globally, or keep inside specific tabs)
      if (this.onAddClick) {
        Button() { 
          Row() {
            Text('+')
             .fontSize(24)
             .fontColor(Color.White)
             .margin({ bottom: 2 })
          }
        }
        .width(48)
        .height(48)
        .position({ x: '85%', y: '85%' })
        .backgroundColor('#2563eb')
        .shadow({ radius: 6, color: '#402563eb', offsetY: 4 })
        .onClick(() => {
          if (this.onAddClick) {
            this.onAddClick();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}
