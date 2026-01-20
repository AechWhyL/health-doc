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
  birth_date: string;
  phone: string;
  address: string | null;
  emergency_contact: string;
  height: number | null;
  weight: number | null;
  blood_type: string | null;
  age: number;
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

interface ElderIdParams {
  elder_id: number;
  page: number;
  pageSize: number;
}

@Component
export struct FamilyElderArchive {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State elder: ElderResponse | null = null;
  @State healthRecords: HealthRecord[] = [];
  @State isLoadingRecords: boolean = false;

  aboutToAppear(): void {
    const param: Object[] = this.navPathStack.getParamByName('Family_ElderArchive') as Object[];
    if (param && param.length > 0) {
      this.elder = param[0] as ElderResponse;
      this.loadHealthRecords();
    }
  }

  private async loadHealthRecords(): Promise<void> {
    if (!this.elder) {
      return;
    }
    this.isLoadingRecords = true;

    try {
      const params: ElderIdParams = { elder_id: this.elder.id, page: 1, pageSize: 20 };
      const response = await httpRequest<ApiResponse<HealthRecordListData>, ElderIdParams>({
        url: '/api/v1/elder-health/health-record/list',
        method: RequestEnum.GET,
        params: params
      });

      if (response.code === 200 && response.data) {
        this.healthRecords = response.data.items || [];
      }
    } catch (error) {
      console.error('加载健康记录失败:', error);
      promptAction.showToast({ message: '加载健康记录失败' });
    } finally {
      this.isLoadingRecords = false;
    }
  }

  private getGenderText(gender: number): string {
    return gender === 1 ? '男' : '女';
  }

  private formatDate(dateStr: string): string {
    const d = new Date(dateStr);
    return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
  }

  private getRecordTypeText(type: string): string {
    switch (type) {
      case 'VISIT':
        return '就诊记录';
      case 'EXAMINATION':
        return '检查报告';
      case 'HOSPITALIZATION':
        return '住院记录';
      case 'SURGERY':
        return '手术记录';
      case 'FOLLOW_UP':
        return '随访记录';
      default:
        return '其他记录';
    }
  }

  private getRecordTypeIcon(type: string): string {
    switch (type) {
      case 'VISIT':
        return '🏥';
      case 'EXAMINATION':
        return '🔬';
      case 'HOSPITALIZATION':
        return '🛏️';
      case 'SURGERY':
        return '⚕️';
      case 'FOLLOW_UP':
        return '📋';
      default:
        return '📄';
    }
  }

  @Builder
  private ElderBasicInfo() {
    if (this.elder) {
      Column() {
        Row() {
          Column() {
            Text(this.elder.gender === 1 ? '👴' : '👵')
              .fontSize(40)
          }
          .width(72)
          .height(72)
          .borderRadius(36)
          .backgroundColor('#f1f5f9')
          .justifyContent(FlexAlign.Center)

          Column() {
            Text(this.elder.name)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1e293b')
            Text(this.getGenderText(this.elder.gender) + ' · ' + this.elder.age + '岁')
              .fontSize(14)
              .fontColor('#64748b')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 })
        }
        .width('100%')

        // 详细信息
        Column() {
          this.InfoRow('📱', '电话', this.elder.phone)
          this.InfoRow('📍', '地址', this.elder.address || '未填写')
          this.InfoRow('🆘', '紧急联系人', this.elder.emergency_contact || '未填写')
          if (this.elder.blood_type) {
            this.InfoRow('🩸', '血型', this.elder.blood_type)
          }
          if (this.elder.height) {
            this.InfoRow('📏', '身高', this.elder.height + ' cm')
          }
          if (this.elder.weight) {
            this.InfoRow('⚖️', '体重', this.elder.weight + ' kg')
          }
        }
        .margin({ top: 20 })
        .padding(16)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
        .width('100%')
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 6, color: '#0f172a0a', offsetY: 2 })
    }
  }

  @Builder
  private InfoRow(icon: string, label: string, value: string) {
    Row() {
      Text(icon + ' ' + label)
        .fontSize(13)
        .fontColor('#64748b')
        .width(110)
      Text(value)
        .fontSize(14)
        .fontColor('#1e293b')
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  private HealthRecordSection() {
    Column() {
      Text('健康记录')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1e293b')
        .margin({ bottom: 12 })

      if (this.isLoadingRecords) {
        Row() {
          LoadingProgress().width(24).height(24)
          Text('加载中...').fontSize(13).fontColor('#64748b').margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding(20)
      } else if (this.healthRecords.length === 0) {
        Column() {
          Text('📋')
            .fontSize(36)
          Text('暂无健康记录')
            .fontSize(14)
            .fontColor('#9ca3af')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(30)
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(this.healthRecords, (record: HealthRecord) => {
          this.RecordItem(record)
        }, (record: HealthRecord) => record.id.toString())
      }
    }
    .width('100%')
    .margin({ top: 16 })
  }

  @Builder
  private RecordItem(record: HealthRecord) {
    Column() {
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
            Text(this.getRecordTypeText(record.record_type))
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
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(14)
    .shadow({ radius: 4, color: '#0f172a08', offsetY: 1 })
    .margin({ bottom: 10 })
    .onClick(() => {
      this.navPathStack.pushPath({
        name: 'Family_HealthArchiveDetail',
        param: record
      });
    })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // 基本信息卡片
          this.ElderBasicInfo()

          // 健康记录列表
          this.HealthRecordSection()
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 30 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f1f5f9')
      .scrollBar(BarState.Off)
    }
    .title('老人档案')
    .backgroundColor('#f1f5f9')
  }
}

@Builder
export function FamilyElderArchiveBuilder() {
  FamilyElderArchive()
}
