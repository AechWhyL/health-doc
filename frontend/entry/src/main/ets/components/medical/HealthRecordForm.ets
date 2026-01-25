import { promptAction } from '@kit.ArkUI';
import {
  HealthRecordType,
  HealthRecordFormSubmitPayload,
  HealthRecordContent,
  MedicalHistoryContent,
  CheckReportContent,
  MedicationContent,
  AllergyContent
} from '../../models/HealthArchiveModels';

interface IFormInputItem {
  label: string,
  value: string
}

interface SelectOption {
  value: string
}

@Component
export struct HealthRecordForm {
  @Prop elderName: string = ''
  @Prop recordType: HealthRecordType = 'MEDICAL_HISTORY'
  @Prop mode: 'create' | 'edit' = 'create'
  @Prop initialTitle: string = ''
  @Prop initialDate: string = ''
  @Prop initialContent: HealthRecordContent | null = null
  onSubmit: (payload: HealthRecordFormSubmitPayload) => void = () => {
  }
  onCancel: () => void = () => {
  }
  @State private recordTitle: string = ''
  @State private recordDateState: Date = new Date()
  @State private diseaseName: string = ''
  @State private diagnosedAtState: Date = new Date()
  @State private medicalStatus: string = 'ONGOING'
  @State private medicalNotes: string = ''
  @State private checkDateState: Date = new Date()
  @State private checkHospitalName: string = ''
  @State private checkItem: string = ''
  @State private checkResultSummary: string = 'NORMAL'
  @State private checkNotes: string = ''
  @State private drugNameInput: string = ''
  @State private dosage: string = ''
  @State private frequency: string = ''
  @State private route: string = ''
  @State private medicationStartDateState: Date = new Date()
  @State private medicationEndDateState: Date = new Date()
  @State private medicationEndDateEnabled: boolean = false
  @State private medicationNotes: string = ''
  @State private prescribingDoctor: string = ''
  @State private medicationHospitalName: string = ''
  @State private allergyItem: string = ''
  @State private allergyFirstDateState: Date = new Date()
  @State private allergyLastDateState: Date = new Date()
  @State private allergyLastDateEnabled: boolean = false
  @State private allergyReactionSymptoms: string = ''
  @State private allergyNotes: string = ''
  @State private initialized: boolean = false

  // Select indexes for Select component
  @State private medicalStatusIndex: number = 0
  @State private checkResultIndex: number = 0

  aboutToAppear(): void {
    if (this.initialized) {
      return
    }
    this.initialized = true
    this.initFromProps()
  }

  private initFromProps(): void {
    if (this.initialTitle !== '') {
      this.recordTitle = this.initialTitle
    }
    if (this.initialDate !== '') {
      const parsed = this.parseDateFromString(this.initialDate)
      if (parsed) {
        this.recordDateState = parsed
      }
    }
    if (this.initialContent !== null) {
      this.fillContentFromInitial(this.initialContent)
    } else {
      this.resetByType()
    }
  }

  private resetByType(): void {
    const today = new Date()
    this.recordDateState = today
    if (this.recordType === 'MEDICAL_HISTORY') {
      this.diseaseName = ''
      this.diagnosedAtState = today
      this.medicalStatus = 'ONGOING'
      this.medicalStatusIndex = 0
      this.medicalNotes = ''
    } else if (this.recordType === 'CHECK_REPORT') {
      this.checkDateState = today
      this.checkHospitalName = ''
      this.checkItem = ''
      this.checkResultSummary = 'NORMAL'
      this.checkResultIndex = 0
      this.checkNotes = ''
    } else if (this.recordType === 'MEDICATION') {
      this.drugNameInput = ''
      this.dosage = ''
      this.frequency = ''
      this.route = ''
      this.medicationStartDateState = today
      this.medicationEndDateEnabled = false
      this.medicationNotes = ''
      this.prescribingDoctor = ''
      this.medicationHospitalName = ''
    } else if (this.recordType === 'ALLERGY') {
      this.allergyItem = ''
      this.allergyFirstDateState = today
      this.allergyLastDateEnabled = false
      this.allergyReactionSymptoms = ''
      this.allergyNotes = ''
    }
  }

  private fillContentFromInitial(content: HealthRecordContent): void {
    if (this.recordType === 'MEDICAL_HISTORY') {
      const c = content as MedicalHistoryContent;
      this.diseaseName = c.disease_name || ''
      const diagnosedAt = this.parseDateFromString(c.diagnosed_at)
      if (diagnosedAt) {
        this.diagnosedAtState = diagnosedAt
      }
      this.medicalStatus = c.status || 'ONGOING'
      this.medicalStatusIndex = this.getStatusIndex(this.medicalStatus)
      this.medicalNotes = c.notes || ''

    } else if (this.recordType === 'CHECK_REPORT') {
      const c = content as CheckReportContent;
      const checkDate = this.parseDateFromString(c.check_date)
      if (checkDate) {
        this.checkDateState = checkDate
      }
      this.checkHospitalName = c.hospital_name || ''
      this.checkItem = c.check_item || ''
      this.checkResultSummary = c.result_summary || 'NORMAL'
      this.checkResultIndex = this.getResultIndex(this.checkResultSummary)
      this.checkNotes = c.notes || ''

    } else if (this.recordType === 'MEDICATION') {
      const c = content as MedicationContent;
      if (c.drug_name && Array.isArray(c.drug_name)) {
        this.drugNameInput = c.drug_name.join('；')
      }
      this.dosage = c.dosage || ''
      this.frequency = c.frequency || ''
      this.route = c.route || ''
      const startDate = this.parseDateFromString(c.start_date)
      if (startDate) {
        this.medicationStartDateState = startDate
      }
      if (c.end_date) {
        const endDate = this.parseDateFromString(c.end_date)
        if (endDate) {
          this.medicationEndDateState = endDate
          this.medicationEndDateEnabled = true
        }
      }
      this.medicationNotes = c.notes || ''
      this.prescribingDoctor = c.prescribing_doctor || ''
      this.medicationHospitalName = c.hospital_name || ''

    } else if (this.recordType === 'ALLERGY') {
      const c = content as AllergyContent;
      this.allergyItem = c.allergy_item || ''
      const firstDate = this.parseDateFromString(c.first_occurrence_date)
      if (firstDate) {
        this.allergyFirstDateState = firstDate
      }
      if (c.last_occurrence_date) {
        const lastDate = this.parseDateFromString(c.last_occurrence_date)
        if (lastDate) {
          this.allergyLastDateState = lastDate
          this.allergyLastDateEnabled = true
        }
      }
      if (c.reaction_symptoms && Array.isArray(c.reaction_symptoms)) {
        this.allergyReactionSymptoms = c.reaction_symptoms.join('；')
      }
      this.allergyNotes = c.notes || ''
    }
  }

  private formatDate(date: Date): string {
    // Return ISO date format for backend validation
    return date.toISOString().split('T')[0]
  }

  private parseDateFromString(value: string | undefined): Date | null {
    if (!value || value === '') {
      return null
    }
    const parts = value.split('-')
    if (parts.length !== 3) {
      return null
    }
    const year = Number.parseInt(parts[0])
    const month = Number.parseInt(parts[1])
    const day = Number.parseInt(parts[2])
    if (Number.isNaN(year) || Number.isNaN(month) || Number.isNaN(day)) {
      return null
    }
    return new Date(year, month - 1, day)
  }

  private getStatusIndex(status: string): number {
    switch (status) {
      case 'ONGOING': return 0
      case 'REMISSION': return 1
      case 'CURED': return 2
      default: return 0
    }
  }

  private getResultIndex(result: string): number {
    switch (result) {
      case 'NORMAL': return 0
      case 'MILD_ABNORMAL': return 1
      case 'SIGNIFICANT_ABNORMAL': return 2
      default: return 0
    }
  }

  private pickDate(current: Date, onAccept: (value: Date) => void): void {
    this.getUIContext().showDatePickerDialog({
      start: new Date('2000-01-01'),
      end: new Date('2100-12-31'),
      selected: current,
      showTime: false,
      useMilitaryTime: false,
      onDateAccept: (value: Date) => {
        onAccept(value)
      },
      onCancel: () => {
      },
      onDateChange: (_value: Date) => {
      },
      onDidAppear: () => {
      },
      onDidDisappear: () => {
      },
      onWillAppear: () => {
      },
      onWillDisappear: () => {
      }
    })
  }

  private validateAndSubmit(): void {
    const title = this.recordTitle.trim()
    if (title === '') {
      this.getUIContext().getPromptAction().showToast({
        message: '请填写记录标题'
      })
      return
    }
    const recordDate = this.formatDate(this.recordDateState)
    
    // Construct specific content object based on type
    let content: HealthRecordContent;

    if (this.recordType === 'MEDICAL_HISTORY') {
      const disease = this.diseaseName.trim()
      if (disease === '') {
        this.getUIContext().getPromptAction().showToast({
          message: '请填写疾病名称'
        })
        return
      }
      
      const medicalContent: MedicalHistoryContent = {
        disease_name: disease,
        diagnosed_at: this.formatDate(this.diagnosedAtState),
        status: this.medicalStatus as 'ONGOING' | 'REMISSION' | 'CURED',
        notes: this.medicalNotes.trim() || undefined
      }
      content = medicalContent;

    } else if (this.recordType === 'CHECK_REPORT') {
      const hospital = this.checkHospitalName.trim()
      const item = this.checkItem.trim()
      if (hospital === '') {
        this.getUIContext().getPromptAction().showToast({
          message: '请填写检查医院名称'
        })
        return
      }
      if (item === '') {
        this.getUIContext().getPromptAction().showToast({
          message: '请填写检查项目'
        })
        return
      }

      const checkContent: CheckReportContent = {
        check_date: this.formatDate(this.checkDateState),
        hospital_name: hospital,
        check_item: item,
        result_summary: this.checkResultSummary as 'NORMAL' | 'MILD_ABNORMAL' | 'SIGNIFICANT_ABNORMAL',
        notes: this.checkNotes.trim() || undefined
      }
      content = checkContent;

    } else if (this.recordType === 'MEDICATION') {
      const drugNamesRaw = this.drugNameInput.trim()
      if (drugNamesRaw === '') {
        this.getUIContext().getPromptAction().showToast({
          message: '请填写用药名称'
        })
        return
      }
      const drugNames: string[] = this.splitDrugNames(drugNamesRaw)
      const dosageText = this.dosage.trim()
      const frequencyText = this.frequency.trim()
      const routeText = this.route.trim()
      if (dosageText === '' || frequencyText === '' || routeText === '') {
        this.getUIContext().getPromptAction().showToast({
          message: '请完善剂量、频次和给药途径'
        })
        return
      }
      
      const medContent: MedicationContent = {
        drug_name: drugNames,
        dosage: dosageText,
        frequency: frequencyText,
        route: routeText,
        start_date: this.formatDate(this.medicationStartDateState),
        end_date: this.medicationEndDateEnabled ? this.formatDate(this.medicationEndDateState) : undefined,
        notes: this.medicationNotes.trim() || undefined,
        prescribing_doctor: this.prescribingDoctor.trim() || undefined,
        hospital_name: this.medicationHospitalName.trim() || undefined
      };
      content = medContent;

    } else { // ALLERGY
      const allergyItemText = this.allergyItem.trim()
      if (allergyItemText === '') {
        this.getUIContext().getPromptAction().showToast({
          message: '请填写过敏项目'
        })
        return
      }
      
      const symptomsText = this.allergyReactionSymptoms.trim()
      if (!symptomsText) {
        this.getUIContext().getPromptAction().showToast({
          message: '请填写过敏反应症状'
        })
        return
      }
      
      const allergyContent: AllergyContent = {
        allergy_item: allergyItemText,
        first_occurrence_date: this.formatDate(this.allergyFirstDateState),
        last_occurrence_date: this.allergyLastDateEnabled ? this.formatDate(this.allergyLastDateState) : undefined,
        reaction_symptoms: this.splitDrugNames(symptomsText),
        notes: this.allergyNotes.trim() || undefined
      };
      content = allergyContent;
    }

    const payload: HealthRecordFormSubmitPayload = {
      recordType: this.recordType,
      recordTitle: title,
      recordDate: recordDate,
      contentStructured: content
    }

    this.onSubmit(payload)
  }

  private splitDrugNames(raw: string): string[] {
    const separators: string[] = [';', '；', '，', ',']
    let current: string = ''
    const result: string[] = []
    for (let i = 0; i < raw.length; i++) {
      const ch = raw.charAt(i)
      let isSeparator: boolean = false
      for (let j = 0; j < separators.length; j++) {
        if (ch === separators[j]) {
          isSeparator = true
          break
        }
      }
      if (isSeparator) {
        const trimmed = current.trim()
        if (trimmed !== '') {
          result.push(trimmed)
        }
        current = ''
      } else {
        current = current + ch
      }
    }
    const finalText = current.trim()
    if (finalText !== '') {
      result.push(finalText)
    }
    return result
  }

  @Builder
  private FormField(label: string, required: boolean = false) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor('#374151')
        .fontWeight(FontWeight.Medium)
      if (required) {
        Text(' *')
          .fontSize(13)
          .fontColor('#dc2626')
      }
    }
    .width('100%')
    .margin({ bottom: 6 })
  }

  @Builder
  private buildInputField(label: string, placeholder: string, value: string, onChange: (v: string) => void, required: boolean = false) {
    Column() {
      this.FormField(label, required)
      TextInput({ text: value, placeholder: placeholder })
        .height(44)
        .fontSize(14)
        .padding({ left: 14, right: 14 })
        .borderRadius(12)
        .backgroundColor('#f8fafc')
        .border({ width: 1, color: '#e2e8f0' })
        .onChange((text: string) => {
          onChange(text)
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 16 })
  }

  @Builder
  private buildTextAreaField(label: string, placeholder: string, value: string, onChange: (v: string) => void) {
    Column() {
      this.FormField(label, false)
      TextArea({ text: value, placeholder: placeholder })
        .height(80)
        .fontSize(14)
        .padding(14)
        .borderRadius(12)
        .backgroundColor('#f8fafc')
        .border({ width: 1, color: '#e2e8f0' })
        .onChange((text: string) => {
          onChange(text)
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 16 })
  }

  @Builder
  private buildDateField(label: string, current: Date, onChangeDate: (value: Date) => void, required: boolean = false) {
    Column() {
      this.FormField(label, required)
      Row() {
        Text('📅')
          .fontSize(16)
          .margin({ right: 10 })
        Text(this.formatDate(current))
          .fontSize(14)
          .fontColor('#1e293b')
          .layoutWeight(1)
        Text('›')
          .fontSize(18)
          .fontColor('#94a3b8')
      }
      .width('100%')
      .height(44)
      .padding({ left: 14, right: 14 })
      .borderRadius(12)
      .backgroundColor('#f8fafc')
      .border({ width: 1, color: '#e2e8f0' })
      .onClick(() => {
        this.pickDate(current, (value: Date) => {
          onChangeDate(value)
        })
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 16 })
  }

  // Status options for Select
  statusOptions: SelectOption[] = [
    { value: '治疗中' },
    { value: '缓解' },
    { value: '痊愈' }
  ]

  // Result options for Select
  resultOptions: SelectOption[] = [
    { value: '正常' },
    { value: '轻度异常' },
    { value: '显著异常' }
  ]

  @Builder
  private buildMedicalHistoryFields() {
    Column() {
      this.buildInputField('记录标题', '如：高血压病史', this.recordTitle, (v: string) => {
        this.recordTitle = v
      }, true)

      this.buildInputField('疾病名称', '如：原发性高血压', this.diseaseName, (v: string) => {
        this.diseaseName = v
      }, true)

      this.buildDateField('确诊日期', this.diagnosedAtState, (value: Date) => {
        this.diagnosedAtState = value
      }, true)

      Column() {
        this.FormField('当前状态', true)
        Select(this.statusOptions)
          .selected(this.medicalStatusIndex)
          .value(this.statusOptions[this.medicalStatusIndex].value)
          .font({ size: 14 })
          .fontColor('#1e293b')
          .selectedOptionFont({ size: 14 })
          .optionFont({ size: 14 })
          .height(44)
          .width('100%')
          .borderRadius(12)
          .backgroundColor('#f8fafc')
          .onSelect((index: number) => {
            this.medicalStatusIndex = index
            switch (index) {
              case 0: this.medicalStatus = 'ONGOING'; break
              case 1: this.medicalStatus = 'REMISSION'; break
              case 2: this.medicalStatus = 'CURED'; break
            }
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })

      this.buildDateField('记录日期', this.recordDateState, (value: Date) => {
        this.recordDateState = value
      })

      this.buildTextAreaField('备注说明', '病程说明、并发症等（可选）', this.medicalNotes, (v: string) => {
        this.medicalNotes = v
      })
    }
    .width('100%')
  }

  @Builder
  private buildCheckReportFields() {
    Column() {
      this.buildInputField('记录标题', '如：2025年度体检报告', this.recordTitle, (v: string) => {
        this.recordTitle = v
      }, true)

      this.buildDateField('检查日期', this.checkDateState, (value: Date) => {
        this.checkDateState = value
        this.recordDateState = value
      }, true)

      this.buildInputField('检查医院', '如：市第一人民医院', this.checkHospitalName, (v: string) => {
        this.checkHospitalName = v
      }, true)

      this.buildInputField('检查项目', '如：胸部CT、心电图', this.checkItem, (v: string) => {
        this.checkItem = v
      }, true)

      Column() {
        this.FormField('检查结果', true)
        Select(this.resultOptions)
          .selected(this.checkResultIndex)
          .value(this.resultOptions[this.checkResultIndex].value)
          .font({ size: 14 })
          .fontColor('#1e293b')
          .selectedOptionFont({ size: 14 })
          .optionFont({ size: 14 })
          .height(44)
          .width('100%')
          .borderRadius(12)
          .backgroundColor('#f8fafc')
          .onSelect((index: number) => {
            this.checkResultIndex = index
            switch (index) {
              case 0: this.checkResultSummary = 'NORMAL'; break
              case 1: this.checkResultSummary = 'MILD_ABNORMAL'; break
              case 2: this.checkResultSummary = 'SIGNIFICANT_ABNORMAL'; break
            }
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })

      this.buildTextAreaField('结论/建议', '关键检查结论、随访建议等', this.checkNotes, (v: string) => {
        this.checkNotes = v
      })
    }
    .width('100%')
  }

  @Builder
  private buildMedicationFields() {
    Column() {
      this.buildInputField('记录标题', '如：降压药方案调整', this.recordTitle, (v: string) => {
        this.recordTitle = v
      }, true)

      this.buildInputField('药品名称', '如：奥美沙坦 20mg（多药用分号隔开）', this.drugNameInput, (v: string) => {
        this.drugNameInput = v
      }, true)

      Row({ space: 12 }) {
        Column() {
          this.FormField('单次剂量', true)
          TextInput({ text: this.dosage, placeholder: '如：20mg' })
            .height(44)
            .fontSize(14)
            .padding({ left: 14, right: 14 })
            .borderRadius(12)
            .backgroundColor('#f8fafc')
            .border({ width: 1, color: '#e2e8f0' })
            .onChange((text: string) => {
              this.dosage = text
            })
        }
        .layoutWeight(1)

        Column() {
          this.FormField('用药频次', true)
          TextInput({ text: this.frequency, placeholder: '如：qd' })
            .height(44)
            .fontSize(14)
            .padding({ left: 14, right: 14 })
            .borderRadius(12)
            .backgroundColor('#f8fafc')
            .border({ width: 1, color: '#e2e8f0' })
            .onChange((text: string) => {
              this.frequency = text
            })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 16 })

      this.buildInputField('给药途径', '如：po 口服', this.route, (v: string) => {
        this.route = v
      }, true)

      this.buildDateField('开始日期', this.medicationStartDateState, (value: Date) => {
        this.medicationStartDateState = value
        this.recordDateState = value
      }, true)

      Row() {
        Column() {
          this.FormField('结束日期', false)
          Row() {
            Text('📅')
              .fontSize(16)
              .margin({ right: 10 })
            Text(this.medicationEndDateEnabled ? this.formatDate(this.medicationEndDateState) : '长期用药')
              .fontSize(14)
              .fontColor(this.medicationEndDateEnabled ? '#1e293b' : '#94a3b8')
              .layoutWeight(1)
          }
          .width('100%')
          .height(44)
          .padding({ left: 14, right: 14 })
          .borderRadius(12)
          .backgroundColor('#f8fafc')
          .border({ width: 1, color: '#e2e8f0' })
          .onClick(() => {
            if (this.medicationEndDateEnabled) {
              this.pickDate(this.medicationEndDateState, (value: Date) => {
                this.medicationEndDateState = value
              })
            }
          })
        }
        .layoutWeight(1)

        Column() {
          Text('设置结束')
            .fontSize(12)
            .fontColor('#64748b')
            .margin({ bottom: 8 })
          Toggle({ type: ToggleType.Switch, isOn: this.medicationEndDateEnabled })
            .onChange((isOn: boolean) => {
              this.medicationEndDateEnabled = isOn
            })
        }
        .width(80)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .margin({ bottom: 16 })

      this.buildInputField('开方医生', '如：王医生（可选）', this.prescribingDoctor, (v: string) => {
        this.prescribingDoctor = v
      })

      this.buildInputField('就诊医院', '如：社区卫生服务中心（可选）', this.medicationHospitalName, (v: string) => {
        this.medicationHospitalName = v
      })

      this.buildTextAreaField('用药备注', '用药目的、注意事项等', this.medicationNotes, (v: string) => {
        this.medicationNotes = v
      })
    }
    .width('100%')
  }

  @Builder
  private buildAllergyFields() {
    Column() {
      this.buildInputField('记录标题', '如：青霉素过敏史', this.recordTitle, (v: string) => {
        this.recordTitle = v
      }, true)

      this.buildInputField('过敏源', '如：青霉素、花生等', this.allergyItem, (v: string) => {
        this.allergyItem = v
      }, true)

      this.buildDateField('首次发生日期', this.allergyFirstDateState, (value: Date) => {
        this.allergyFirstDateState = value
        this.recordDateState = value
      }, true)

      this.buildTextAreaField('过敏反应', '如：皮疹、呼吸困难等', this.allergyReactionSymptoms, (v: string) => {
        this.allergyReactionSymptoms = v
      })

      Row() {
        Column() {
          this.FormField('最近发生日期', false)
          Row() {
            Text('📅')
            // ... (rest of date picker UI is same as before)
// ... truncated for brevity, but I will include full code ...
            Text('📅')
              .fontSize(16)
              .margin({ right: 10 })
            Text(this.allergyLastDateEnabled ? this.formatDate(this.allergyLastDateState) : '未设置')
              .fontSize(14)
              .fontColor(this.allergyLastDateEnabled ? '#1e293b' : '#94a3b8')
              .layoutWeight(1)
          }
          .width('100%')
          .height(44)
          .padding({ left: 14, right: 14 })
          .borderRadius(12)
          .backgroundColor('#f8fafc')
          .border({ width: 1, color: '#e2e8f0' })
          .onClick(() => {
            if (this.allergyLastDateEnabled) {
              this.pickDate(this.allergyLastDateState, (value: Date) => {
                this.allergyLastDateState = value
              })
            }
          })
        }
        .layoutWeight(1)

        Column() {
          Text('设置日期')
            .fontSize(12)
            .fontColor('#64748b')
            .margin({ bottom: 8 })
          Toggle({ type: ToggleType.Switch, isOn: this.allergyLastDateEnabled })
            .onChange((isOn: boolean) => {
              this.allergyLastDateEnabled = isOn
            })
        }
        .width(80)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .margin({ bottom: 16 })

      this.buildTextAreaField('备注说明', '严重程度、诱发因素等', this.allergyNotes, (v: string) => {
        this.allergyNotes = v
      })
    }
    .width('100%')
  }

  build() {
    Column() {
      if (this.recordType === 'MEDICAL_HISTORY') {
        this.buildMedicalHistoryFields()
      } else if (this.recordType === 'CHECK_REPORT') {
        this.buildCheckReportFields()
      } else if (this.recordType === 'MEDICATION') {
        this.buildMedicationFields()
      } else if (this.recordType === 'ALLERGY') {
        this.buildAllergyFields()
      }

      // Action buttons
      Row({ space: 12 }) {
        Button(this.mode === 'create' ? '提交' : '保存')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .height(48)
          .backgroundColor('#2563eb')
          .fontColor(Color.White)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.validateAndSubmit()
          })

        Button('取消')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .height(48)
          .backgroundColor('#f1f5f9')
          .fontColor('#64748b')
          .fontSize(15)
          .onClick(() => {
            this.onCancel()
          })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
  }
}
