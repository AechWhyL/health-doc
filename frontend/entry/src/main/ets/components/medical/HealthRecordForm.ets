import { promptAction } from '@kit.ArkUI';
import { HealthRecordType, HealthRecordFormSubmitPayload } from '../../models/HealthRecordModels';

interface IFormInputItem {
  label: string,
  value: string
}

@Component
export struct HealthRecordForm {
  @Prop elderName: string = ''
  @Prop recordType: HealthRecordType = 'MEDICAL_HISTORY'
  @Prop mode: 'create' | 'edit' = 'create'
  @Prop initialTitle: string = ''
  @Prop initialDate: string = ''
  @Prop initialContent: Record<string, Object> | null = null
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
      this.medicalNotes = ''
    } else if (this.recordType === 'CHECK_REPORT') {
      this.checkDateState = today
      this.checkHospitalName = ''
      this.checkItem = ''
      this.checkResultSummary = 'NORMAL'
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

  private fillContentFromInitial(content: Record<string, Object>): void {
    if (this.recordType === 'MEDICAL_HISTORY') {
      const disease = this.getStringField(content, 'disease_name')
      if (disease !== null) {
        this.diseaseName = disease
      }
      const diagnosedAt = this.getStringField(content, 'diagnosed_at')
      if (diagnosedAt !== null) {
        const dt = this.parseDateFromString(diagnosedAt)
        if (dt) {
          this.diagnosedAtState = dt
        }
      }
      const status = this.getStringField(content, 'status')
      if (status !== null) {
        this.medicalStatus = status
      }
      const notes = this.getStringField(content, 'notes')
      if (notes !== null) {
        this.medicalNotes = notes
      }
    } else if (this.recordType === 'CHECK_REPORT') {
      const checkDate = this.getStringField(content, 'check_date')
      if (checkDate !== null) {
        const cd = this.parseDateFromString(checkDate)
        if (cd) {
          this.checkDateState = cd
        }
      }
      const hospital = this.getStringField(content, 'hospital_name')
      if (hospital !== null) {
        this.checkHospitalName = hospital
      }
      const checkItem = this.getStringField(content, 'check_item')
      if (checkItem !== null) {
        this.checkItem = checkItem
      }
      const resultSummary = this.getStringField(content, 'result_summary')
      if (resultSummary !== null) {
        this.checkResultSummary = resultSummary
      }
      const notes = this.getStringField(content, 'notes')
      if (notes !== null) {
        this.checkNotes = notes
      }
    } else if (this.recordType === 'MEDICATION') {
      const drugNamesValue = content['drug_name']
      if (drugNamesValue instanceof Array) {
        const names: Array<Object> = drugNamesValue as Array<Object>
        let combined: string = ''
        for (let i = 0; i < names.length; i++) {
          const item = names[i]
          if (typeof item === 'string') {
            if (combined === '') {
              combined = item
            } else {
              combined = combined + '；' + item
            }
          }
        }
        this.drugNameInput = combined
      }
      const dosage = this.getStringField(content, 'dosage')
      if (dosage !== null) {
        this.dosage = dosage
      }
      const frequency = this.getStringField(content, 'frequency')
      if (frequency !== null) {
        this.frequency = frequency
      }
      const route = this.getStringField(content, 'route')
      if (route !== null) {
        this.route = route
      }
      const startDate = this.getStringField(content, 'start_date')
      if (startDate !== null) {
        const sd = this.parseDateFromString(startDate)
        if (sd) {
          this.medicationStartDateState = sd
        }
      }
      const endDate = this.getStringField(content, 'end_date')
      if (endDate !== null && endDate !== '') {
        const ed = this.parseDateFromString(endDate)
        if (ed) {
          this.medicationEndDateState = ed
          this.medicationEndDateEnabled = true
        }
      }
      const notes = this.getStringField(content, 'notes')
      if (notes !== null) {
        this.medicationNotes = notes
      }
      const prescribingDoctor = this.getStringField(content, 'prescribing_doctor')
      if (prescribingDoctor !== null) {
        this.prescribingDoctor = prescribingDoctor
      }
      const hospitalName = this.getStringField(content, 'hospital_name')
      if (hospitalName !== null) {
        this.medicationHospitalName = hospitalName
      }
    } else if (this.recordType === 'ALLERGY') {
      const allergyItem = this.getStringField(content, 'allergy_item')
      if (allergyItem !== null) {
        this.allergyItem = allergyItem
      }
      const firstDate = this.getStringField(content, 'first_occurrence_date')
      if (firstDate !== null) {
        const fd = this.parseDateFromString(firstDate)
        if (fd) {
          this.allergyFirstDateState = fd
        }
      }
      const lastDate = this.getStringField(content, 'last_occurrence_date')
      if (lastDate !== null && lastDate !== '') {
        const ld = this.parseDateFromString(lastDate)
        if (ld) {
          this.allergyLastDateState = ld
          this.allergyLastDateEnabled = true
        }
      }
      const reactions = this.getStringField(content, 'reaction_symptoms')
      if (reactions !== null) {
        this.allergyReactionSymptoms = reactions
      }
      const notes = this.getStringField(content, 'notes')
      if (notes !== null) {
        this.allergyNotes = notes
      }
    }
  }

  private getStringField(content: Record<string, Object>, key: string): string | null {
    const value = content[key]
    if (typeof value === 'string') {
      return value
    }
    return null
  }

  private formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = date.getMonth() + 1
    const day = date.getDate()
    const monthText = month < 10 ? '0' + month.toString() : month.toString()
    const dayText = day < 10 ? '0' + day.toString() : day.toString()
    return year.toString() + '-' + monthText + '-' + dayText
  }

  private parseDateFromString(value: string): Date | null {
    if (value === '') {
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
    let content: Record<string, Object> = {}
    if (this.recordType === 'MEDICAL_HISTORY') {
      const disease = this.diseaseName.trim()
      if (disease === '') {
        this.getUIContext().getPromptAction().showToast({
          message: '请填写疾病名称'
        })
        return
      }
      const diagnosedAt = this.formatDate(this.diagnosedAtState)
      content['disease_name'] = disease
      content['diagnosed_at'] = diagnosedAt
      content['status'] = this.medicalStatus
      content['notes'] = this.medicalNotes.trim()
    } else if (this.recordType === 'CHECK_REPORT') {
      const checkDate = this.formatDate(this.checkDateState)
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
      content['check_date'] = checkDate
      content['hospital_name'] = hospital
      content['check_item'] = item
      content['result_summary'] = this.checkResultSummary
      content['notes'] = this.checkNotes.trim()
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
      const startDate = this.formatDate(this.medicationStartDateState)
      let endDate: string = ''
      if (this.medicationEndDateEnabled) {
        endDate = this.formatDate(this.medicationEndDateState)
      }
      content['drug_name'] = drugNames
      content['dosage'] = dosageText
      content['frequency'] = frequencyText
      content['route'] = routeText
      content['start_date'] = startDate
      content['end_date'] = endDate
      content['notes'] = this.medicationNotes.trim()
      content['prescribing_doctor'] = this.prescribingDoctor.trim()
      content['hospital_name'] = this.medicationHospitalName.trim()
    } else if (this.recordType === 'ALLERGY') {
      const allergyItemText = this.allergyItem.trim()
      if (allergyItemText === '') {
        this.getUIContext().getPromptAction().showToast({
          message: '请填写过敏项目'
        })
        return
      }
      const firstDate = this.formatDate(this.allergyFirstDateState)
      let lastDate: string = ''
      if (this.allergyLastDateEnabled) {
        lastDate = this.formatDate(this.allergyLastDateState)
      }
      content['allergy_item'] = allergyItemText
      content['first_occurrence_date'] = firstDate
      content['last_occurrence_date'] = lastDate
      content['reaction_symptoms'] = this.allergyReactionSymptoms.trim()
      content['notes'] = this.allergyNotes.trim()
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
  private buildInputField(label: string, placeholder: string, value: string, onChange: (v: string) => void) {
    Column() {
      Text(label)
        .fontSize(11)
        .fontColor('#6b7280')
      TextInput({ text: value, placeholder: placeholder })
        .height(32)
        .fontSize(12)
        .padding({ left: 12, right: 12 })
        .borderRadius(16)
        .backgroundColor('#f9fafb')
        .onChange((text: string) => {
          onChange(text)
        })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildDateField(label: string, current: Date, onChangeDate: (value: Date) => void) {
    Column() {
      Text(label)
        .fontSize(11)
        .fontColor('#6b7280')
        .width("100%")
      Row() {
        Text(this.formatDate(current))
          .fontSize(12)
          .fontColor('#111827')
          .margin({ right: 8 })
          .width("100%")
      }
      .padding({
        left: 12,
        right: 12,
        top: 6,
        bottom: 6
      })
      .borderRadius(16)
      .backgroundColor('#f9fafb')
      .onClick(() => {
        this.pickDate(current, (value: Date) => {
          onChangeDate(value)
        })
      })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildSelectField(label: string, value: string, options: IFormInputItem[],
    onChangeValue: (v: string) => void) {
    Column() {
      Text(label)
        .fontSize(11)
        .fontColor('#6b7280')
      Row() {
        ForEach(options, (item: IFormInputItem) => {
          Text(item.label)
            .fontSize(11)
            .fontColor(item.value === value ? '#f9fafb' : '#4b5563')
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4
            })
            .borderRadius(999)
            .backgroundColor(item.value === value ? '#111827' : '#f3f4f6')
            .margin({ right: 6, top: 2 })
            .onClick(() => {
              onChangeValue(item.value)
            })
        }, (item: IFormInputItem) => item.value)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width("100%")
  }

  currStatusFormInputs: IFormInputItem[] = [
    { label: '治疗中', value: 'ONGOING' },
    { label: '缓解', value: 'REMISSION' },
    { label: '痊愈', value: 'CURED' }
  ]

  @Builder
  private buildMedicalHistoryFields() {
    Column({ space: 6 }) {
      this.buildInputField('记录标题', '如：高血压病史', this.recordTitle, (v: string) => {
        this.recordTitle = v
      })

      this.buildDateField('记录日期', this.recordDateState, (value: Date) => {
        this.recordDateState = value
      })

      this.buildInputField('疾病名称', '如：原发性高血压', this.diseaseName, (v: string) => {
        this.diseaseName = v
      })

      this.buildDateField('确诊日期', this.diagnosedAtState, (value: Date) => {
        this.diagnosedAtState = value
      })

      this.buildSelectField('当前状态', this.medicalStatus, this.currStatusFormInputs, (v: string) => {
        this.medicalStatus = v
      })

      this.buildInputField('备注说明', '病程说明、并发症等（可选）', this.medicalNotes, (v: string) => {
        this.medicalNotes = v
      })
    }
  }

  checkResultFormItems: IFormInputItem[] = [
    { label: '正常', value: 'NORMAL' },
    { label: '轻度异常', value: 'MILD_ABNORMAL' },
    { label: '显著异常', value: 'SIGNIFICANT_ABNORMAL' }
  ]

  @Builder
  private buildCheckReportFields() {
    Column({ space: 6 }) {
      this.buildInputField('记录标题', '如：2025年度体检报告', this.recordTitle, (v: string) => {
        this.recordTitle = v
      })

      this.buildDateField('检查日期', this.recordDateState, (value: Date) => {
        this.recordDateState = value
        this.checkDateState = value
      })

      this.buildInputField('就诊/检查医院', '如：市第一人民医院', this.checkHospitalName, (v: string) => {
        this.checkHospitalName = v
      })

      this.buildInputField('检查项目', '如：胸部CT、心电图', this.checkItem, (v: string) => {
        this.checkItem = v
      })

      this.buildSelectField('检查结果', this.checkResultSummary, this.checkResultFormItems, (v: string) => {
        this.checkResultSummary = v
      })

      this.buildInputField('关键结论/建议', '关键检查结论、随访建议等', this.checkNotes, (v: string) => {
        this.checkNotes = v
      })
    }
  }

  @Builder
  private buildMedicationFields() {
    Column({ space: 6 }) {
      this.buildInputField('记录标题', '如：降压药方案调整', this.recordTitle, (v: string) => {
        this.recordTitle = v
      })

      this.buildDateField('开始用药日期', this.recordDateState, (value: Date) => {
        this.recordDateState = value
        this.medicationStartDateState = value
      })

      this.buildInputField('药品名称', '如：奥美沙坦 20mg；可多种药物', this.drugNameInput, (v: string) => {
        this.drugNameInput = v
      })

      this.buildInputField('单次剂量', '如：20mg', this.dosage, (v: string) => {
        this.dosage = v
      })

      this.buildInputField('用药频次', '如：qd、bid 等', this.frequency, (v: string) => {
        this.frequency = v
      })

      this.buildInputField('给药途径', '如：po 口服', this.route, (v: string) => {
        this.route = v
      })

      Row() {
        Column() {
          this.buildDateField('结束日期', this.medicationEndDateState, (value: Date) => {
            this.medicationEndDateState = value
          })
        }
        .layoutWeight(1)

        Column() {
          Toggle({ type: ToggleType.Switch, isOn: this.medicationEndDateEnabled })
            .onChange((isOn: boolean) => {
              this.medicationEndDateEnabled = isOn
            })
          Text('是否设置结束日期')
            .fontSize(11)
            .fontColor('#6b7280')
        }
        .margin({ left: 8 })
      }

      this.buildInputField('开方医生', '如：王医生', this.prescribingDoctor, (v: string) => {
        this.prescribingDoctor = v
      })

      this.buildInputField('就诊医院', '如：社区卫生服务中心', this.medicationHospitalName, (v: string) => {
        this.medicationHospitalName = v
      })

      this.buildInputField('用药备注', '用药目的、注意事项等', this.medicationNotes, (v: string) => {
        this.medicationNotes = v
      })
    }
  }

  @Builder
  private buildAllergyFields() {
    Column({ space: 6 }) {
      this.buildInputField('记录标题', '如：青霉素过敏史', this.recordTitle, (v: string) => {
        this.recordTitle = v
      })

      this.buildDateField('首次发生日期', this.recordDateState, (value: Date) => {
        this.recordDateState = value
        this.allergyFirstDateState = value
      })

      this.buildInputField('过敏源', '如：青霉素、花生等', this.allergyItem, (v: string) => {
        this.allergyItem = v
      })

      this.buildInputField('过敏反应', '如：皮疹、呼吸困难，可多填', this.allergyReactionSymptoms, (v: string) => {
        this.allergyReactionSymptoms = v
      })

      Row() {
        Column() {
          this.buildDateField('最近发生日期', this.allergyLastDateState, (value: Date) => {
            this.allergyLastDateState = value
          })
        }
        .layoutWeight(1)

        Column() {
          Toggle({ type: ToggleType.Switch, isOn: this.allergyLastDateEnabled })
            .onChange((isOn: boolean) => {
              this.allergyLastDateEnabled = isOn
            })
          Text('是否设置最近发生日期')
            .fontSize(11)
            .fontColor('#6b7280')
        }
        .margin({ left: 8 })
      }

      this.buildInputField('备注说明', '严重程度、诱发因素等', this.allergyNotes, (v: string) => {
        this.allergyNotes = v
      })
    }
  }

  build() {
    Column() {
      Text(this.mode === 'create' ? '新增健康档案记录' : '编辑健康档案记录')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 4 })

      if (this.recordType === 'MEDICAL_HISTORY') {
        this.buildMedicalHistoryFields()
      } else if (this.recordType === 'CHECK_REPORT') {
        this.buildCheckReportFields()
      } else if (this.recordType === 'MEDICATION') {
        this.buildMedicationFields()
      } else if (this.recordType === 'ALLERGY') {
        this.buildAllergyFields()
      }

      Row() {
        Button(this.mode === 'create' ? '提交新记录' : '保存修改')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .height(34)
          .backgroundColor('#111827')
          .fontColor('#f9fafb')
          .onClick(() => {
            this.validateAndSubmit()
          })

        Button('取消')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .height(34)
          .margin({ left: 8 })
          .backgroundColor('#f9fafb')
          .fontColor('#111827')
          .border({
            width: 1,
            color: '#e5e7eb'
          })
          .onClick(() => {
            this.onCancel()
          })
      }
      .margin({ top: 10 })
    }
  }
}

