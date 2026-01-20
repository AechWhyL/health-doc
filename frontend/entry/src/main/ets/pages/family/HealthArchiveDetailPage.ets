import { AttachmentPreviewParams } from './AttachmentPreviewPage';

type HealthRecordType = 'MEDICAL_HISTORY' | 'CHECK_REPORT' | 'MEDICATION' | 'ALLERGY';

interface HealthRecordAttachment {
  type: 'IMAGE' | 'FILE';
  url: string;
  name?: string;
}

interface MedicalHistoryContent {
  disease_name: string;
  diagnosed_at: string;
  status: 'ONGOING' | 'REMISSION' | 'CURED';
  notes?: string;
  attachments?: HealthRecordAttachment[];
}

interface CheckReportContent {
  check_date: string;
  hospital_name: string;
  check_item: string;
  result_summary: 'NORMAL' | 'MILD_ABNORMAL' | 'SIGNIFICANT_ABNORMAL';
  notes?: string;
  attachments?: HealthRecordAttachment[];
}

interface MedicationContent {
  drug_name: string[];
  dosage: string;
  frequency: string;
  route: string;
  start_date: string;
  end_date?: string;
  notes?: string;
  prescribing_doctor?: string;
  hospital_name?: string;
  attachments?: HealthRecordAttachment[];
}

interface AllergyContent {
  allergy_item: string;
  reaction_symptoms: string[];
  first_occurrence_date: string;
  last_occurrence_date?: string;
  notes?: string;
  attachments?: HealthRecordAttachment[];
}

type HealthRecordContent = MedicalHistoryContent | CheckReportContent | MedicationContent | AllergyContent;

interface HealthArchiveRecord {
  id: number;
  elder_id: number;
  record_type: HealthRecordType;
  record_title: string;
  record_date: string;
  content_structured: HealthRecordContent;
  created_at?: string;
  updated_at?: string;
}

@Component
export struct HealthArchiveDetailPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State record: HealthArchiveRecord | null = null;

  aboutToAppear(): void {
    const params = this.navPathStack.getParamByName('Family_HealthArchiveDetail') as Object[];
    if (params && params.length > 0) {
      this.record = params[0] as HealthArchiveRecord;
    }
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

  private getStatusText(status: string): string {
    switch (status) {
      case 'ONGOING': return '进行中';
      case 'REMISSION': return '缓解';
      case 'CURED': return '治愈';
      case 'NORMAL': return '正常';
      case 'MILD_ABNORMAL': return '轻度异常';
      case 'SIGNIFICANT_ABNORMAL': return '重度异常';
      default: return status;
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'ONGOING':
      case 'MILD_ABNORMAL':
        return '#f59e0b';
      case 'REMISSION':
      case 'NORMAL':
      case 'CURED':
        return '#16a34a';
      case 'SIGNIFICANT_ABNORMAL':
        return '#dc2626';
      default:
        return '#64748b';
    }
  }

  private formatDate(dateStr: string): string {
    const d = new Date(dateStr);
    return d.getFullYear() + '-' +
      String(d.getMonth() + 1).padStart(2, '0') + '-' +
      String(d.getDate()).padStart(2, '0');
  }

  private openAttachment(attachment: HealthRecordAttachment): void {
    this.navPathStack.pushPath({
      name: 'Family_AttachmentPreview',
      param: {
        url: attachment.url,
        name: attachment.name || '附件预览'
      } as AttachmentPreviewParams
    });
  }

  @Builder
  private InfoRow(label: string, value: string, valueColor?: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#64748b')
        .width(90)
      Text(value)
        .fontSize(14)
        .fontColor(valueColor || '#1e293b')
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }

  @Builder
  private StatusBadge(status: string) {
    Text(this.getStatusText(status))
      .fontSize(12)
      .fontColor(this.getStatusColor(status))
      .backgroundColor(this.getStatusColor(status) + '20')
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .borderRadius(12)
  }

  @Builder
  private SectionTitle(title: string) {
    Text(title)
      .fontSize(15)
      .fontWeight(FontWeight.Medium)
      .fontColor('#374151')
      .margin({ top: 20, bottom: 12 })
  }

  @Builder
  private AttachmentList(attachments: HealthRecordAttachment[]) {
    if (attachments && attachments.length > 0) {
      this.SectionTitle('附件')
      ForEach(attachments, (attachment: HealthRecordAttachment) => {
        Row() {
          Text(attachment.type === 'IMAGE' ? '🖼️' : '📄')
            .fontSize(20)
          Text(attachment.name || '附件')
            .fontSize(14)
            .fontColor('#1e293b')
            .layoutWeight(1)
            .margin({ left: 10 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text('查看 →')
            .fontSize(13)
            .fontColor('#2563eb')
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#f8fafc')
        .borderRadius(10)
        .margin({ bottom: 8 })
        .onClick(() => {
          this.openAttachment(attachment);
        })
      }, (item: HealthRecordAttachment, index: number) => index.toString())
    }
  }

  @Builder
  private MedicalHistoryDetail(content: MedicalHistoryContent) {
    Column() {
      this.InfoRow('疾病名称', content.disease_name)
      this.InfoRow('确诊日期', this.formatDate(content.diagnosed_at))
      Row() {
        Text('状态')
          .fontSize(14)
          .fontColor('#64748b')
          .width(90)
        this.StatusBadge(content.status)
      }
      .width('100%')
      .padding({ top: 10, bottom: 10 })

      if (content.notes) {
        this.InfoRow('备注', content.notes)
      }
      if (content.attachments) {
        this.AttachmentList(content.attachments)
      }
    }
  }

  @Builder
  private CheckReportDetail(content: CheckReportContent) {
    Column() {
      this.InfoRow('检查日期', this.formatDate(content.check_date))
      this.InfoRow('检查医院', content.hospital_name)
      this.InfoRow('检查项目', content.check_item)
      Row() {
        Text('结论')
          .fontSize(14)
          .fontColor('#64748b')
          .width(90)
        this.StatusBadge(content.result_summary)
      }
      .width('100%')
      .padding({ top: 10, bottom: 10 })

      if (content.notes) {
        this.InfoRow('备注', content.notes)
      }
      if (content.attachments) {
        this.AttachmentList(content.attachments)
      }
    }
  }

  @Builder
  private MedicationDetail(content: MedicationContent) {
    Column() {
      this.InfoRow('药品名称', content.drug_name.join('、'))
      this.InfoRow('剂量', content.dosage)
      this.InfoRow('频次', content.frequency)
      this.InfoRow('给药途径', content.route)
      this.InfoRow('开始日期', this.formatDate(content.start_date))
      if (content.end_date) {
        this.InfoRow('结束日期', this.formatDate(content.end_date))
      }
      if (content.prescribing_doctor) {
        this.InfoRow('开药医生', content.prescribing_doctor)
      }
      if (content.hospital_name) {
        this.InfoRow('开药医院', content.hospital_name)
      }
      if (content.notes) {
        this.InfoRow('备注', content.notes)
      }
      if (content.attachments) {
        this.AttachmentList(content.attachments)
      }
    }
  }

  @Builder
  private AllergyDetail(content: AllergyContent) {
    Column() {
      this.InfoRow('过敏源', content.allergy_item)
      this.InfoRow('反应症状', content.reaction_symptoms.join('、'))
      this.InfoRow('首次发生', this.formatDate(content.first_occurrence_date))
      if (content.last_occurrence_date) {
        this.InfoRow('最近发生', this.formatDate(content.last_occurrence_date))
      }
      if (content.notes) {
        this.InfoRow('备注', content.notes)
      }
      if (content.attachments) {
        this.AttachmentList(content.attachments)
      }
    }
  }

  @Builder
  private ContentDetail() {
    if (this.record) {
      if (this.record.record_type === 'MEDICAL_HISTORY') {
        this.MedicalHistoryDetail(this.record.content_structured as MedicalHistoryContent)
      } else if (this.record.record_type === 'CHECK_REPORT') {
        this.CheckReportDetail(this.record.content_structured as CheckReportContent)
      } else if (this.record.record_type === 'MEDICATION') {
        this.MedicationDetail(this.record.content_structured as MedicationContent)
      } else if (this.record.record_type === 'ALLERGY') {
        this.AllergyDetail(this.record.content_structured as AllergyContent)
      }
    }
  }

  build() {
    NavDestination() {
      if (this.record) {
        Scroll() {
          Column() {
            // 标题卡片
            Column() {
              Row() {
                Column() {
                  Text(this.getRecordTypeIcon(this.record.record_type))
                    .fontSize(28)
                }
                .width(56)
                .height(56)
                .borderRadius(28)
                .backgroundColor('#f1f5f9')
                .justifyContent(FlexAlign.Center)

                Column() {
                  Text(this.getRecordTypeName(this.record.record_type))
                    .fontSize(12)
                    .fontColor('#2563eb')
                    .backgroundColor('#eff6ff')
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(8)
                  Text(this.record.record_title)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1e293b')
                    .margin({ top: 6 })
                  Text('记录日期：' + this.formatDate(this.record.record_date))
                    .fontSize(13)
                    .fontColor('#64748b')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 14 })
              }
              .width('100%')
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 6, color: '#0f172a0a', offsetY: 2 })

            // 详细内容卡片
            Column() {
              this.SectionTitle('详细信息')
              this.ContentDetail()
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 6, color: '#0f172a0a', offsetY: 2 })
            .margin({ top: 16 })
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 30 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#f1f5f9')
        .scrollBar(BarState.Off)
      } else {
        Column() {
          Text('📋')
            .fontSize(48)
          Text('无法加载档案详情')
            .fontSize(16)
            .fontColor('#64748b')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#f1f5f9')
      }
    }
    .title('档案详情')
    .backgroundColor('#f1f5f9')
  }
}

@Builder
export function HealthArchiveDetailPageBuilder() {
  HealthArchiveDetailPage()
}
