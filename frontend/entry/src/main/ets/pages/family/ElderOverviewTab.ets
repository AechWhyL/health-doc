import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';
import { ElderCard } from '../../components/family/ElderCard';
import { 
  ArchiveStats, 
  ElderWithArchiveStats, 
  EldersWithArchiveStatsListData,
  UserElderWithArchiveStatsResponse,
  ElderResponse
} from '../../models/HealthArchiveModels';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

interface PaginationParams {
  page: number;
  pageSize: number;
}

@Component
export struct ElderOverviewTab {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State elders: ElderWithArchiveStats[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';


  aboutToAppear(): void {
    this.loadElders();
  }

  private async loadElders(): Promise<void> {
    if (this.isLoading) {
      return;
    }
    this.isLoading = true;
    this.errorMessage = '';

    try {
      // Get elders with archive stats
      const params: PaginationParams = { page: 1, pageSize: 20 };
      const response = await httpRequest<ApiResponse<EldersWithArchiveStatsListData>, PaginationParams>({
        url: '/api/v1/users/me/elders-with-stats',
        method: RequestEnum.GET,
        params: params
      });

      if (response.code !== 200 || !response.data) {
        this.errorMessage = response.message || '获取关联老人失败';
        promptAction.showToast({ message: this.errorMessage });
        return;
      }

      const items = response.data.items || [];

      this.elders = items.map(item => {
        return {
          relation: item,
          archiveStats: item.archive_stats
        } as ElderWithArchiveStats;
      });

    } catch (error) {
      console.error('加载关联老人失败:', error);
      this.errorMessage = '网络异常，无法获取老人列表';
      promptAction.showToast({ message: this.errorMessage });
    } finally {
      this.isLoading = false;
    }
  }

  private openElderArchive(elder: ElderResponse): void {
    this.navPathStack.pushPath({
      name: 'Family_ElderArchive',
      param: elder
    });
  }



  build() {
    Stack() {
    Column() {
      // 页面标题
      Row() {
        Column() {
          Text('关联老人')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e293b')
          Text('实时查看老人档案')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)


      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })

      // 加载状态
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('正在加载...')
            .fontSize(14)
            .fontColor('#64748b')
            .margin({ top: 12 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.errorMessage !== '') {
        // 错误状态
        Column() {
          Text('😔')
            .fontSize(40)
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#ef4444')
            .margin({ top: 12 })
          Button('重新加载')
            .type(ButtonType.Capsule)
            .backgroundColor('#2563eb')
            .margin({ top: 16 })
            .onClick(() => {
              this.loadElders();
            })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.elders.length === 0) {
        // 空状态
        Column() {
          Text('👨‍👩‍👧‍👦')
            .fontSize(48)
          Text('暂无关联老人')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#374151')
            .margin({ top: 16 })
          Text('请联系医护人员添加老人关联关系')
            .fontSize(13)
            .fontColor('#9ca3af')
            .margin({ top: 8 })
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
      } else {
        // 老人卡片列表
        Scroll() {
          Column() {
            ForEach(this.elders, (item: ElderWithArchiveStats) => {
              ElderCard({
                elderName: item.relation.elder.name,
                elderAge: item.relation.elder.age,
                elderGender: item.relation.elder.gender,
                elderPhone: item.relation.elder.phone,
                relationName: item.relation.relation_name || '',
                archiveStats: item.archiveStats,
                onCardClick: () => {
                  this.openElderArchive(item.relation.elder);
                },
                onViewArchive: () => {
                  this.openElderArchive(item.relation.elder);
                }
              })
            }, (item: ElderWithArchiveStats) => item.relation.relation_id.toString())
          }
          .padding({ left: 16, right: 16, bottom: 20 })
          .constraintSize({
            minHeight:'100%'
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')


    }
    .width('100%')
    .height('100%')
  }
}
