import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';
import { AddHealthDataParams } from './AddHealthDataPage';
import { DailyHealthDataView } from '../../components/DailyHealthDataView';

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
export struct HealthDataTab {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State elders: UserElderRelationItem[] = [];
  @State selectedElderId: number = -1;
  @State selectedElderName: string = ''
  @State isLoadingElders: boolean = false;
  
  // Reference to the child component for refreshing
  private dailyHealthView: DailyHealthDataView | null = null;

  aboutToAppear(): void {
    this.loadElders();
    this.navPathStack.setInterception({
      willShow: (from: NavDestinationContext | 'navBar', to: NavDestinationContext | 'navBar') => {
        if (typeof from === 'string') {
        } else if (typeof to === 'string') {
          let target = from as NavDestinationContext;
          console.info(`${target.pathInfo.name} -> to page is navigation home`);
          this.loadElders()
        }
      }
    });
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
           // Check if current selected ID is still in the list, if not, select first
           const exists = this.elders.some(item => item.elder_id === this.selectedElderId);
           if (!exists) {
             this.selectElder(this.elders[0]);
           }
        }
      }
    } catch (error) {
      console.error('加载老人列表失败:', error);
    } finally {
      this.isLoadingElders = false;
    }
  }

  private selectElder(item: UserElderRelationItem): void {
    this.selectedElderId = item.elder_id;
    this.selectedElderName = item.elder.name;
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
          .selected(this.elders.findIndex(item => item.elder_id === this.selectedElderId))
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
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })

      // 老人选择器
      this.ElderSelector()

      // 数据组件
      if (this.selectedElderId > 0) {
        DailyHealthDataView({ 
          elderId: this.selectedElderId,
          onAddClick: () => {
            this.navPathStack.pushPath({
              name: 'Family_AddHealthData',
              param: {
                elderId: this.selectedElderId,
                elderName: this.selectedElderName
              } as AddHealthDataParams,
              onPop: () => {
                 // 自动刷新逻辑已经由 DailyHealthDataView 的 loadHealthData 处理，
                 // 但是页面返回时，aboutToAppear 会被 navPathStack interception 触发 loadElders。
                 // 这里我们主要依赖 DailyHealthDataView 的 watch 或者手动刷新。
                 // 由于 DailyHealthDataView 是子组件，其 @Watch('elderId') 只在 ID 变化时触发。
                 // 我们需要一种机制来强制刷新数据。
                 // 既然页面返回会触发 navPathStack interception -> loadElders，但 loadElders 不会变动 ID，所以子组件不会刷新。
                 // 最好是在这里强制刷新一下。
                 // 这里可以使用 key 属性或者类似机制，但 ArkTS 推荐数据驱动。
                 // 简单的做法是重新赋值 elderId (hack) 或者调用子组件方法。
                 // 这里的 onPop 回调是在 AddHealthDataPage pop 时触发的。
                 // 我们可以重新设置一个 flag 或者... 
                 // 实际上，DailyHealthDataView 在 aboutToAppear 会加载数据。
                 // 当从 AddHealthDataPage 返回时，DailyHealthDataView 并没有销毁。
                 // 我们可以传递一个 @State refreshKey 给 DailyHealthDataView 并 watch 它。
                 // 或者简单点，我们先不仅做这个优化，因为 HealthDataTab 的 onPop 逻辑其实是在 HealthDataTab 自己的 aboutToAppear nav interception 里写的。
                 // wait, the AddHealthDataPage code says: this.navPathStack.pop(true);
                 // The logic in HealthDataTab aboutToAppear handles "to page is navigation home" -> loadElders().
                 // We should make loadElders also trigger refreshing the data view if needed.
                 // Actually, simpler: reuse the selectedElderId trick.
                 const id = this.selectedElderId;
                 this.selectedElderId = -1;
                 setTimeout(() => {
                   this.selectedElderId = id;
                 }, 10);
              }
            });
          }
        })
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
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}
