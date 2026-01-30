import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../../common/api/HttpUtil';
import { RequestEnum } from '../../../common/api/httpEnum';
import { SectionHeader } from '../../../components/common/SectionHeader';
import { StatCard } from '../../../components/common/StatCard';
import { EmptyState } from '../../../components/common/EmptyState';
import { 
  ArchiveStats, 
  ElderResponse,
  ElderWithArchiveStats,
  EldersWithArchiveStatsListData,
  UserElderWithArchiveStatsResponse
} from '../../../models/HealthArchiveModels';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}


interface MyEldersQueryParams {
  page: number;
  pageSize: number;
  elder_name?: string;
}

@Builder
export function DocTabBuilder(){
  DocTab()
}

@Component
export struct DocTab {
  @State private elders: ElderWithArchiveStats[] = []
  @State private isLoadingElders: boolean = false
  @State private elderError: string = ''

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
      this.elders = []
    }

    try {
      const params: MyEldersQueryParams = {
        page: 1,
        pageSize: 50
      }

      // 使用新的统计接口
      const response = await httpRequest<ApiResponse<EldersWithArchiveStatsListData>, MyEldersQueryParams>({
        url: '/api/v1/users/me/elders-with-stats',
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
      const records = listData && listData.items ? listData.items : []

      this.elders = records.map((e: UserElderWithArchiveStatsResponse) => {
        return {
          relation: e,
          archiveStats: e.archive_stats
        } as ElderWithArchiveStats
      })
      this.elderError = ''
    } catch (error) {
      this.elderError = '网络异常'
    } finally {
      this.isLoadingElders = false
    }
  }



  private isElderLinked(elderId: number): boolean {
    return this.elders.some((item: ElderWithArchiveStats) => item.relation.elder_id === elderId)
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

  private getGenderText(gender: number): string {
    return gender === 1 ? '男' : '女';
  }

  @Builder
  private buildStatsBar() {
    Row({ space: 12 }) {
      StatCard({
        value: this.elders.length.toString(),
        label: '关联老人',
        icon: '👥',
        color: '#2563eb',
        bgColor: '#eff6ff'
      })
      
      // 可以添加其他统计信息，或者仅仅保留关联老人数量
      // StatCard({
      //   value: this.elders.reduce((acc, curr) => acc + curr.archiveStats.total, 0).toString(),
      //   label: '档案总数',
      //   icon: '📋',
      //   color: '#16a34a',
      //   bgColor: '#f0fdf4'
      // })
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  build() {
    Column() {
      // // 统计栏
      // this.buildStatsBar()

      // 老人列表
      SectionHeader({
        title: '我正在关注的老人列表',
        subtitle: `共 ${this.elders.length} 位`
      })

      if (this.isLoadingElders && this.elders.length === 0) {
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
      } else if (this.elders.length === 0) {
        EmptyState({
          icon: '👥',
          title: '暂无关联老人',
          subtitle: '通过手机号搜索添加老人',
          actionText: ''
        })
      } else {
        Scroll() {
          Column() {
            ForEach(this.elders, (item: ElderWithArchiveStats) => {
              Column() {
                // 顶部信息区
                Row() {
                    // 头像区域
                    Column() {
                    Text(this.getGenderEmoji(item.relation.elder.gender))
                        .fontSize(32)
                    }
                    .width(56)
                    .height(56)
                    .borderRadius(28)
                    .backgroundColor('#f1f5f9')
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)

                    // 基本信息
                    Column() {
                        Row() {
                            Text(item.relation.elder.name)
                            .fontSize(16)
                            .fontWeight(FontWeight.Bold)
                            .fontColor('#1e293b')
                            Text(' · ' + this.getGenderText(item.relation.elder.gender) + ' · ' + item.relation.elder.age + '岁')
                            .fontSize(13)
                            .fontColor('#64748b')
                            .margin({ left: 8 })
                        }

                        Text('联系电话：' + item.relation.elder.phone)
                        .fontSize(12)
                        .fontColor('#94a3b8')
                        .margin({ top: 4 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                    .margin({ left: 14 })

                  Text('›')
                    .fontSize(24)
                    .fontColor('#cbd5e1')
                }
                .width('100%')

                Divider()
                .strokeWidth(1)
                .color('#f1f5f9')
                .margin({ top: 12, bottom: 12 })

                // 档案统计区
                Row() {
                    Column() {
                        Text(item.archiveStats.total.toString())
                            .fontSize(20)
                            .fontWeight(FontWeight.Bold)
                            .fontColor('#1e293b')
                        Text('档案总数')
                            .fontSize(12)
                            .fontColor('#64748b')
                            .margin({ top: 4 })
                    }
                    .alignItems(HorizontalAlign.Center)
                    .width(80)

                    // 垂直分割线
                    Divider()
                        .vertical(true)
                        .height(30)
                        .color('#e2e8f0')
                        .margin({ left: 10, right: 10 })

                    // 摘要详情
                    Row({ space: 8 }) {
                        if (item.archiveStats.breakdown['MEDICAL_HISTORY']) {
                            Text(`病史 ${item.archiveStats.breakdown['MEDICAL_HISTORY']}`)
                            .fontSize(11)
                            .fontColor('#64748b')
                            .backgroundColor('#f8fafc')
                            .padding({ left: 6, right: 6, top: 4, bottom: 4 })
                            .borderRadius(4)
                        }
                        if (item.archiveStats.breakdown['CHECK_REPORT']) {
                            Text(`检查 ${item.archiveStats.breakdown['CHECK_REPORT']}`)
                            .fontSize(11)
                            .fontColor('#64748b')
                            .backgroundColor('#f8fafc')
                            .padding({ left: 6, right: 6, top: 4, bottom: 4 })
                            .borderRadius(4)
                        }
                        if (item.archiveStats.breakdown['MEDICATION']) {
                            Text(`用药 ${item.archiveStats.breakdown['MEDICATION']}`)
                            .fontSize(11)
                            .fontColor('#64748b')
                            .backgroundColor('#f8fafc')
                            .padding({ left: 6, right: 6, top: 4, bottom: 4 })
                            .borderRadius(4)
                        }
                        if (item.archiveStats.breakdown['ALLERGY']) {
                            Text(`过敏 ${item.archiveStats.breakdown['ALLERGY']}`)
                            .fontSize(11)
                            .fontColor('#64748b')
                            .backgroundColor('#f8fafc')
                            .padding({ left: 6, right: 6, top: 4, bottom: 4 })
                            .borderRadius(4)
                        }
                    }
                    .layoutWeight(1)
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
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
            }, (item: ElderWithArchiveStats) => item.relation.relation_id.toString())
          }
          .constraintSize({
            minHeight:"100%"
          })
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
