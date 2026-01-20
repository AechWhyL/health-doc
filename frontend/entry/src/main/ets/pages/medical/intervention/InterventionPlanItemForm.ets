import { promptAction } from '@kit.ArkUI';
import { InterventionService } from '../../../common/api/InterventionService';
import {
  CreatePlanItemRequest,
  CreatePlanItemScheduleRequest,
  PlanItemType,
  MedicationDetail,
  RehabDetail
} from '../../../models/DTO/intervention';
import dayjs from 'dayjs';
import { CardContainer } from '../../../components/common/CardContainer';

export interface PlanItemFormRouteParams {
  planId: number;
}

@Component
export struct InterventionPlanItemForm {
  @State planId: number = 0
  @State itemType: PlanItemType = 'MEDICATION'
  @State name: string = ''
  @State description: string = ''
  @State startDate: Date | null = new Date()
  @State endDate: Date | null = null
  // Medication
  @State drugName: string = ''
  @State dosage: string = ''
  @State frequencyType: string = ''
  @State instructions: string = ''
  // Rehab
  @State exerciseName: string = ''
  @State exerciseType: string = ''
  @State guideUrl: string = ''
  // Schedule
  @State scheduleType: string = 'DAILY'
  @State scheduleTimes: string[] = ['08:00']
  @State scheduleStartDate: Date | null = new Date()
  @State scheduleEndDate: Date | null = null
  @State selectedWeekdays: boolean[] = [false, false, false, false, false, false, false]
  @State isSubmitting: boolean = false
  @Consume('navPathStack') navPathStack: NavPathStack;

  private weekDayLabels: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  private addTime(): void {
    if (this.scheduleTimes.length < 6) {
      this.scheduleTimes = this.scheduleTimes.concat(['12:00'])
    }
  }

  private removeTime(index: number): void {
    if (this.scheduleTimes.length > 1) {
      const newTimes: string[] = []
      for (let i = 0; i < this.scheduleTimes.length; i++) {
        if (i !== index) {
          newTimes.push(this.scheduleTimes[i])
        }
      }
      this.scheduleTimes = newTimes
    }
  }

  private updateTime(index: number, value: string): void {
    const newTimes: string[] = []
    for (let i = 0; i < this.scheduleTimes.length; i++) {
      if (i === index) {
        newTimes.push(value)
      } else {
        newTimes.push(this.scheduleTimes[i])
      }
    }
    this.scheduleTimes = newTimes
  }

  private async submit() {
    if (!this.name.trim()) {
      promptAction.showToast({ message: '请输入计划项名称' });
      return;
    }
    if (!this.startDate) {
      promptAction.showToast({ message: '请选择计划项开始日期' });
      return;
    }
    if (!this.scheduleStartDate) {
      promptAction.showToast({ message: '请选择日程开始日期' });
      return;
    }
    if (this.itemType === 'MEDICATION' && (!this.drugName || !this.dosage || !this.frequencyType)) {
      promptAction.showToast({ message: '请完善用药信息' });
      return;
    }
    if (this.itemType === 'REHAB' && !this.exerciseName) {
      promptAction.showToast({ message: '请输入训练名称' });
      return;
    }
    if (this.scheduleTimes.length === 0) {
      promptAction.showToast({ message: '请至少添加一个执行时间' });
      return;
    }
    if (this.scheduleType === 'WEEKLY') {
      const hasSelected = this.selectedWeekdays.some(selected => selected);
      if (!hasSelected) {
        promptAction.showToast({ message: '请至少选择一个星期' });
        return;
      }
    }

    this.isSubmitting = true;
    try {
      const itemRequest: CreatePlanItemRequest = {
        itemType: this.itemType,
        name: this.name,
        description: this.description,
        startDate: dayjs(this.startDate).format('YYYY-MM-DD'),
        endDate: this.endDate ? dayjs(this.endDate).format('YYYY-MM-DD') : null
      };

      if (this.itemType === 'MEDICATION') {
        const detail: MedicationDetail = {
          drug_name: this.drugName,
          dosage: this.dosage,
          frequency_type: this.frequencyType,
          instructions: this.instructions
        };
        itemRequest.medicationDetail = detail;
      } else {
        const detail: RehabDetail = {
          exercise_name: this.exerciseName,
          exercise_type: this.exerciseType,
          guide_resource_url: this.guideUrl
        };
        itemRequest.rehabDetail = detail;
      }

      const itemResponse = await InterventionService.createPlanItem(this.planId, itemRequest);
      if (itemResponse.code !== 200 || !itemResponse.data) {
        throw new Error(itemResponse.message || '创建计划项失败');
      }

      const itemId = itemResponse.data.id;

      const scheduleRequest: CreatePlanItemScheduleRequest = {
        scheduleType: this.scheduleType as 'ONCE' | 'DAILY' | 'WEEKLY',
        startDate: dayjs(this.scheduleStartDate).format('YYYY-MM-DD'),
        endDate: this.scheduleEndDate ? dayjs(this.scheduleEndDate).format('YYYY-MM-DD') : null,
        timesOfDay: this.scheduleTimes
      };

      if (this.scheduleType === 'WEEKLY') {
        const weekdays: number[] = []
        for (let i = 0; i < this.selectedWeekdays.length; i++) {
          if (this.selectedWeekdays[i]) {
            weekdays.push(i + 1)
          }
        }
        scheduleRequest.weekdays = weekdays
      }

      const scheduleResponse = await InterventionService.createPlanItemSchedule(itemId, scheduleRequest);
      if (scheduleResponse.code !== 200) {
        promptAction.showToast({ message: '计划项创建成功，但日程设置失败' });
      } else {
        promptAction.showToast({ message: '创建成功' });
      }

      this.navPathStack.pop();
    } catch (e) {
      promptAction.showToast({ message: e.message || '网络异常' });
    } finally {
      this.isSubmitting = false;
    }
  }

  @Builder
  buildInput(label: string, placeholder: string, text: string, required: boolean, onChange: (val: string) => void) {
    Column() {
      Row() {
        Text(label).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#374151')
        if (required) {
          Text(' *').fontSize(14).fontColor('#dc2626')
        }
      }.width('100%').margin({ bottom: 8 })

      TextInput({ text: text, placeholder: placeholder })
        .height(48)
        .fontSize(15)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
        .onChange(onChange)
    }.width('100%').margin({ bottom: 16 })
  }

  @Builder
  buildTextArea(label: string, placeholder: string, text: string, onChange: (val: string) => void) {
    Column() {
      Text(label).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#374151').margin({ bottom: 8 })
      TextArea({ text: text, placeholder: placeholder })
        .height(100)
        .fontSize(15)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
        .onChange(onChange)
    }.width('100%').margin({ bottom: 16 })
  }

  @Builder
  buildDatePicker(label: string, value: Date | null, optional: boolean, onSelect: (date: Date) => void) {
    Column() {
      Row() {
        Text(label).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#374151')
        if (optional) {
          Text(' (可选)').fontSize(12).fontColor('#9ca3af')
        }
      }.width('100%').margin({ bottom: 8 })

      Row() {
        Text(value ? dayjs(value).format('YYYY-MM-DD') : '请选择日期')
          .fontSize(15)
          .fontColor(value ? '#1e293b' : '#9ca3af')
          .layoutWeight(1)
        Text('📅').fontSize(16)
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#f8fafc')
      .borderRadius(12)
      .onClick(() => {
        DatePickerDialog.show({
          selected: value || new Date(),
          onAccept: (result: DatePickerResult) => {
            const newDate = new Date(result.year, result.month, result.day)
            onSelect(newDate)
          }
        })
      })
    }.width('100%').margin({ bottom: 16 })
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            // 类型选择
            Row() {
              Button('用药计划')
                .type(ButtonType.Normal)
                .backgroundColor(this.itemType === 'MEDICATION' ? '#2563eb' : '#e2e8f0')
                .fontColor(this.itemType === 'MEDICATION' ? '#ffffff' : '#64748b')
                .borderRadius(20)
                .height(36)
                .onClick(() => { this.itemType = 'MEDICATION' })
                .layoutWeight(1)
                .margin({ right: 12 })

              Button('康复计划')
                .type(ButtonType.Normal)
                .backgroundColor(this.itemType === 'REHAB' ? '#2563eb' : '#e2e8f0')
                .fontColor(this.itemType === 'REHAB' ? '#ffffff' : '#64748b')
                .borderRadius(20)
                .height(36)
                .onClick(() => { this.itemType = 'REHAB' })
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 20 })

            // 基本信息
            CardContainer({ title: '基本信息' }) {
              Column() {
                this.buildInput('名称', '计划项名称', this.name, true, (val) => { this.name = val })
                this.buildTextArea('说明', '计划项说明（可选）', this.description, (val) => { this.description = val })
                this.buildDatePicker('计划项开始日期', this.startDate, false, (d) => { this.startDate = d })
                this.buildDatePicker('计划项结束日期', this.endDate, true, (d) => { this.endDate = d })
              }
            }

            // 详细信息
            CardContainer({ title: this.itemType === 'MEDICATION' ? '用药详情' : '训练详情' }) {
              Column() {
                if (this.itemType === 'MEDICATION') {
                  this.buildInput('药品名称', '例如：阿司匹林', this.drugName, true, (val) => { this.drugName = val })
                  this.buildInput('剂量', '例如：100mg', this.dosage, true, (val) => { this.dosage = val })
                  this.buildInput('频次描述', '例如：每日一次', this.frequencyType, true, (val) => { this.frequencyType = val })
                  this.buildTextArea('用药指示', '例如：饭后服用', this.instructions, (val) => { this.instructions = val })
                } else {
                  this.buildInput('训练名称', '例如：下肢力量训练', this.exerciseName, true, (val) => { this.exerciseName = val })
                  this.buildInput('训练类型', '例如：力量', this.exerciseType, false, (val) => { this.exerciseType = val })
                  this.buildInput('指导链接', 'https://...', this.guideUrl, false, (val) => { this.guideUrl = val })
                }
              }
            }

            // 日程设置
            CardContainer({ title: '日程设置' }) {
              Column() {
                // 日程类型
                Column() {
                  Text('日程类型').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#374151').margin({ bottom: 8 })
                  Row({ space: 8 }) {
                    Button('一次性')
                      .type(ButtonType.Normal)
                      .backgroundColor(this.scheduleType === 'ONCE' ? '#2563eb' : '#f1f5f9')
                      .fontColor(this.scheduleType === 'ONCE' ? '#fff' : '#64748b')
                      .borderRadius(16)
                      .height(32)
                      .onClick(() => { this.scheduleType = 'ONCE' })
                    Button('每天')
                      .type(ButtonType.Normal)
                      .backgroundColor(this.scheduleType === 'DAILY' ? '#2563eb' : '#f1f5f9')
                      .fontColor(this.scheduleType === 'DAILY' ? '#fff' : '#64748b')
                      .borderRadius(16)
                      .height(32)
                      .onClick(() => { this.scheduleType = 'DAILY' })
                    Button('每周')
                      .type(ButtonType.Normal)
                      .backgroundColor(this.scheduleType === 'WEEKLY' ? '#2563eb' : '#f1f5f9')
                      .fontColor(this.scheduleType === 'WEEKLY' ? '#fff' : '#64748b')
                      .borderRadius(16)
                      .height(32)
                      .onClick(() => { this.scheduleType = 'WEEKLY' })
                  }
                }.width('100%').margin({ bottom: 16 }).alignItems(HorizontalAlign.Start)

                this.buildDatePicker('日程开始日期', this.scheduleStartDate, false, (d) => { this.scheduleStartDate = d })

                if (this.scheduleType !== 'ONCE') {
                  this.buildDatePicker('日程结束日期', this.scheduleEndDate, true, (d) => { this.scheduleEndDate = d })
                }

                if (this.scheduleType === 'WEEKLY') {
                  Text('重复周期').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#374151').margin({ bottom: 8 })
                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.weekDayLabels, (label: string, index: number) => {
                      Row() {
                        Checkbox({ name: label, group: 'weekdays' })
                          .select(this.selectedWeekdays[index])
                          .onChange((value: boolean) => { this.selectedWeekdays[index] = value })
                        Text(label).fontSize(14).margin({ left: 4 })
                      }.width('25%').margin({ bottom: 8 })
                    })
                  }.margin({ bottom: 16 })
                }

                // 多时间点
                Row() {
                  Text('执行时间').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#374151').layoutWeight(1)
                  Button('+ 添加').type(ButtonType.Normal).fontSize(12).height(28).backgroundColor('#eff6ff').fontColor('#2563eb').borderRadius(14)
                    .onClick(() => { this.addTime() }).enabled(this.scheduleTimes.length < 6)
                }.width('100%').margin({ bottom: 8 })

                ForEach(this.scheduleTimes, (time: string, index: number) => {
                  Row() {
                    Text(`时间${index + 1}`).fontSize(13).fontColor('#64748b').width(50)
                    Row() {
                      Text(time).fontSize(14).fontColor('#1e293b')
                    }.layoutWeight(1).padding(10).backgroundColor('#f8fafc').borderRadius(8)
                    .onClick(() => {
                      TimePickerDialog.show({
                        useMilitaryTime: true,
                        selected: new Date(`2000-01-01T${time}:00`),
                        onAccept: (val: TimePickerResult) => {
                          const h = val.hour.toString().padStart(2, '0')
                          const m = val.minute.toString().padStart(2, '0')
                          this.updateTime(index, `${h}:${m}`)
                        }
                      })
                    })
                    if (this.scheduleTimes.length > 1) {
                      Text('✕').fontSize(16).fontColor('#dc2626').padding(8).onClick(() => { this.removeTime(index) })
                    }
                  }.width('100%').padding({ top: 4, bottom: 4 })
                }, (time: string, index: number) => `${index}-${time}`)
              }
            }

            Button(this.isSubmitting ? '提交中...' : '创建计划项')
              .type(ButtonType.Capsule)
              .width('100%')
              .height(48)
              .backgroundColor('#2563eb')
              .fontSize(16)
              .onClick(() => { this.submit() })
              .enabled(!this.isSubmitting)
              .margin({ top: 12, bottom: 20 })
          }
          .padding(16)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f8fafc')
    }
    .title('新建计划项')
    .onReady((ctx: NavDestinationContext) => {
      const params = ctx.pathInfo.param as PlanItemFormRouteParams;
      if (params && params.planId) {
        this.planId = params.planId;
      }
    })
  }
}
