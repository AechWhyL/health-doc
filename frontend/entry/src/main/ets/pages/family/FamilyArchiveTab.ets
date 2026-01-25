import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';
import { HealthRecordListView } from '../../components/health_record/HealthRecordListView';
import {
  HealthRecordItem,
  AddHealthRecordParams
} from '../../models/HealthArchiveModels';

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
export struct FamilyArchiveTab {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State elders: UserElderRelationItem[] = [];
  @State selectedElderId: number = -1;
  @State selectedElderName: string = '';
  @State isLoadingElders: boolean = false;
  @State refreshKey: number = 0; // 用于触发列表刷新

  aboutToAppear(): void {
    this.loadElders();
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
          this.selectedElderId = this.elders[0].elder_id;
          this.selectedElderName = this.elders[0].elder.name;
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

  private handleItemClick(record: HealthRecordItem): void {
    this.navPathStack.pushPath({
      name: 'Family_HealthArchiveDetail',
      param: record
    });
  }

  private handleAddClick(): void {
    if (this.selectedElderId <= 0) return;

    const params: AddHealthRecordParams = {
      elderId: this.selectedElderId,
      elderName: this.selectedElderName,
      mode: 'create'
    };

    this.navPathStack.pushPath({
      name: 'Common_AddHealthRecord',
      param: params,
      onPop: () => {
        // 页面返回时刷新列表
        this.refreshKey++;
      }
    });
  }

  @Builder
  private ElderSelector() {
    Row() {
      Text('选择老人:')
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
          Text('健康档案')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e293b')
          Text('查看老人病史、检查报告、用药记录等')
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

      // 档案列表 (使用新组件)
      if (this.selectedElderId > 0) {
        HealthRecordListView({
          elderId: this.selectedElderId,
          elderName: this.selectedElderName,
          showAddButton: true,
          onItemClick: (record: HealthRecordItem) => {
            this.handleItemClick(record);
          },
          onAddClick: () => {
            this.handleAddClick();
          }
        })
      } else {
        Column() {
          Text('请选择老人查看档案')
            .fontSize(14)
            .fontColor('#9ca3af')
            .margin({ top: 50 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}
