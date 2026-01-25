import { HealthRecordListView } from '../../components/health_record/HealthRecordListView';
import {
  HealthRecordItem,
  ElderBasicInfo,
  HealthRecordDetailParams
} from '../../models/HealthArchiveModels';

@Builder
export function FamilyHealthRecordListPageBuilder() {
  FamilyHealthRecordListPage()
}

@ComponentV2
export struct FamilyHealthRecordListPage {
  @Local private elder: ElderBasicInfo | null = null;
  @Local refresher:number = 0

  navPathStack: NavPathStack = new NavPathStack();

  private openDetailPage(record: HealthRecordItem): void {
    const detailParams: HealthRecordDetailParams = {
      recordId: record.id,
      mode: 'readonly',
      elderName: this.elder?.name || ''
    };

    this.navPathStack.pushPath({
      name: 'Common_HealthRecordDetail',
      param: detailParams
    });
  }

  build() {
    NavDestination() {
      Column() {
        if (this.elder) {
          HealthRecordListView({
            elderId: this.elder.id,
            elderName: this.elder.name,
            showAddButton: false,
            refresher:this.refresher,
            onItemClick: (record: HealthRecordItem) => {
              this.openDetailPage(record);
            }
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f1f5f9')
    }
    .title('健康档案')
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack;
      this.elder = ctx.pathInfo.param as ElderBasicInfo;
    })
    .onResult(()=>{
      this.refresher++
    })
    .width('100%')
    .height('100%')
  }
}
