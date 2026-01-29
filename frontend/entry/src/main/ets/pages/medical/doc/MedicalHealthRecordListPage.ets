import { HealthRecordListView } from '../../../components/health_record/HealthRecordListView';
import {
  HealthRecordItem,
  ElderBasicInfo,
  AddHealthRecordParams,
  HealthRecordDetailParams
} from '../../../models/HealthArchiveModels';
import { SymbolGlyphModifier } from '@kit.ArkUI';
import {HealthRecordListViewController} from '../../../components/health_record/HealthRecordListView'

@Builder
export function MedicalHealthRecordListPageBuilder() {
  MedicalHealthRecordListPage()
}

@ComponentV2
export struct MedicalHealthRecordListPage {
  @Local private elder: ElderBasicInfo | null = null;

  @Local refresher:number = 0

  navPathStack: NavPathStack = new NavPathStack();
  private listViewRef: HealthRecordListView | null = null;

  private openDetailPage(record: HealthRecordItem): void {
    const detailParams: HealthRecordDetailParams = {
      recordId: record.id,
      mode: 'editable',
      elderName: this.elder?.name || ''
    };

    this.navPathStack.pushPath({
      name: 'Common_HealthRecordDetail',
      param: detailParams
    });
  }

  private openAddPage(): void {
    if (!this.elder) return;

    const params: AddHealthRecordParams = {
      elderId: this.elder.id,
      elderName: this.elder.name,
      mode: 'create'
    };

    this.navPathStack.pushPath({
      name: 'Common_AddHealthRecord',
      param: params,
      onPop: () => {
        if (this.listViewRef) {
          this.listViewRef.refresh();
        }
      }
    });
  }

  build() {
    NavDestination() {
      Column() {
        if (this.elder) {
          HealthRecordListView({
            elderId: this.elder.id,
            elderName: this.elder.name,
            showAddButton: true,
            refresher:this.refresher,
            onItemClick: (record: HealthRecordItem) => {
              this.openDetailPage(record);
            },
            onAddClick: () => {
              this.openAddPage();
            }
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f1f5f9')
    }
    .title('健康档案')
    .menus([
      {
        value:"新建",
        symbolIcon:new SymbolGlyphModifier($r('sys.symbol.plus')),
        action:()=>{
          this.openAddPage()
        }
      }
    ])
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack;
      this.elder = ctx.pathInfo.param as ElderBasicInfo;
    })
    .onResult(()=>{
      this.refresher++
      console.log("[MedicalHealthRecordListPage] refresher:" + this.refresher)
    })
    .width('100%')
    .height('100%')
  }
}
