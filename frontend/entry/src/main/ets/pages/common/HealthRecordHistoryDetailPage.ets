import { HealthRecordHistory, HealthRecordItem, HealthRecordHistoryDetailParams, HealthRecordType,
  HealthRecordContent } from '../../models/HealthArchiveModels';
import dayjs from 'dayjs';

@Builder
export function HealthRecordHistoryDetailPageBuilder() {
  HealthRecordHistoryDetailPage()
}

export interface HealthRecordHistoryDetailPageParams{
  history:HealthRecordHistory
}

@ComponentV2
export struct HealthRecordHistoryDetailPage {
  @Local private history: HealthRecordHistory | null = null;
  @Local private currentTab: number = 1; // 0: Before, 1: After
  private navPathStack: NavPathStack = new NavPathStack();

  private formatDate(dateStr: string | undefined | null): string {
    if (!dateStr) return '未填写';
    const date = dayjs(dateStr);
    if (!date.isValid()) return '未填写';
    return date.format('YYYY年M月D日');
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

  private getFieldBorderColor(key: string): string {
    if (!this.history || !this.history.snapshot_after) {
      return '#e2e8f0';
    }

    // New record (ADD) - no special highlighting needed based on description "modified tab... modified row blue, new row green"
    // "modified tab" implies MODIFY operation. For ADD operation, maybe everything is effectively "new", but instructions focus on MODIFY.
    // Let's assume this logic primarily applies when operation_type is MODIFY.
    if (this.history.operation_type !== 'MODIFY') {
       return '#e2e8f0';
    }

    const before:HealthRecordContent|object = this.history.snapshot_before ? this.history.snapshot_before.content_structured: {};
    const after:HealthRecordContent|object = this.history.snapshot_after.content_structured;

    const valBefore = Reflect.get(before,key) as string;
    const valAfter = Reflect.get(after,key) as string;

    // Helper to check if value 'exists' / is not empty
    const hasValue = (v: Object | undefined | null): boolean => {
      if (v === undefined || v === null) return false;
      if (typeof v === 'string') return v.trim() !== '';
      if (Array.isArray(v)) return v.length > 0;
      return true; // Numbers etc
    };

    const hasBefore = hasValue(valBefore);
    const hasAfter = hasValue(valAfter);
    
    // Compare values for modification
    // deep comparison might be needed for arrays, but simple JSON.stringify is usually enough for these simple structures
    const isModified = hasBefore && hasAfter && JSON.stringify(valBefore) !== JSON.stringify(valAfter);

    if (this.currentTab === 1) { 
      // 修改后 (After Tab)
      // "属于'修改'的行的边框高亮为蓝色"
      if (isModified) {
        return '#2563eb'; // Blue
      }
      // "属于'从空到有'的字段的行的边框高亮为绿色"
      if (!hasBefore && hasAfter) {
        return '#16a34a'; // Green
      }
    } else {
      // 修改前 (Before Tab)
      // "属于'从非空到空'的行高亮为红色"
      if (hasBefore && !hasAfter) {
        return '#dc2626'; // Red
      }
    }

    return '#e2e8f0'; // Default gray
  }

  @Builder
  private ContentRow(label: string, value: string, borderColor: string = '#e2e8f0') {
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
      color: borderColor
    })
  }

  @Builder
  private buildMedicalHistoryContent(content: Object) {
    Column({ space: 12 }) {
      if (this.getStringValue(content, 'disease_name')) {
        this.ContentRow('🏷️ 疾病名称', this.getStringValue(content, 'disease_name'), this.getFieldBorderColor('disease_name'))
      }
      if (this.getStringValue(content, 'diagnosed_at')) {
        this.ContentRow('📅 确诊日期', this.formatDate(this.getStringValue(content, 'diagnosed_at')), this.getFieldBorderColor('diagnosed_at'))
      }
      if (this.getStringValue(content, 'status')) {
        this.ContentRow('📊 当前状态', this.getStatusText(this.getStringValue(content, 'status')), this.getFieldBorderColor('status'))
      }
      if (this.getStringValue(content, 'notes')) {
        this.ContentRow('📝 备注说明', this.getStringValue(content, 'notes'), this.getFieldBorderColor('notes'))
      }
    }
    .width('100%')
  }

  @Builder
  private buildCheckReportContent(content: Object) {
    Column({ space: 12 }) {
      if (this.getStringValue(content, 'check_date')) {
        this.ContentRow('📅 检查日期', this.formatDate(this.getStringValue(content, 'check_date')), this.getFieldBorderColor('check_date'))
      }
      if (this.getStringValue(content, 'hospital_name')) {
        this.ContentRow('🏥 检查医院', this.getStringValue(content, 'hospital_name'), this.getFieldBorderColor('hospital_name'))
      }
      if (this.getStringValue(content, 'check_item')) {
        this.ContentRow('🔍 检查项目', this.getStringValue(content, 'check_item'), this.getFieldBorderColor('check_item'))
      }
      if (this.getStringValue(content, 'result_summary')) {
        this.ContentRow('📋 检查结果', this.getResultSummaryText(this.getStringValue(content, 'result_summary')), this.getFieldBorderColor('result_summary'))
      }
      if (this.getStringValue(content, 'notes')) {
        this.ContentRow('📝 结论/建议', this.getStringValue(content, 'notes'), this.getFieldBorderColor('notes'))
      }
    }
    .width('100%')
  }

  @Builder
  private buildMedicationContent(content: Object) {
    Column({ space: 12 }) {
      if (this.getArrayAsString(content, 'drug_name')) {
        this.ContentRow('💊 药品名称', this.getArrayAsString(content, 'drug_name'), this.getFieldBorderColor('drug_name'))
      }
      if (this.getStringValue(content, 'dosage')) {
        this.ContentRow('📏 单次剂量', this.getStringValue(content, 'dosage'), this.getFieldBorderColor('dosage'))
      }
      if (this.getStringValue(content, 'frequency')) {
        this.ContentRow('🔄 用药频次', this.getStringValue(content, 'frequency'), this.getFieldBorderColor('frequency'))
      }
      if (this.getStringValue(content, 'route')) {
        this.ContentRow('💉 给药途径', this.getStringValue(content, 'route'), this.getFieldBorderColor('route'))
      }
      if (this.getStringValue(content, 'start_date')) {
        this.ContentRow('📅 开始日期', this.formatDate(this.getStringValue(content, 'start_date')), this.getFieldBorderColor('start_date'))
      }
      if (this.getStringValue(content, 'end_date')) {
        this.ContentRow('📅 结束日期', this.formatDate(this.getStringValue(content, 'end_date')), this.getFieldBorderColor('end_date'))
      }
      if (this.getStringValue(content, 'prescribing_doctor')) {
        this.ContentRow('👨‍⚕️ 开方医生', this.getStringValue(content, 'prescribing_doctor'), this.getFieldBorderColor('prescribing_doctor'))
      }
      if (this.getStringValue(content, 'hospital_name')) {
        this.ContentRow('🏥 就诊医院', this.getStringValue(content, 'hospital_name'), this.getFieldBorderColor('hospital_name'))
      }
      if (this.getStringValue(content, 'notes')) {
        this.ContentRow('📝 用药备注', this.getStringValue(content, 'notes'), this.getFieldBorderColor('notes'))
      }
    }
    .width('100%')
  }

  @Builder
  private buildAllergyContent(content: Object) {
    Column({ space: 12 }) {
      if (this.getStringValue(content, 'allergy_item')) {
        this.ContentRow('🚫 过敏源', this.getStringValue(content, 'allergy_item'), this.getFieldBorderColor('allergy_item'))
      }
      if (this.getStringValue(content, 'first_occurrence_date')) {
        this.ContentRow('📅 首次发生', this.formatDate(this.getStringValue(content, 'first_occurrence_date')), this.getFieldBorderColor('first_occurrence_date'))
      }
      if (this.getStringValue(content, 'last_occurrence_date')) {
        this.ContentRow('📅 最近发生', this.formatDate(this.getStringValue(content, 'last_occurrence_date')), this.getFieldBorderColor('last_occurrence_date'))
      }
      if (this.getArrayAsString(content, 'reaction_symptoms')) {
        this.ContentRow('🤒 过敏反应', this.getArrayAsString(content, 'reaction_symptoms'), this.getFieldBorderColor('reaction_symptoms'))
      }
      if (this.getStringValue(content, 'notes')) {
        this.ContentRow('📝 备注说明', this.getStringValue(content, 'notes'), this.getFieldBorderColor('notes'))
      }
    }
    .width('100%')
  }

  @Builder
  private buildRecordView(record: HealthRecordItem) {
    Column() {
        // Header
        Row() {
            Column() {
            Text(this.getRecordTypeIcon(record.record_type))
                .fontSize(24)
            }
            .width(48)
            .height(48)
            .borderRadius(24)
            .backgroundColor(this.getRecordTypeBgColor(record.record_type))
            .justifyContent(FlexAlign.Center)
 
            Column() {
            Text(record.record_title)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1e293b')
            
            Row({ space: 8 }) {
                Text(this.getRecordTypeLabel(record.record_type))
                .fontSize(12)
                .fontColor(this.getRecordTypeColor(record.record_type))
                .backgroundColor(this.getRecordTypeBgColor(record.record_type))
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(8)
 
                Text(this.formatDate(record.record_date))
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
        .padding(20)
        .backgroundColor(Color.White)
        .margin({ bottom: 12 })
        .borderRadius(12)
 
        // Content
        Column() {
            if (record.record_type === 'MEDICAL_HISTORY') {
            this.buildMedicalHistoryContent(record.content_structured)
            } else if (record.record_type === 'CHECK_REPORT') {
            this.buildCheckReportContent(record.content_structured)
            } else if (record.record_type === 'MEDICATION') {
            this.buildMedicationContent(record.content_structured)
            } else if (record.record_type === 'ALLERGY') {
            this.buildAllergyContent(record.content_structured)
            }
        }
        .width('100%')
        .padding(12)
    }
    .width('100%')
  }

  build() {
    NavDestination() {
      Column() {
        if (!this.history) {
            // Empty state or loading
        } else {
             if (this.history.operation_type === 'MODIFY') {
                 Row() {
                     Column() {
                         Text('修改前')
                             .fontSize(14)
                             .fontWeight(this.currentTab === 0 ? FontWeight.Bold : FontWeight.Normal)
                             .fontColor(this.currentTab === 0 ? '#2563eb' : '#64748b')
                         Divider()
                             .strokeWidth(2)
                             .color(this.currentTab === 0 ? '#2563eb' : Color.Transparent)
                             .margin({ top: 8 })
                             .width(20)
                     }
                     .layoutWeight(1)
                     .alignItems(HorizontalAlign.Center)
                     .onClick(() => this.currentTab = 0)
 
                     Column() {
                        Text('修改后')
                            .fontSize(14)
                            .fontWeight(this.currentTab === 1 ? FontWeight.Bold : FontWeight.Normal)
                            .fontColor(this.currentTab === 1 ? '#2563eb' : '#64748b')
                        Divider()
                            .strokeWidth(2)
                            .color(this.currentTab === 1 ? '#2563eb' : Color.Transparent)
                            .margin({ top: 8 })
                            .width(20)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Center)
                    .onClick(() => this.currentTab = 1)
                 }
                 .height(48)
                 .backgroundColor(Color.White)
                 .width('100%')
                 .margin({ bottom: 12 })
             }
 
             Scroll() {
                 Column() {
                     if (this.currentTab === 0 && this.history.operation_type === 'MODIFY') {
                         if (this.history.snapshot_before) {
                            this.buildRecordView(this.history.snapshot_before)
                         } else {
                             Text('无历史数据')
                         }
                     } else {
                         this.buildRecordView(this.history.snapshot_after)
                     }
                 }
                 .constraintSize({
                   minHeight:'100%'
                 })
                 .padding(16)
             }
             .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f8fafc')
    }
    .title(this.history?.operation_type === 'ADD' ? '新增记录详情' : '修改记录详情')
    .onReady((ctx: NavDestinationContext) => {
        this.navPathStack = ctx.pathStack;
        // Check if param is object or just HealthRecordHistory
        const param = ctx.pathInfo.param as Object;
        if (param && (param as Record<string, Object>)['history']) {
             this.history = (param as Record<string, Object>)['history'] as HealthRecordHistory;
        } else {
             // Fallback if passed directly?
             this.history = param as HealthRecordHistory;
        }
 
        // Set default tab to After
        this.currentTab = 1;
 
        // If it's ADD, tab is always 1 (hidden tabs)
    })
  }
}
