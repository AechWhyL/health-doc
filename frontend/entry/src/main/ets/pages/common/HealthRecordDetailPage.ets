import { HealthRecordType, HealthRecordItem, AddHealthRecordParams, HealthRecordDetailParams } from '../../models/HealthArchiveModels';
import dayjs from 'dayjs';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

@Builder
export function HealthRecordDetailPageBuilder() {
  HealthRecordDetailPage()
}

@ComponentV2
export struct HealthRecordDetailPage {
  @Local private params: HealthRecordDetailParams = {
    recordId: 0,
    mode: 'readonly'
  };

  @Local private record: HealthRecordItem | null = null;
  @Local private isLoading: boolean = true;
  @Local private loadError: string = '';

  private navPathStack: NavPathStack = new NavPathStack();

  // 加载档案详情
  private async loadRecordDetail(): Promise<void> {
    this.isLoading = true;
    this.loadError = '';

    try {
      const response = await httpRequest<ApiResponse<HealthRecordItem>, null>({
        url: '/api/v1/elder-health/health-record/' + this.params.recordId.toString(),
        method: RequestEnum.GET,
        token: 'auth'
      });

      if (response.code !== 200) {
        this.loadError = response.message || '加载档案详情失败';
        this.isLoading = false;
        return;
      }

      this.record = response.data || null;
      this.isLoading = false;
    } catch (_error) {
      this.loadError = '网络异常,加载档案详情失败';
      this.isLoading = false;
    }
  }

  private getRecordTypeLabel(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '病史记录';
      case 'CHECK_REPORT': return '检查报告';
      case 'MEDICATION': return '用药记录';
      case 'ALLERGY': return '过敏记录';
    }
  }

  private getRecordTypeIcon(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '🏥';
      case 'CHECK_REPORT': return '🔬';
      case 'MEDICATION': return '💊';
      case 'ALLERGY': return '⚠️';
    }
  }

  private getRecordTypeColor(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '#1d4ed8';
      case 'CHECK_REPORT': return '#15803d';
      case 'MEDICATION': return '#b91c1c';
      case 'ALLERGY': return '#c2410c';
    }
  }

  private getRecordTypeBgColor(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '#eff6ff';
      case 'CHECK_REPORT': return '#f0fdf4';
      case 'MEDICATION': return '#fef2f2';
      case 'ALLERGY': return '#fff7ed';
    }
  }

  private formatDate(dateStr: string | undefined | null): string {
    if (!dateStr) return '未填写';
    const date = dayjs(dateStr);
    if (!date.isValid()) return '未填写';
    const now = dayjs();

    if (date.isSame(now, 'day')) {
      return '今天';
    }
    if (date.isSame(now.subtract(1, 'day'), 'day')) {
      return '昨天';
    }
    return date.format('YYYY年M月D日');
  }

  private getStatusText(status: string | undefined): string {
    switch (status) {
      case 'ONGOING': return '治疗中';
      case 'REMISSION': return '缓解';
      case 'CURED': return '痊愈';
      default: return status || '未知';
    }
  }

  private getResultSummaryText(result: string | undefined): string {
    switch (result) {
      case 'NORMAL': return '正常';
      case 'MILD_ABNORMAL': return '轻度异常';
      case 'SIGNIFICANT_ABNORMAL': return '显著异常';
      default: return result || '未知';
    }
  }

  private getStringValue(content: Object, key: string): string {
    const record = content as Record<string, Object>;
    const value = record[key];
    if (typeof value === 'string' && value.trim() !== '') {
      return value;
    }
    return '';
  }

  private getArrayAsString(content: Object, key: string): string {
    const record = content as Record<string, Object>;
    const value = record[key];
    if (Array.isArray(value)) {
      return (value as string[]).join('、');
    }
    if (typeof value === 'string') {
      return value;
    }
    return '';
  }

  private handleEdit(): void {
    if (!this.record) return;

    const editParams: AddHealthRecordParams = {
      elderId: this.record.elder_id,
      elderName: this.params.elderName || '',
      mode: 'edit',
      editRecord: this.record,
      recordType: this.record.record_type
    };

    this.navPathStack.pushPath({
      name: 'Common_AddHealthRecord',
      param: editParams
    });
  }

  private async handleDelete(): Promise<void> {
    if (!this.record) return;

    try {
      const response = await httpRequest<ApiResponse<Object>, null>({
        url: '/api/v1/elder-health/health-record/' + this.record.id.toString(),
        method: RequestEnum.DELETE,
        token: 'auth'
      });

      if (response.code !== 200) {
        const msg = response.message || '删除健康记录失败';
        this.getUIContext().getPromptAction().showToast({ message: msg });
        return;
      }

      this.getUIContext().getPromptAction().showToast({ message: '删除健康记录成功' });
      this.navPathStack.pop(true);
    } catch (_error) {
      this.getUIContext().getPromptAction().showToast({ message: '网络异常,删除健康记录失败' });
    }
  }

  @Builder
  private buildMedicalHistoryContent(content: Object) {
    Column({ space: 12 }) {
      if (this.getStringValue(content, 'disease_name')) {
        this.ContentRow('🏷️ 疾病名称', this.getStringValue(content, 'disease_name'))
      }
      if (this.getStringValue(content, 'diagnosed_at')) {
        this.ContentRow('📅 确诊日期', this.formatDate(this.getStringValue(content, 'diagnosed_at')))
      }
      if (this.getStringValue(content, 'status')) {
        this.ContentRow('📊 当前状态', this.getStatusText(this.getStringValue(content, 'status')))
      }
      if (this.getStringValue(content, 'notes')) {
        this.ContentRow('📝 备注说明', this.getStringValue(content, 'notes'))
      }
    }
    .width('100%')
  }

  @Builder
  private buildCheckReportContent(content: Object) {
    Column({ space: 12 }) {
      if (this.getStringValue(content, 'check_date')) {
        this.ContentRow('📅 检查日期', this.formatDate(this.getStringValue(content, 'check_date')))
      }
      if (this.getStringValue(content, 'hospital_name')) {
        this.ContentRow('🏥 检查医院', this.getStringValue(content, 'hospital_name'))
      }
      if (this.getStringValue(content, 'check_item')) {
        this.ContentRow('🔍 检查项目', this.getStringValue(content, 'check_item'))
      }
      if (this.getStringValue(content, 'result_summary')) {
        this.ContentRow('📋 检查结果', this.getResultSummaryText(this.getStringValue(content, 'result_summary')))
      }
      if (this.getStringValue(content, 'notes')) {
        this.ContentRow('📝 结论/建议', this.getStringValue(content, 'notes'))
      }
    }
    .width('100%')
  }

  @Builder
  private buildMedicationContent(content: Object) {
    Column({ space: 12 }) {
      if (this.getArrayAsString(content, 'drug_name')) {
        this.ContentRow('💊 药品名称', this.getArrayAsString(content, 'drug_name'))
      }
      if (this.getStringValue(content, 'dosage')) {
        this.ContentRow('📏 单次剂量', this.getStringValue(content, 'dosage'))
      }
      if (this.getStringValue(content, 'frequency')) {
        this.ContentRow('🔄 用药频次', this.getStringValue(content, 'frequency'))
      }
      if (this.getStringValue(content, 'route')) {
        this.ContentRow('💉 给药途径', this.getStringValue(content, 'route'))
      }
      if (this.getStringValue(content, 'start_date')) {
        this.ContentRow('📅 开始日期', this.formatDate(this.getStringValue(content, 'start_date')))
      }
      if (this.getStringValue(content, 'end_date')) {
        this.ContentRow('📅 结束日期', this.formatDate(this.getStringValue(content, 'end_date')))
      }
      if (this.getStringValue(content, 'prescribing_doctor')) {
        this.ContentRow('👨‍⚕️ 开方医生', this.getStringValue(content, 'prescribing_doctor'))
      }
      if (this.getStringValue(content, 'hospital_name')) {
        this.ContentRow('🏥 就诊医院', this.getStringValue(content, 'hospital_name'))
      }
      if (this.getStringValue(content, 'notes')) {
        this.ContentRow('📝 用药备注', this.getStringValue(content, 'notes'))
      }
    }
    .width('100%')
  }

  @Builder
  private buildAllergyContent(content: Object) {
    Column({ space: 12 }) {
      if (this.getStringValue(content, 'allergy_item')) {
        this.ContentRow('🚫 过敏源', this.getStringValue(content, 'allergy_item'))
      }
      if (this.getStringValue(content, 'first_occurrence_date')) {
        this.ContentRow('📅 首次发生', this.formatDate(this.getStringValue(content, 'first_occurrence_date')))
      }
      if (this.getStringValue(content, 'last_occurrence_date')) {
        this.ContentRow('📅 最近发生', this.formatDate(this.getStringValue(content, 'last_occurrence_date')))
      }
      if (this.getArrayAsString(content, 'reaction_symptoms')) {
        this.ContentRow('🤒 过敏反应', this.getArrayAsString(content, 'reaction_symptoms'))
      }
      if (this.getStringValue(content, 'notes')) {
        this.ContentRow('📝 备注说明', this.getStringValue(content, 'notes'))
      }
    }
    .width('100%')
  }

  @Builder
  private ContentRow(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor('#64748b')
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 6 })
      Text(value)
        .fontSize(14)
        .fontColor('#1e293b')
        .wordBreak(WordBreak.BREAK_ALL)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .border({
      width: 1,
      color: '#e2e8f0'
    })
    .shadow({
      radius: 2,
      color: '#0f172a08',
      offsetY: 1
    })
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isLoading) {
          // 加载状态
          Column() {
            LoadingProgress()
              .width(48)
              .height(48)
              .color('#2563eb')
            Text('加载中...')
              .fontSize(14)
              .fontColor('#64748b')
              .margin({ top: 12 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#f8fafc')
        } else if (this.loadError) {
          // 错误状态
          Column() {
            Text('😕')
              .fontSize(48)
            Text(this.loadError)
              .fontSize(14)
              .fontColor('#64748b')
              .margin({ top: 12 })
            Button('重新加载')
              .type(ButtonType.Capsule)
              .backgroundColor('#2563eb')
              .fontColor(Color.White)
              .fontSize(14)
              .height(40)
              .margin({ top: 20 })
              .onClick(() => {
                this.loadRecordDetail();
              })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#f8fafc')
        } else if (this.record) {
          // 正常内容
          Column() {
            // Header
            Row() {
              Column() {
                Text(this.getRecordTypeIcon(this.record.record_type))
                  .fontSize(24)
              }
              .width(48)
              .height(48)
              .borderRadius(24)
              .backgroundColor(this.getRecordTypeBgColor(this.record.record_type))
              .justifyContent(FlexAlign.Center)

              Column() {
                Text(this.record.record_title)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1e293b')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Row({ space: 8 }) {
                  Text(this.getRecordTypeLabel(this.record.record_type))
                    .fontSize(12)
                    .fontColor(this.getRecordTypeColor(this.record.record_type))
                    .backgroundColor(this.getRecordTypeBgColor(this.record.record_type))
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(8)

                  Text(this.formatDate(this.record.record_date))
                    .fontSize(12)
                    .fontColor('#64748b')
                }
                .margin({ top: 6 })

                if (this.record.creator_name) {
                  Text('创建人: ' + this.record.creator_name)
                    .fontSize(12)
                    .fontColor('#64748b')
                    .margin({ top: 4 })
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 14 })
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)

            // Content
            Scroll() {
              Column() {
                if (this.record.record_type === 'MEDICAL_HISTORY') {
                  this.buildMedicalHistoryContent(this.record.content_structured)
                } else if (this.record.record_type === 'CHECK_REPORT') {
                  this.buildCheckReportContent(this.record.content_structured)
                } else if (this.record.record_type === 'MEDICATION') {
                  this.buildMedicationContent(this.record.content_structured)
                } else if (this.record.record_type === 'ALLERGY') {
                  this.buildAllergyContent(this.record.content_structured)
                }
              }
              .padding(20)
              .constraintSize({
                minHeight:"100%"
              })
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
            .backgroundColor('#f8fafc')

            // Action buttons (only in editable mode)
            if (this.params.mode === 'editable') {
              Column() {
                Row({ space: 12 }) {
                  Button('编辑')
                    .type(ButtonType.Capsule)
                    .backgroundColor('#2563eb')
                    .fontColor(Color.White)
                    .fontSize(14)
                    .height(44)
                    .layoutWeight(1)
                    .onClick(() => {
                      this.handleEdit();
                    })

                  Button('删除')
                    .type(ButtonType.Capsule)
                    .backgroundColor('#fef2f2')
                    .fontColor('#dc2626')
                    .fontSize(14)
                    .height(44)
                    .layoutWeight(1)
                    .onClick(() => {
                      this.handleDelete();
                    })
                }
                .width('100%')
              }
              .width('100%')
              .padding({ left: 20, right: 20, top: 12, bottom: 20 })
              .backgroundColor(Color.White)
            }
          }
          .width('100%')
          .height('100%')
        }
      }
      .width('100%')
      .height('100%')
    }
    .title('档案详情')
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack;
      this.params = ctx.pathInfo.param as HealthRecordDetailParams;
      this.loadRecordDetail();
    })
    .onResult(()=>{
      this.loadRecordDetail();
    })
    .width('100%')
    .height('100%')
  }
}
