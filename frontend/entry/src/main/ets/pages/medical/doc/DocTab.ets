import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../../common/api/HttpUtil';
import { RequestEnum } from '../../../common/api/httpEnum';
import { SectionHeader } from '../../../components/common/SectionHeader';
import { StatCard } from '../../../components/common/StatCard';
import { EmptyState } from '../../../components/common/EmptyState';
import { 
  ElderResponse
} from '../../../models/HealthArchiveModels';
import { Pagination } from '../../../components/common/Pagination';
import { PaginationResponse } from '../../../models/DTO/types';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}


interface ElderListParams {
  page: number;
  pageSize: number;
  elder_name?: string;
  phone?: string;
  linked_only?: boolean;
}

interface ElderListData extends PaginationResponse<ElderResponse>{

}

@Builder
export function DocTabBuilder(){
  DocTab()
}

@Component
export struct DocTab {
  @State private elders: ElderResponse[] = []
  @State private isLoadingElders: boolean = false
  @State private elderError: string = ''
  
  // 筛选相关状态
  @State private showFilterPanel: boolean = false
  @State private filterPhone: string = ''
  @State private filterName: string = ''
  @State private filterLinkedOnly: boolean = true

  // 分页相关
  @State @Watch('loadElders') private currentPage:number = 1
  @State private totalPages:number = 10
  @State private pageSize:number = 5
  @State private totalItems:number = 0

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
      const params: ElderListParams = {
        page: this.currentPage,
        pageSize: this.pageSize,
        elder_name: this.filterName || undefined,
        phone: this.filterPhone || undefined,
        linked_only: this.filterLinkedOnly
      }

      // 统一使用 elder/list 接口
      const response = await httpRequest<ApiResponse<ElderListData>, ElderListParams>({
        url: '/api/v1/elder-health/elder/list',
        method: RequestEnum.GET,
        token: 'auth',
        params
      })

      if (response.code !== 200 || !response.data) {
        const msg = response.message || '获取老人列表失败'
        this.elderError = msg
        return
      }

      const listData = response.data
      const pagination = response.data.meta
      this.pageSize = pagination.pageSize
      this.currentPage = pagination.currentPage
      this.totalPages = pagination.totalPages
      this.totalItems = pagination.totalItems
      const records = listData && listData.items ? listData.items : []

      this.elders = records
      this.elderError = ''
    } catch (error) {
      this.elderError = '网络异常'
    } finally {
      this.isLoadingElders = false
    }
  }



  // private isElderLinked(elderId: number): boolean {
  //   return this.elders.some((item: ElderWithArchiveStats) => item.relation.elder_id === elderId)
  // }



  private openElderArchiveDetail(elder: ElderResponse): void {
    this.navPathStack.pushPath({
      name: 'Medical_DocTab_ElderArchive',
      param: elder
    })
  }

  private getGenderEmoji(gender: number): string {
    return gender === 0 ? '👴' : '👵'
  }

  private getGenderText(gender: number): string {
    return gender === 0 ? '男' : '女';
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

  @Builder
  private buildFilterPanel() {
    if (this.showFilterPanel) {
      Column() {
        // 筛选标题
        Row() {
          Text('筛选条件')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e293b')
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 老人姓名输入框
        Column() {
          Text('老人姓名')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ bottom: 6 })
          TextInput({ placeholder: '请输入老人姓名', text: this.filterName })
            .fontSize(14)
            .onChange((value: string) => {
              this.filterName = value
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 12 })

        // 电话号码输入框
        Column() {
          Text('电话号码')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ bottom: 6 })
          TextInput({ placeholder: '请输入电话号码', text: this.filterPhone })
            .fontSize(14)
            .type(InputType.PhoneNumber)
            .onChange((value: string) => {
              this.filterPhone = value
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 12 })

        // 关联状态选择器
        Column() {
          Text('关联状态')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ bottom: 6 })
          Row() {
            Radio({ value: 'linked', group: 'linkedGroup' })
              .checked(this.filterLinkedOnly)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.filterLinkedOnly = true
                }
              })
            Text('仅显示已关联')
              .fontSize(14)
              .fontColor('#1e293b')
              .margin({ left: 8, right: 24 })
            
            Radio({ value: 'all', group: 'linkedGroup' })
              .checked(!this.filterLinkedOnly)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.filterLinkedOnly = false
                }
              })
            Text('显示所有老人')
              .fontSize(14)
              .fontColor('#1e293b')
              .margin({ left: 8 })
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 16 })

        // 按钮组
        Row({ space: 12 }) {
          Button('重置')
            .fontSize(14)
            .fontColor('#64748b')
            .backgroundColor('#f1f5f9')
            .layoutWeight(1)
            .onClick(() => {
              this.filterName = ''
              this.filterPhone = ''
              this.filterLinkedOnly = true
            })
          
          Button('确定')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#2563eb')
            .layoutWeight(1)
            .onClick(() => {
              this.showFilterPanel = false
              this.loadElders(true)
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .shadow({ radius: 8, color: '#0f172a14', offsetY: 2 })
      .margin({ bottom: 16 })
    }
  }

  build() {
    Column() {
      // 头部标题和筛选按钮
      Row() {
        Column() {
          Text('老人信息管理')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e293b')
          Text(`共 ${this.totalItems} 位`)
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 筛选按钮
        Button({ type: ButtonType.Normal }) {
          Row({ space: 4 }) {
            Text('🔍')
              .fontSize(16)
            Text('筛选')
              .fontSize(14)
              .fontColor('#2563eb')
          }
        }
        .backgroundColor('#eff6ff')
        .borderRadius(8)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          this.showFilterPanel = !this.showFilterPanel
        })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 筛选面板
      this.buildFilterPanel()

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
            ForEach(this.elders, (elder: ElderResponse) => {
              Column() {
                // 老人信息卡片
                Row() {
                  // 头像区域
                  Column() {
                    Text(this.getGenderEmoji(elder.gender))
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
                      Text(elder.name)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#1e293b')
                      Text(' · ' + this.getGenderText(elder.gender) + ' · ' + elder.age + '岁')
                        .fontSize(13)
                        .fontColor('#64748b')
                        .margin({ left: 8 })
                    }

                    Text('联系电话：' + elder.phone)
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
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(14)
              .shadow({ radius: 4, color: '#0f172a0a', offsetY: 1 })
              .margin({ bottom: 12 })
              .onClick(() => {
                this.openElderArchiveDetail(elder)
              })
            }, (elder: ElderResponse) => elder.id.toString())

            Pagination({
              currentPage:this.currentPage,
              totalPages:this.totalPages,
              onCurrentPageChange:(currentPage)=>{
                this.currentPage = currentPage
              }
            })
              .width("100%")
          }
          .constraintSize({
            minHeight:"100%"
          })
          .justifyContent(FlexAlign.SpaceBetween)
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
