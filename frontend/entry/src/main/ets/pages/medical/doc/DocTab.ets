import { promptAction } from '@kit.ArkUI';
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
  birth_date: string;
  phone: string;
  address: string | null;
  emergency_contact: string;
  height: number | null;
  weight: number | null;
  blood_type: string | null;
  age: number;
  created_at: string;
  updated_at: string;
}

interface UserElderRelationItem {
  relation_id: number;
  elder_id: number;
  relation_name: string | null;
  remark: string | null;
  elder: ElderResponse;
}

interface MyEldersQueryParams {
  page: number;
  pageSize: number;
  elder_name?: string;
}

interface MyEldersListData {
  items: UserElderRelationItem[];
  total: number;
}

interface AddMyElderRequest {
  elder_id: number;
  relation_name?: string;
  remark?: string;
}

interface ElderListQueryParams {
  phone?: string;
  page: number;
  pageSize: number;
  name?: string;
}

interface ElderListPageData {
  items: ElderResponse[];
  total: number;
  pages: number;
  current: number;
  size: number;
}

interface HealthJudgment {
  bp_level?: string;
  fpg_level?: string;
}

interface HealthMeasurement {
  id: number;
  sbp?: number;
  dbp?: number;
  fpg?: number;
  judgment?: HealthJudgment;
}

interface HealthMeasurementListData {
  records: HealthMeasurement[];
  total: number;
}

interface HealthDataQueryParams {
  elder_id: number;
  page: number;
  pageSize: number;
  include_judgment: boolean;
}

// 新API返回的健康摘要
interface HealthSummary {
  latest_bp?: string;
  latest_fpg?: string;
  bp_level?: string;
  fpg_level?: string;
}

// 新API返回的老人关系项（包含健康摘要）
interface UserElderWithHealthItem extends UserElderRelationItem {
  health_summary?: HealthSummary;
}

// 新API返回数据结构
interface EldersWithHealthListData {
  records: UserElderWithHealthItem[];
  total: number;
  abnormal_count: number;
}

// 扩展的老人关系，包含健康摘要
interface ElderWithHealth {
  relation: UserElderRelationItem;
  latestBp?: string;
  latestFpg?: string;
  bpStatus?: string;
  fpgStatus?: string;
}

interface buildElderCardParams {
  item:ElderWithHealth
}

@Builder
export function DocTabBuilder(){
  DocTab()
}

@Component
export struct DocTab {
  @State private eldersWithHealth: ElderWithHealth[] = []
  @State private isLoadingElders: boolean = false
  @State private elderError: string = ''
  @State private searchKeyword: string = ''
  @State private isSearchingByPhone: boolean = false
  @State private phoneSearchResult: ElderResponse | null = null
  @State private isAddingRelation: boolean = false
  @State private showAddPanel: boolean = false
  @State private abnormalCount: number = 0
  @Consume('navPathStack') navPathStack: NavPathStack;

  aboutToAppear(): void {
    this.loadElders(true)
  }

  private async loadElders(reset: boolean = false): Promise<void> {
    if (this.isLoadingElders) {
      return
    }

    this.isLoadingElders = true
    if (reset) {
      this.eldersWithHealth = []
    }

    try {
      const params: MyEldersQueryParams = {
        page: 1,
        pageSize: 50
      }

      // 使用新的合并接口，一次性获取老人列表和健康数据
      const response = await httpRequest<ApiResponse<EldersWithHealthListData>, MyEldersQueryParams>({
        url: '/api/v1/users/me/elders-with-health',
        method: RequestEnum.GET,
        token: 'auth',
        params
      })

      if (response.code !== 200 || !response.data) {
        const msg = response.message || '获取关联老人失败'
        this.elderError = msg
        return
      }

      const listData = response.data
      const elders = listData && listData.records ? listData.records : []

      // 直接从响应中解析健康数据，无需额外请求
      this.eldersWithHealth = elders.map((e: UserElderWithHealthItem) => {
        const item: ElderWithHealth = {
          relation: e,
          latestBp: e.health_summary?.latest_bp,
          latestFpg: e.health_summary?.latest_fpg,
          bpStatus: e.health_summary?.bp_level,
          fpgStatus: e.health_summary?.fpg_level
        }
        return item
      })
      this.abnormalCount = listData.abnormal_count || 0
      this.elderError = ''
    } catch (error) {
      this.elderError = '网络异常'
    } finally {
      this.isLoadingElders = false
    }
  }



  private isElderLinked(elderId: number): boolean {
    return this.eldersWithHealth.some((item: ElderWithHealth) => item.relation.elder_id === elderId)
  }

  private async searchElderByPhone(): Promise<void> {
    if (this.isSearchingByPhone) {
      return
    }
    const value = this.searchKeyword.trim()
    if (value === '') {
      return
    }
    if (!/^\d{11}$/.test(value)) {
      promptAction.showToast({ message: '请输入11位手机号搜索老人' })
      return
    }

    this.isSearchingByPhone = true
    this.phoneSearchResult = null

    try {
      let params: ElderListQueryParams = {
        page: 1,
        pageSize: 1,
        phone: value
      }

      const response = await httpRequest<ApiResponse<ElderListPageData>, ElderListQueryParams>({
        url: '/api/v1/elder-health/elder/list',
        method: RequestEnum.GET,
        token: 'auth',
        params
      })

      if (response.code !== 200 || !response.data) {
        promptAction.showToast({ message: '未找到该手机号对应的老人' })
        return
      }

      const pageData = response.data
      const records = pageData && pageData.items ? pageData.items : []
      if (records.length === 0) {
        promptAction.showToast({ message: '未找到该手机号对应的老人' })
        return
      }

      this.phoneSearchResult = records[0]
      this.showAddPanel = true
    } catch (error) {
      promptAction.showToast({ message: '搜索失败' })
    } finally {
      this.isSearchingByPhone = false
    }
  }

  private async addElderRelation(): Promise<void> {
    if (this.isAddingRelation || !this.phoneSearchResult) {
      return
    }
    if (this.isElderLinked(this.phoneSearchResult.id)) {
      promptAction.showToast({ message: '该老人已关联' })
      return
    }

    this.isAddingRelation = true

    try {
      const body: AddMyElderRequest = {
        elder_id: this.phoneSearchResult.id
      }

      const response = await httpRequest<ApiResponse<null>, AddMyElderRequest>({
        url: '/api/v1/users/me/elders',
        method: RequestEnum.POST,
        token: 'auth',
        params: body
      })

      if (response.code !== 200) {
        promptAction.showToast({ message: response.message || '关联失败' })
        return
      }

      promptAction.showToast({ message: '关联成功' })
      this.showAddPanel = false
      this.phoneSearchResult = null
      this.loadElders(true)
    } catch (error) {
      promptAction.showToast({ message: '网络异常' })
    } finally {
      this.isAddingRelation = false
    }
  }

  private openElderArchiveDetail(elder: ElderResponse): void {
    this.navPathStack.pushPath({
      name: 'Medical_DocTab_ElderArchive',
      param: elder
    })
  }

  private getGenderEmoji(gender: number): string {
    return gender === 1 ? '👴' : '👵'
  }

  private getStatusColor(status?: string): string {
    switch (status) {
      case 'NORMAL': return '#16a34a'
      case 'MILD': return '#ca8a04'
      case 'MODERATE': return '#ea580c'
      case 'SEVERE': return '#dc2626'
      default: return '#64748b'
    }
  }

  private getStatusBgColor(status?: string): string {
    switch (status) {
      case 'NORMAL': return '#f0fdf4'
      case 'MILD': return '#fefce8'
      case 'MODERATE': return '#fff7ed'
      case 'SEVERE': return '#fef2f2'
      default: return '#f1f5f9'
    }
  }

  @Builder
  private buildSearchBar() {
    Row() {
      Row() {
        Text('🔍')
          .fontSize(16)
          .margin({ right: 8 })
        TextInput({ text: this.searchKeyword, placeholder: '搜索姓名或手机号...' })
          .height(40)
          .fontSize(14)
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchKeyword = value
          })
          .onSubmit(() => {
            this.searchElderByPhone()
          })
      }
      .layoutWeight(1)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#f1f5f9')
      .borderRadius(20)

      Button(this.isSearchingByPhone ? '...' : '搜索')
        .type(ButtonType.Capsule)
        .height(40)
        .width(64)
        .fontSize(14)
        .backgroundColor('#2563eb')
        .margin({ left: 10 })
        .onClick(() => {
          this.searchElderByPhone()
        })
    }
    .width('100%')
    .padding({ bottom: 12 })
  }

  @Builder
  private buildStatsBar() {
    Row({ space: 12 }) {
      StatCard({
        value: this.eldersWithHealth.length.toString(),
        label: '关联老人',
        icon: '👥',
        color: '#2563eb',
        bgColor: '#eff6ff'
      })

      StatCard({
        value: this.abnormalCount.toString(),
        label: '异常指标',
        icon: '⚠️',
        color: this.abnormalCount > 0 ? '#dc2626' : '#16a34a',
        bgColor: this.abnormalCount > 0 ? '#fef2f2' : '#f0fdf4'
      })
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  @Builder
  private buildAddPanel() {
    if (this.showAddPanel) {
      CardContainer({ title: '添加老人' }) {
        Column() {
          if (this.phoneSearchResult) {
            Row() {
              Text(this.getGenderEmoji(this.phoneSearchResult.gender))
                .fontSize(32)
                .margin({ right: 12 })
              Column() {
                Text(this.phoneSearchResult.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                Text(`${this.phoneSearchResult.age}岁 · ${this.phoneSearchResult.phone}`)
                  .fontSize(13)
                  .fontColor('#64748b')
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 12 })

            if (this.isElderLinked(this.phoneSearchResult.id)) {
              Text('✓ 已关联')
                .fontSize(14)
                .fontColor('#16a34a')
            } else {
              Button(this.isAddingRelation ? '添加中...' : '确认添加')
                .type(ButtonType.Capsule)
                .width('100%')
                .height(40)
                .backgroundColor('#2563eb')
                .onClick(() => {
                  this.addElderRelation()
                })
            }
          } else {
            Text('请在上方搜索栏输入老人手机号搜索')
              .fontSize(13)
              .fontColor('#9ca3af')
          }
        }
      }
    }
  }

  @Builder
  private buildElderCard(params: buildElderCardParams) {
    Column() {
      Row() {
        Text(this.getGenderEmoji(params.item.relation.elder.gender))
          .fontSize(36)
          .margin({ right: 14 })

        Column() {
          Row() {
            Text(params.item.relation.elder.name)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1e293b')
            Text(`${params.item.relation.elder.age}岁`)
              .fontSize(13)
              .fontColor('#64748b')
              .margin({ left: 8 })
          }

          Text(params.item.relation.relation_name || '关联老人')
            .fontSize(12)
            .fontColor('#94a3b8')
            .margin({ top: 4 })

          // 健康摘要
          Row({ space: 8 }) {
            Row() {
              Text(`血压: ${params.item.latestBp || '--'}`)
                .fontSize(11)
                .fontColor(this.getStatusColor(params.item.bpStatus))
            }
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(this.getStatusBgColor(params.item.bpStatus))
            .borderRadius(4)

            Row() {
              Text(`血糖: ${params.item.latestFpg || '--'}`)
                .fontSize(11)
                .fontColor(this.getStatusColor(params.item.fpgStatus))
            }
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(this.getStatusBgColor(params.item.fpgStatus))
            .borderRadius(4)
          }
          .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('›')
          .fontSize(24)
          .fontColor('#cbd5e1')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(14)
    .shadow({ radius: 4, color: '#0f172a0a', offsetY: 1 })
    .margin({ bottom: 12 })
    .onClick(() => {
      this.openElderArchiveDetail(params.item.relation.elder)
    })
  }

  build() {
    Column() {
      // 搜索栏
      this.buildSearchBar()

      // 统计栏
      this.buildStatsBar()

      // 添加面板
      this.buildAddPanel()

      // 老人列表
      SectionHeader({
        title: '已关联的老人',
        subtitle: `共 ${this.eldersWithHealth.length} 位`
      })

      if (this.isLoadingElders && this.eldersWithHealth.length === 0) {
        Column() {
          LoadingProgress().width(32).height(32).color('#2563eb')
          Text('加载中...')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(40)
        .alignItems(HorizontalAlign.Center)
      } else if (this.elderError) {
        EmptyState({
          icon: '❌',
          title: '加载失败',
          subtitle: this.elderError,
          actionText: '重试',
          onAction: () => {
            this.loadElders(true)
          }
        })
      } else if (this.eldersWithHealth.length === 0) {
        EmptyState({
          icon: '👥',
          title: '暂无关联老人',
          subtitle: '通过手机号搜索添加老人',
          actionText: ''
        })
      } else {
        Scroll() {
          Column() {
            ForEach(this.eldersWithHealth, (item: ElderWithHealth) => {
              // this.buildElderCard({item})
              Column() {
                Row() {
                  Text(this.getGenderEmoji(item.relation.elder.gender))
                    .fontSize(36)
                    .margin({ right: 14 })

                  Column() {
                    Row() {
                      Text(item.relation.elder.name)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#1e293b')
                      Text(`${item.relation.elder.age}岁`)
                        .fontSize(13)
                        .fontColor('#64748b')
                        .margin({ left: 8 })
                    }

                    Text(item.relation.relation_name || '关联老人')
                      .fontSize(12)
                      .fontColor('#94a3b8')
                      .margin({ top: 4 })

                    // 健康摘要
                    Row({ space: 8 }) {
                      Row() {
                        Text(`血压: ${item.latestBp || '--'}`)
                          .fontSize(11)
                          .fontColor(this.getStatusColor(item.bpStatus))
                      }
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .backgroundColor(this.getStatusBgColor(item.bpStatus))
                      .borderRadius(4)

                      Row() {
                        Text(`血糖: ${item.latestFpg || '--'}`)
                          .fontSize(11)
                          .fontColor(this.getStatusColor(item.fpgStatus))
                      }
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .backgroundColor(this.getStatusBgColor(item.fpgStatus))
                      .borderRadius(4)
                    }
                    .margin({ top: 8 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Text('›')
                    .fontSize(24)
                    .fontColor('#cbd5e1')
                }
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(14)
              .shadow({ radius: 4, color: '#0f172a0a', offsetY: 1 })
              .margin({ bottom: 12 })
              .onClick(() => {
                this.openElderArchiveDetail(item.relation.elder)
              })
            }, (item: ElderWithHealth) => item.relation.relation_id.toString())
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#f8fafc')
  }
}
