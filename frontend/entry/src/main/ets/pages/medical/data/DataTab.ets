import { httpRequest } from '../../../common/api/HttpUtil';
import { RequestEnum } from '../../../common/api/httpEnum';
import { SectionHeader } from '../../../components/common/SectionHeader';
import { StatCard } from '../../../components/common/StatCard';
import { EmptyState } from '../../../components/common/EmptyState';
import { CardContainer } from '../../../components/common/CardContainer';

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

interface HealthJudgment {
  bp_level?: string;
  fpg_level?: string;
  ppg_level?: string;
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
}

interface MyEldersQueryParams {
  page: number;
  pageSize: number;
}

interface HealthDataQueryParams {
  elder_id: number;
  page: number;
  pageSize: number;
  include_judgment: boolean;
}

@Component
export struct DataTab {
  @State private elders: UserElderRelationItem[] = []
  @State private selectedElder: UserElderRelationItem | null = null
  @State private isLoadingElders: boolean = false
  @State private measurements: HealthMeasurement[] = []
  @State private isLoadingData: boolean = false
  @State private latestMeasurement: HealthMeasurement | null = null

  aboutToAppear(): void {
    this.loadElders()
  }

  private async loadElders(): Promise<void> {
    this.isLoadingElders = true
    try {
      const params: MyEldersQueryParams = { page: 1, pageSize: 50 }
      const response = await httpRequest<ApiResponse<MyEldersListData>, MyEldersQueryParams>({
        url: '/api/v1/users/me/elders',
        method: RequestEnum.GET,
        token: 'auth',
        params: params
      })

      if (response.code === 200 && response.data) {
        this.elders = response.data.items || []
        if (this.elders.length > 0) {
          this.selectedElder = this.elders[0]
          this.loadHealthData()
        }
      }
    } catch (error) {
      console.error('Failed to load elders')
    } finally {
      this.isLoadingElders = false
    }
  }

  private async loadHealthData(): Promise<void> {
    if (!this.selectedElder) {
      return
    }
    this.isLoadingData = true
    try {
      const params: HealthDataQueryParams = {
        elder_id: this.selectedElder.elder_id,
        page: 1,
        pageSize: 10,
        include_judgment: true
      }
      const response = await httpRequest<ApiResponse<HealthMeasurementListData>, HealthDataQueryParams>({
        url: '/api/v1/elder-health/daily-health/list',
        method: RequestEnum.GET,
        token: 'auth',
        params: params
      })

      if (response.code === 200 && response.data) {
        this.measurements = response.data.records || []
        this.latestMeasurement = this.measurements.length > 0 ? this.measurements[0] : null
      }
    } catch (error) {
      console.error('Failed to load health data')
    } finally {
      this.isLoadingData = false
    }
  }

  private selectElder(elder: UserElderRelationItem): void {
    this.selectedElder = elder
    this.loadHealthData()
  }

  private getBpStatusText(level?: string): string {
    switch (level) {
      case 'NORMAL': return '正常'
      case 'MILD': return '偏高'
      case 'MODERATE': return '中度'
      case 'SEVERE': return '严重'
      default: return '--'
    }
  }

  private getBpStatusColor(level?: string): string {
    switch (level) {
      case 'NORMAL': return '#16a34a'
      case 'MILD': return '#ca8a04'
      case 'MODERATE': return '#ea580c'
      case 'SEVERE': return '#dc2626'
      default: return '#64748b'
    }
  }

  private formatDateTime(dateStr: string): string {
    const date = new Date(dateStr)
    const now = new Date()
    const isToday = date.toDateString() === now.toDateString()
    const yesterday = new Date(now)
    yesterday.setDate(yesterday.getDate() - 1)
    const isYesterday = date.toDateString() === yesterday.toDateString()

    const time = `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`

    if (isToday) {
      return `今日 ${time}`
    } else if (isYesterday) {
      return `昨日 ${time}`
    } else {
      return `${date.getMonth() + 1}/${date.getDate()} ${time}`
    }
  }

  @Builder
  private buildElderSelector() {
    Row() {
      Text(this.selectedElder ? `👤 ${this.selectedElder.elder.name}` : '选择老人')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1e293b')
        .layoutWeight(1)

      Text('▼')
        .fontSize(12)
        .fontColor('#9ca3af')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: '#0f172a0a', offsetY: 1 })
    .margin({ bottom: 16 })
    .bindMenu(this.elders.map((elder: UserElderRelationItem) => {
      const item: MenuElement = {
        value: elder.elder.name,
        action: () => {
          this.selectElder(elder)
        }
      }
      return item
    }))
  }

  @Builder
  private buildHealthOverview() {
    if (this.latestMeasurement) {
      Row({ space: 12 }) {
        // 血压
        Column() {
          Text('血压')
            .fontSize(12)
            .fontColor('#64748b')
          if (this.latestMeasurement.sbp && this.latestMeasurement.dbp) {
            Text(`${this.latestMeasurement.sbp}/${this.latestMeasurement.dbp}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1e293b')
              .margin({ top: 4 })
            Text(this.getBpStatusText(this.latestMeasurement.judgment?.bp_level))
              .fontSize(11)
              .fontColor(this.getBpStatusColor(this.latestMeasurement.judgment?.bp_level))
              .margin({ top: 2 })
          } else {
            Text('--')
              .fontSize(20)
              .fontColor('#9ca3af')
              .margin({ top: 4 })
          }
        }
        .padding(14)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)

        // 血糖
        Column() {
          Text('血糖')
            .fontSize(12)
            .fontColor('#64748b')
          if (this.latestMeasurement.fpg !== undefined && this.latestMeasurement.fpg !== null) {
            Text(`${Number(this.latestMeasurement.fpg).toFixed(1)}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1e293b')
              .margin({ top: 4 })
            Text(this.getBpStatusText(this.latestMeasurement.judgment?.fpg_level))
              .fontSize(11)
              .fontColor(this.getBpStatusColor(this.latestMeasurement.judgment?.fpg_level))
              .margin({ top: 2 })
          } else {
            Text('--')
              .fontSize(20)
              .fontColor('#9ca3af')
              .margin({ top: 4 })
          }
        }
        .padding(14)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)

        // 体重
        Column() {
          Text('体重')
            .fontSize(12)
            .fontColor('#64748b')
          if (this.latestMeasurement.weight) {
            Text(`${this.latestMeasurement.weight}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1e293b')
              .margin({ top: 4 })
            Text('kg')
              .fontSize(11)
              .fontColor('#64748b')
              .margin({ top: 2 })
          } else {
            Text('--')
              .fontSize(20)
              .fontColor('#9ca3af')
              .margin({ top: 4 })
          }
        }
        .padding(14)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 16 })
    }
  }

  @Builder
  private buildMeasurementItem(m: HealthMeasurement) {
    Row() {
      Column() {
        Text(this.formatDateTime(m.measured_at))
          .fontSize(13)
          .fontColor('#64748b')

        Row({ space: 12 }) {
          if (m.sbp && m.dbp) {
            Row() {
              Text(`血压 ${m.sbp}/${m.dbp}`)
                .fontSize(14)
                .fontColor('#1e293b')
              if (m.judgment?.bp_level && m.judgment.bp_level !== 'NORMAL') {
                Text('⚠️')
                  .fontSize(12)
                  .margin({ left: 4 })
              }
            }
          }
          if (m.fpg) {
            Row() {
              Text(`血糖 ${Number(m.fpg).toFixed(1)}`)
                .fontSize(14)
                .fontColor('#1e293b')
              if (m.judgment?.fpg_level && m.judgment.fpg_level !== 'NORMAL') {
                Text('⚠️')
                  .fontSize(12)
                  .margin({ left: 4 })
              }
            }
          }
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.getBpStatusText(m.judgment?.bp_level || m.judgment?.fpg_level))
        .fontSize(12)
        .fontColor(this.getBpStatusColor(m.judgment?.bp_level || m.judgment?.fpg_level))
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(m.judgment?.bp_level === 'NORMAL' && m.judgment?.fpg_level === 'NORMAL' ? '#ecfdf5' : '#fef2f2')
        .borderRadius(12)
    }
    .width('100%')
    .padding(12)
    .margin({ bottom: 8 })
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  build() {
    Column() {
      if (this.isLoadingElders) {
        Column() {
          LoadingProgress().width(32).height(32).color('#2563eb')
          Text('加载中...')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.elders.length === 0) {
        EmptyState({
          icon: '👥',
          title: '暂无关联老人',
          subtitle: '请先在档案页面添加老人'
        })
      } else {
        // 老人选择器
        this.buildElderSelector()

        // 健康概览
        SectionHeader({ title: '健康概览' })
        if (this.isLoadingData) {
          LoadingProgress().width(24).height(24).color('#2563eb').margin({ bottom: 16 })
        } else if (this.latestMeasurement) {
          this.buildHealthOverview()
        } else {
          Text('暂无健康数据')
            .fontSize(13)
            .fontColor('#9ca3af')
            .margin({ bottom: 16 })
        }

        // 最近测量
        SectionHeader({ title: '最近测量' })
        if (this.measurements.length === 0) {
          EmptyState({
            icon: '📊',
            title: '暂无测量记录',
            subtitle: '等待老人上传健康数据'
          })
        } else {
          Scroll() {
            Column() {
              ForEach(this.measurements, (m: HealthMeasurement) => {
                this.buildMeasurementItem(m)
              }, (m: HealthMeasurement) => m.id.toString())
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#f8fafc')
  }
}
