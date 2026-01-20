import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';

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

type HealthRecordType = 'MEDICAL_HISTORY' | 'CHECK_REPORT' | 'MEDICATION' | 'ALLERGY';

interface HealthRecord {
  id: number;
  elder_id: number;
  record_type: HealthRecordType;
  record_title: string;
  record_date: string;
  content_structured: Object;
  created_at?: string;
  updated_at?: string;
}

interface HealthRecordListData {
  items: HealthRecord[];
  total: number;
}

interface PaginationParams {
  page: number;
  pageSize: number;
}

interface ElderIdParams extends PaginationParams {
  elder_id: number;
}

@Component
export struct FamilyArchiveTab {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State elders: UserElderRelationItem[] = [];
  @State selectedElderId: number = -1;
  @State selectedElderName: string = '';
  @State healthRecords: HealthRecord[] = [];
  @State isLoadingElders: boolean = false;
  @State isLoadingRecords: boolean = false;

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
          this.loadHealthRecords();
        }
      }
    } catch (error) {
      console.error('加载老人列表失败:', error);
    } finally {
      this.isLoadingElders = false;
    }
  }

  private async loadHealthRecords(): Promise<void> {
    if (this.selectedElderId < 0) {
      return;
    }

    this.isLoadingRecords = true;
    try {
      const params: ElderIdParams = { elder_id: this.selectedElderId, page: 1, pageSize: 30 };
      const response = await httpRequest<ApiResponse<HealthRecordListData>, ElderIdParams>({
        url: '/api/v1/elder-health/health-record/list',
        method: RequestEnum.GET,
        params: params
      });

      if (response.code === 200 && response.data) {
        this.healthRecords = response.data.items || [];
      }
    } catch (error) {
      console.error('加载健康档案失败:', error);
      promptAction.showToast({ message: '加载健康档案失败' });
    } finally {
      this.isLoadingRecords = false;
    }
  }

  private selectElder(item: UserElderRelationItem): void {
    this.selectedElderId = item.elder_id;
    this.selectedElderName = item.elder.name;
    this.loadHealthRecords();
  }

  private getRecordTypeName(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '病史';
      case 'CHECK_REPORT': return '检查报告';
      case 'MEDICATION': return '用药记录';
      case 'ALLERGY': return '过敏信息';
      default: return '健康档案';
    }
  }

  private getRecordTypeIcon(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '🏥';
      case 'CHECK_REPORT': return '🔬';
      case 'MEDICATION': return '💊';
      case 'ALLERGY': return '⚠️';
      default: return '📋';
    }
  }

  private formatDate(dateStr: string): string {
    const d = new Date(dateStr);
    return d.getFullYear() + '-' +
      String(d.getMonth() + 1).padStart(2, '0') + '-' +
      String(d.getDate()).padStart(2, '0');
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
          .selected(0)
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

  @Builder
  private RecordList() {
    if (this.isLoadingRecords) {
      Column() {
        LoadingProgress().width(32).height(32)
        Text('加载中...').fontSize(13).fontColor('#64748b').margin({ top: 8 })
      }
      .width('100%')
      .height(200)
      .justifyContent(FlexAlign.Center)
    } else if (this.healthRecords.length === 0) {
      Column() {
        Text('📋')
          .fontSize(40)
        Text('暂无健康档案记录')
          .fontSize(14)
          .fontColor('#9ca3af')
          .margin({ top: 12 })
      }
      .width('100%')
      .height(200)
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.healthRecords, (record: HealthRecord) => {
          ListItem() {
            this.RecordItem(record)
          }
        }, (record: HealthRecord) => record.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  private RecordItem(record: HealthRecord) {
    Row() {
      Column() {
        Text(this.getRecordTypeIcon(record.record_type))
          .fontSize(24)
      }
      .width(44)
      .height(44)
      .borderRadius(22)
      .backgroundColor('#f1f5f9')
      .justifyContent(FlexAlign.Center)

      Column() {
        Row() {
          Text(this.getRecordTypeName(record.record_type))
            .fontSize(12)
            .fontColor('#2563eb')
            .backgroundColor('#eff6ff')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(8)
          Text(this.formatDate(record.record_date))
            .fontSize(12)
            .fontColor('#9ca3af')
            .margin({ left: 8 })
        }

        Text(record.record_title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1e293b')
          .margin({ top: 6 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      Text('→')
        .fontSize(16)
        .fontColor('#9ca3af')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 8 })
    .onClick(() => {
      this.navPathStack.pushPath({
        name: 'Family_HealthArchiveDetail',
        param: record
      });
    })
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

      // 档案列表
      this.RecordList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}
