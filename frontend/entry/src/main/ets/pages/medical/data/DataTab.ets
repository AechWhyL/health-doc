import { httpRequest } from '../../../common/api/HttpUtil';
import { RequestEnum } from '../../../common/api/httpEnum';
import { DailyHealthDataView } from '../../../components/DailyHealthDataView';
import { AddHealthDataParams } from './MedicalAddHealthDataPage';

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

interface PaginationParams {
  page: number;
  pageSize: number;
}

@Component
export struct DataTab {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State elders: UserElderRelationItem[] = []
  @State selectedElderId: number = -1
  @State selectedElderName: string = ''
  @State isLoadingElders: boolean = false

  aboutToAppear(): void {
    this.loadElders()
  }

  private async loadElders(): Promise<void> {
    this.isLoadingElders = true
    try {
      const params: PaginationParams = { page: 1, pageSize: 50 }
      const response = await httpRequest<ApiResponse<MyEldersListData>, PaginationParams>({
        url: '/api/v1/users/me/elders',
        method: RequestEnum.GET,
        token: 'auth',
        params: params
      })

      if (response.code === 200 && response.data) {
        this.elders = response.data.items || []
        if (this.elders.length > 0) {
          // Check if current selected ID is still in the list, if not, select first
           const exists = this.elders.some(item => item.elder_id === this.selectedElderId);
           if (!exists) {
             this.selectElder(this.elders[0]);
           }
        }
      }
    } catch (error) {
      console.error('Failed to load elders')
    } finally {
      this.isLoadingElders = false
    }
  }

  private selectElder(item: UserElderRelationItem): void {
    this.selectedElderId = item.elder_id
    this.selectedElderName = item.elder.name
  }

  @Builder
  private ElderSelector() {
    Row() {
      Text(this.selectedElderName ? `👤 ${this.selectedElderName}` : '选择老人')
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
    .margin({ left: 16, right: 16, top: 16, bottom: 8 })
    .bindMenu(this.elders.map((item: UserElderRelationItem) => {
      const menu: MenuElement = {
        value: item.elder.name,
        action: () => {
          this.selectElder(item)
        }
      }
      return menu
    }))
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
        Column() {
          Text('👥')
            .fontSize(40)
          Text('暂无关联老人')
            .fontSize(14)
            .fontColor('#9ca3af')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // Elder Selector
        this.ElderSelector()

        // Daily Health View
        if (this.selectedElderId > 0) {
          Row(){
            DailyHealthDataView({
              elderId: this.selectedElderId,
              onAddClick: () => {
                this.navPathStack.pushPath({
                  name: 'Medical_AddHealthData',
                  param: {
                    elderId: this.selectedElderId,
                    elderName: this.selectedElderName
                  } as AddHealthDataParams,
                  onPop: () => {
                    const id = this.selectedElderId;
                    this.selectedElderId = -1;
                    setTimeout(() => {
                      this.selectedElderId = id;
                    }, 10);
                  }
                });
              }
            })
          }
          .layoutWeight(1)

        } else {
             Column() {
                Text('请选择老人查看数据')
                  .fontSize(14)
                  .fontColor('#9ca3af')
                  .margin({ top: 50 })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}
