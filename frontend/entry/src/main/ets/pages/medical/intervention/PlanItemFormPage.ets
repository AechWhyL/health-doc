import { promptAction } from '@kit.ArkUI';
import { InterventionService } from '../../../common/api/InterventionService';
import dayjs from 'dayjs';
import {
  CreatePlanItemRequest,
  CreatePlanItemScheduleRequest,
  PlanItemType,
  MedicationDetail,
  RehabDetail
} from '../../../models/DTO/intervention';
import { FormRow } from '../../../components/common/FormRow'

export interface PlanItemFormRouteParams {
  planId: number;
}

@Builder
export function PlanItemFormPageBuilder() {
  PlanItemFormPage()
}

@Component
export struct PlanItemFormPage {
  @State private planId: number = 0
  @State private formItemType: PlanItemType = 'MEDICATION'
  @State private formName: string = ''
  @State private formDescription: string = ''
  @State private formDrugName: string = ''
  @State private formDosage: string = ''
  @State private formFrequencyType: string = ''
  @State private formInstructions: string = ''
  @State private formExerciseName: string = ''
  @State private formExerciseType: string = ''
  @State private formGuideUrl: string = ''
  @State private formScheduleType: string = 'DAILY'
  @State private formScheduleTimes: string[] = ['08:00']
  @State private formScheduleStartDate: Date | null = new Date()
  @State private formScheduleEndDate: Date | null = null
  @State private formSelectedWeekdays: boolean[] = [false, false, false, false, false, false, false]
  @State private formIsSubmitting: boolean = false
  private weekDayLabels: string[] = ['一', '二', '三', '四', '五', '六', '日'];
  @Consume('navPathStack') navPathStack: NavPathStack;

  private addFormTime(): void {
    if (this.formScheduleTimes.length < 6) {
      this.formScheduleTimes = this.formScheduleTimes.concat(['12:00'])
    }
  }

  private removeFormTime(index: number): void {
    if (this.formScheduleTimes.length > 1) {
      const newTimes: string[] = []
      for (let i = 0; i < this.formScheduleTimes.length; i++) {
        if (i !== index) {
          newTimes.push(this.formScheduleTimes[i])
        }
      }
      this.formScheduleTimes = newTimes
    }
  }

  private updateFormTime(index: number, value: string): void {
    const newTimes: string[] = []
    for (let i = 0; i < this.formScheduleTimes.length; i++) {
      if (i === index) {
        newTimes.push(value)
      } else {
        newTimes.push(this.formScheduleTimes[i])
      }
    }
    this.formScheduleTimes = newTimes
  }

  private toggleWeekday(index: number): void {
    const newWeekdays: boolean[] = []
    for (let i = 0; i < this.formSelectedWeekdays.length; i++) {
      if (i === index) {
        newWeekdays.push(!this.formSelectedWeekdays[i])
      } else {
        newWeekdays.push(this.formSelectedWeekdays[i])
      }
    }
    this.formSelectedWeekdays = newWeekdays
  }

  private async submitItemForm() {
    if (!this.formName.trim()) {
      promptAction.showToast({ message: '请输入计划项名称' });
      return;
    }
    if (!this.formScheduleStartDate) {
      promptAction.showToast({ message: '请选择日程开始日期' });
      return;
    }
    if (!this.formScheduleEndDate) {
      promptAction.showToast({ message: '请选择日程结束日期' });
      return;
    }
    if (this.formItemType === 'MEDICATION' && (!this.formDrugName || !this.formDosage || !this.formFrequencyType)) {
      promptAction.showToast({ message: '请完善用药信息' });
      return;
    }
    if (this.formItemType === 'REHAB' && !this.formExerciseName) {
      promptAction.showToast({ message: '请输入训练名称' });
      return;
    }
    if (this.formScheduleType === 'WEEKLY') {
      const hasSelected = this.formSelectedWeekdays.some(v => v);
      if (!hasSelected) {
        promptAction.showToast({ message: '请选择重复星期' });
        return;
      }
    }

    this.formIsSubmitting = true;
    try {
      const startDateStr = dayjs(this.formScheduleStartDate).format('YYYY-MM-DD');
      const itemRequest: CreatePlanItemRequest = {
        itemType: this.formItemType,
        name: this.formName,
        description: this.formDescription,
        startDate: startDateStr,
        endDate: this.formScheduleEndDate ? dayjs(this.formScheduleEndDate).format('YYYY-MM-DD') : null
      };

      if (this.formItemType === 'MEDICATION') {
        const detail: MedicationDetail = {
          drug_name: this.formDrugName,
          dosage: this.formDosage,
          frequency_type: this.formFrequencyType,
          instructions: this.formInstructions
        };
        itemRequest.medicationDetail = detail;
      } else {
        const detail: RehabDetail = {
          exercise_name: this.formExerciseName,
          exercise_type: this.formExerciseType,
          guide_resource_url: this.formGuideUrl
        };
        itemRequest.rehabDetail = detail;
      }

      const itemResponse = await InterventionService.createPlanItem(this.planId, itemRequest);
      if (itemResponse.code !== 200 || !itemResponse.data) {
        throw new Error(itemResponse.message || '创建计划项失败');
      }

      const itemId = itemResponse.data.id;

      const scheduleRequest: CreatePlanItemScheduleRequest = {
        scheduleType: this.formScheduleType as 'ONCE' | 'DAILY' | 'WEEKLY',
        startDate: startDateStr,
        endDate: this.formScheduleEndDate ? dayjs(this.formScheduleEndDate).format('YYYY-MM-DD') : null,
        timesOfDay: this.formScheduleTimes
      };

      if (this.formScheduleType === 'WEEKLY') {
        const weekdays: number[] = []
        for (let i = 0; i < this.formSelectedWeekdays.length; i++) {
          if (this.formSelectedWeekdays[i]) {
            weekdays.push(i + 1)
          }
        }
        scheduleRequest.weekdays = weekdays
      }

      await InterventionService.createPlanItemSchedule(itemId, scheduleRequest);
      promptAction.showToast({ message: '创建成功' });
      this.navPathStack.pop();
    } catch (e) {
      promptAction.showToast({ message: e.message || '创建失败' });
    } finally {
      this.formIsSubmitting = false;
    }
  }

  // Builders for FormRow content
  @Builder
  nameInputBuilder() {
    TextInput({ text: this.formName, placeholder: '计划项名称' })
      .height(40)
      .backgroundColor('#fff')
      .border({ width: 1, color: '#d1d5db' })
      .borderRadius(8)
      .onChange((v) => {
        this.formName = v
      })
  }

  @Builder
  drugNameInputBuilder() {
    TextInput({ text: this.formDrugName, placeholder: '例如：阿司匹林' })
      .height(40)
      .backgroundColor('#fff')
      .border({ width: 1, color: '#d1d5db' })
      .borderRadius(8)
      .onChange((v) => {
        this.formDrugName = v
      })
  }

  @Builder
  dosageInputBuilder() {
    TextInput({ text: this.formDosage, placeholder: '例如：100mg' })
      .height(40)
      .backgroundColor('#fff')
      .border({ width: 1, color: '#d1d5db' })
      .borderRadius(8)
      .onChange((v) => {
        this.formDosage = v
      })
  }

  @Builder
  frequencyInputBuilder() {
    TextInput({ text: this.formFrequencyType, placeholder: '例如：每日一次' })
      .height(40)
      .backgroundColor('#fff')
      .border({ width: 1, color: '#d1d5db' })
      .borderRadius(8)
      .onChange((v) => {
        this.formFrequencyType = v
      })
  }

  @Builder
  exerciseNameInputBuilder() {
    TextInput({ text: this.formExerciseName, placeholder: '例如：下肢力量训练' })
      .height(40)
      .backgroundColor('#fff')
      .border({ width: 1, color: '#d1d5db' })
      .borderRadius(8)
      .onChange((v) => {
        this.formExerciseName = v
      })
  }

  @Builder
  exerciseTypeInputBuilder() {
    TextInput({ text: this.formExerciseType, placeholder: '例如：力量' })
      .height(40)
      .backgroundColor('#fff')
      .border({ width: 1, color: '#d1d5db' })
      .borderRadius(8)
      .onChange((v) => {
        this.formExerciseType = v
      })
  }

  @Builder
  scheduleTypeBuilder() {
    Row({ space: 6 }) {
      Button('一次')
        .type(ButtonType.Normal)
        .height(32)
        .borderRadius(16)
        .fontSize(13)
        .backgroundColor(this.formScheduleType === 'ONCE' ? '#2563eb' : '#fff')
        .fontColor(this.formScheduleType === 'ONCE' ? '#fff' : '#374151')
        .border({ width: 1, color: this.formScheduleType === 'ONCE' ? '#2563eb' : '#d1d5db' })
        .onClick(() => {
          this.formScheduleType = 'ONCE'
        })
      Button('每天')
        .type(ButtonType.Normal)
        .height(32)
        .borderRadius(16)
        .fontSize(13)
        .backgroundColor(this.formScheduleType === 'DAILY' ? '#2563eb' : '#fff')
        .fontColor(this.formScheduleType === 'DAILY' ? '#fff' : '#374151')
        .border({ width: 1, color: this.formScheduleType === 'DAILY' ? '#2563eb' : '#d1d5db' })
        .onClick(() => {
          this.formScheduleType = 'DAILY'
        })
      Button('每周')
        .type(ButtonType.Normal)
        .height(32)
        .borderRadius(16)
        .fontSize(13)
        .backgroundColor(this.formScheduleType === 'WEEKLY' ? '#2563eb' : '#fff')
        .fontColor(this.formScheduleType === 'WEEKLY' ? '#fff' : '#374151')
        .border({ width: 1, color: this.formScheduleType === 'WEEKLY' ? '#2563eb' : '#d1d5db' })
        .onClick(() => {
          this.formScheduleType = 'WEEKLY'
        })
    }
  }

  @Builder
  weekdaysBuilder() {
    Row({ space: 4 }) {
      ForEach(this.weekDayLabels, (label: string, idx: number) => {
        Text(label)
          .fontSize(13)
          .width(32)
          .height(32)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.formSelectedWeekdays[idx] ? '#2563eb' : '#fff')
          .fontColor(this.formSelectedWeekdays[idx] ? '#fff' : '#374151')
          .border({ width: 1, color: this.formSelectedWeekdays[idx] ? '#2563eb' : '#d1d5db' })
          .borderRadius(16)
          .onClick(() => {
            this.toggleWeekday(idx)
          })
      })
    }
  }

  @Builder
  scheduleStartBuilder() {
    Row() {
      Text(this.formScheduleStartDate ? dayjs(this.formScheduleStartDate).format('YYYY-MM-DD') : '请选择')
        .fontSize(14).fontColor(this.formScheduleStartDate ? '#1e293b' : '#9ca3af').layoutWeight(1)
      Text('📅').fontSize(14)
    }
    .height(40)
    .padding({ left: 12, right: 12 })
    .backgroundColor('#fff')
    .border({ width: 1, color: '#d1d5db' })
    .borderRadius(8)
    .onClick(() => {
      DatePickerDialog.show({
        selected: this.formScheduleStartDate || new Date(),
        onAccept: (r: DatePickerResult) => {
          this.formScheduleStartDate = new Date(r.year, r.month, r.day)
        }
      })
    })
  }

  @Builder
  scheduleEndBuilder() {
    Row() {
      Text(this.formScheduleEndDate ? dayjs(this.formScheduleEndDate).format('YYYY-MM-DD') : '请选择')
        .fontSize(14).fontColor(this.formScheduleEndDate ? '#1e293b' : '#9ca3af').layoutWeight(1)
      Text('📅').fontSize(14)
    }
    .height(40)
    .padding({ left: 12, right: 12 })
    .backgroundColor('#fff')
    .border({ width: 1, color: '#d1d5db' })
    .borderRadius(8)
    .onClick(() => {
      DatePickerDialog.show({
        selected: this.formScheduleEndDate || new Date(),
        onAccept: (r: DatePickerResult) => {
          this.formScheduleEndDate = new Date(r.year, r.month, r.day)
        }
      })
    })
  }

  @Builder
  scheduleTimesBuilder() {
    Column() {
      ForEach(this.formScheduleTimes, (time: string, idx: number) => {
        Row() {
          Row() {
            Text(time).fontSize(14).fontColor('#1e293b')
          }
          .layoutWeight(1)
          .height(36)
          .padding({ left: 12 })
          .backgroundColor('#fff')
          .border({ width: 1, color: '#d1d5db' })
          .borderRadius(8)
          .onClick(() => {
            TimePickerDialog.show({
              useMilitaryTime: true,
              selected: new Date(`2000-01-01T${time}:00`),
              onAccept: (val: TimePickerResult) => {
                const h = val.hour.toString().padStart(2, '0')
                const m = val.minute.toString().padStart(2, '0')
                this.updateFormTime(idx, `${h}:${m}`)
              }
            })
          })

          if (this.formScheduleTimes.length > 1) {
            Text('✕').fontSize(16).fontColor('#dc2626').padding({ left: 8 }).onClick(() => {
              this.removeFormTime(idx)
            })
          }
        }.width('100%').margin({ bottom: 6 })
      }, (t: string, i: number) => `${i}-${t}`)
      Text('+ 添加时间').fontSize(13).fontColor('#2563eb').margin({ top: 4 })
        .onClick(() => {
          this.addFormTime()
        })
    }
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            // 类型选择
            Row({ space: 12 }) {
              Button('💊 用药')
                .type(ButtonType.Normal)
                .layoutWeight(1)
                .height(40)
                .borderRadius(20)
                .backgroundColor(this.formItemType === 'MEDICATION' ? '#2563eb' : '#fff')
                .fontColor(this.formItemType === 'MEDICATION' ? '#fff' : '#374151')
                .border({ width: 1, color: this.formItemType === 'MEDICATION' ? '#2563eb' : '#e2e8f0' })
                .onClick(() => {
                  this.formItemType = 'MEDICATION'
                })
              Button('🏃 康复')
                .type(ButtonType.Normal)
                .layoutWeight(1)
                .height(40)
                .borderRadius(20)
                .backgroundColor(this.formItemType === 'REHAB' ? '#2563eb' : '#fff')
                .fontColor(this.formItemType === 'REHAB' ? '#fff' : '#374151')
                .border({ width: 1, color: this.formItemType === 'REHAB' ? '#2563eb' : '#e2e8f0' })
                .onClick(() => {
                  this.formItemType = 'REHAB'
                })
            }.width('100%').margin({ bottom: 20 })

            // 基本信息
            Text('基本信息').fontSize(15).fontWeight(FontWeight.Medium).fontColor('#1e293b').margin({ bottom: 12 })
            FormRow({
              label: '名称', required: true, content: () => {
                this.nameInputBuilder()
              }
            })

            // 详细信息
            Text(this.formItemType === 'MEDICATION' ? '用药详情' : '训练详情')
              .fontSize(15).fontWeight(FontWeight.Medium).fontColor('#1e293b').margin({ top: 8, bottom: 12 })

            if (this.formItemType === 'MEDICATION') {
              FormRow({
                label: '药品名称', required: true, content: () => {
                  this.drugNameInputBuilder()
                }
              })
              FormRow({
                label: '剂量', required: true, content: () => {
                  this.dosageInputBuilder()
                }
              })
              FormRow({
                label: '频次', required: true, content: () => {
                  this.frequencyInputBuilder()
                }
              })
            } else {
              FormRow({
                label: '训练名称', required: true, content: () => {
                  this.exerciseNameInputBuilder()
                }
              })
              FormRow({
                label: '训练类型', required: false, content: () => {
                  this.exerciseTypeInputBuilder()
                }
              })
            }

            // 日程设置
            Text('日程设置')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1e293b')
              .margin({ top: 8, bottom: 12 })
            FormRow({
              label: '日程类型', required: true, content: () => {
                this.scheduleTypeBuilder()
              }
            })

            if (this.formScheduleType === 'WEEKLY') {
              FormRow({
                label: '重复星期', required: true, content: () => {
                  this.weekdaysBuilder()
                }
              })
            }

            FormRow({
              label: '日程开始', required: true, content: () => {
                this.scheduleStartBuilder()
              }
            })

            FormRow({
              label: '日程结束', required: true, content: () => {
                this.scheduleEndBuilder()
              }
            })

            // 执行时间
            FormRow({
              label: '执行时间', required: true, content: () => {
                this.scheduleTimesBuilder()
              }
            })

            Blank().height(24)
            Button(this.formIsSubmitting ? '提交中...' : '创建计划项')
              .type(ButtonType.Capsule)
              .width('100%')
              .height(48)
              .backgroundColor('#2563eb')
              .fontSize(16)
              .onClick(() => {
                this.submitItemForm()
              })
              .enabled(!this.formIsSubmitting)
            Blank().height(24)
          }.padding(16)
        }.layoutWeight(1)
      }.width('100%').height('100%').backgroundColor('#f8fafc')
    }
    .title('新建计划项')
    .onReady((ctx: NavDestinationContext) => {
      const params = ctx.pathInfo.param as PlanItemFormRouteParams
      if (params && params.planId) {
        this.planId = params.planId
      }
    })
  }
}
