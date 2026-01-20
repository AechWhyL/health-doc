import { HealthRecordType, HealthRecordItem } from '../../models/HealthRecordModels';
import dayjs from 'dayjs';

@CustomDialog
export struct HealthRecordDetailDialog {
  controller?: CustomDialogController
  @Prop record: HealthRecordItem | null = null
  onEdit: () => void = () => {}
  onDelete: () => void = () => {}

  private getRecordTypeLabel(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '病史记录'
      case 'CHECK_REPORT': return '检查报告'
      case 'MEDICATION': return '用药记录'
      case 'ALLERGY': return '过敏记录'
    }
  }

  private getRecordTypeIcon(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '🏥'
      case 'CHECK_REPORT': return '🔬'
      case 'MEDICATION': return '💊'
      case 'ALLERGY': return '⚠️'
    }
  }

  private getRecordTypeColor(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '#1d4ed8'
      case 'CHECK_REPORT': return '#15803d'
      case 'MEDICATION': return '#b91c1c'
      case 'ALLERGY': return '#c2410c'
    }
  }

  private getRecordTypeBgColor(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '#eff6ff'
      case 'CHECK_REPORT': return '#f0fdf4'
      case 'MEDICATION': return '#fef2f2'
      case 'ALLERGY': return '#fff7ed'
    }
  }

  private formatDate(dateStr: string | undefined | null): string {
    if (!dateStr) return '未填写'
    const date = dayjs(dateStr)
    if (!date.isValid()) return '未填写'
    const now = dayjs()

    if (date.isSame(now, 'day')) {
      return '今天'
    }
    if (date.isSame(now.subtract(1, 'day'), 'day')) {
      return '昨天'
    }
    return date.format('YYYY年M月D日')
  }

  private getStatusText(status: string | undefined): string {
    switch (status) {
      case 'ONGOING': return '治疗中'
      case 'REMISSION': return '缓解'
      case 'CURED': return '痊愈'
      default: return status || '未知'
    }
  }

  private getResultSummaryText(result: string | undefined): string {
    switch (result) {
      case 'NORMAL': return '正常'
      case 'MILD_ABNORMAL': return '轻度异常'
      case 'SIGNIFICANT_ABNORMAL': return '显著异常'
      default: return result || '未知'
    }
  }

  private getStringValue(content: Record<string, Object>, key: string): string {
    const value = content[key]
    if (typeof value === 'string' && value.trim() !== '') {
      return value
    }
    return ''
  }

  private getArrayAsString(content: Record<string, Object>, key: string): string {
    const value = content[key]
    if (Array.isArray(value)) {
      return (value as string[]).join('、')
    }
    if (typeof value === 'string') {
      return value
    }
    return ''
  }

  @Builder
  private buildMedicalHistoryContent(content: Record<string, Object>) {
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
  private buildCheckReportContent(content: Record<string, Object>) {
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
  private buildMedicationContent(content: Record<string, Object>) {
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
  private buildAllergyContent(content: Record<string, Object>) {
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
      if (this.getStringValue(content, 'reaction_symptoms')) {
        this.ContentRow('🤒 过敏反应', this.getStringValue(content, 'reaction_symptoms'))
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
        .margin({ bottom: 4 })
      Text(value)
        .fontSize(14)
        .fontColor('#1e293b')
        .wordBreak(WordBreak.BREAK_ALL)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor('#f8fafc')
    .borderRadius(10)
  }

  build() {
    Flex({
      direction:FlexDirection.Column
    }) {
      if (this.record) {
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
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 14 })
        }
        .width('100%')
        .margin({ bottom: 20, top: 40 })

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
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        // Action buttons
        Row({ space: 12 }) {
          Button('编辑')
            .type(ButtonType.Capsule)
            .backgroundColor('#2563eb')
            .fontColor(Color.White)
            .fontSize(14)
            .height(44)
            .layoutWeight(1)
            .onClick(() => {
              this.onEdit()
              if (this.controller) {
                this.controller.close()
              }
            })

          Button('删除')
            .type(ButtonType.Capsule)
            .backgroundColor('#fef2f2')
            .fontColor('#dc2626')
            .fontSize(14)
            .height(44)
            .layoutWeight(1)
            .onClick(() => {
              this.onDelete()
              if (this.controller) {
                this.controller.close()
              }
            })
        }
        .width('100%')
        .margin({ top: 20 })

        // Close button
        Button('关闭')
          .type(ButtonType.Capsule)
          .backgroundColor('#f1f5f9')
          .fontColor('#64748b')
          .fontSize(14)
          .height(44)
          .width('100%')
          .margin({ top: 10 })
          .onClick(() => {
            if (this.controller) {
              this.controller.close()
            }
          })
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(20)
  }
}
