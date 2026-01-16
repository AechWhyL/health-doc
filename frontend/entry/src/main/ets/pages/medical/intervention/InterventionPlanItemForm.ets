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

export interface PlanItemFormRouteParams {
  planId: number;
}

type IScheduleType = "ONCE" | "DAILY" | "WEEKLY"

@Component
export struct InterventionPlanItemForm {
  @State planId: number = 0
  @State itemType: PlanItemType = 'MEDICATION'
  @State name: string = ''
  @State description: string = ''
  @State startDate: Date = new Date()
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
  @State scheduleType: string = 'DAILY' // ONCE, DAILY, WEEKLY
  @State scheduleTime: string = '08:00'
  @State selectedWeekdays: boolean[] =
    [false, false, false, false, false, false, false] // Mon-Sun (Indices 0-6 map to 1-7)
  @State isSubmitting: boolean = false
  @Consume('navPathStack') navPathStack: NavPathStack;
  private weekDayLabels: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  private scheduleTypeOptions: SelectOption[] = [
    { value: '一次性' },
    { value: '每日' },
    { value: '每周' }
  ];

  private async submit() {
    if (!this.name.trim()) {
      promptAction.showToast({ message: '请输入计划项名称' });
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

    // Validate Schedule
    if (this.scheduleType === 'WEEKLY') {
      const hasSelected = this.selectedWeekdays.some(selected => selected);
      if (!hasSelected) {
        promptAction.showToast({ message: '请至少选择一个星期' });
        return;
      }
    }

    this.isSubmitting = true;
    try {
      // 1. Create Item
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

      // 2. Create Schedule
      const scheduleRequest: CreatePlanItemScheduleRequest = {
        scheduleType: this.scheduleType as 'ONCE' | 'DAILY' | 'WEEKLY',
        startDate: itemRequest.startDate,
        endDate: itemRequest.endDate || itemRequest.startDate, // ONCE might not have endDate, default to startDate
        timesOfDay: [this.scheduleTime]
      };

      if (this.scheduleType === 'WEEKLY') {
        // Map boolean array to 1-7
        scheduleRequest.weekdays = this.selectedWeekdays
          .map((selected, index) => selected ? index + 1 : 0)
          .filter(day => day !== 0);
      }

      const scheduleResponse = await InterventionService.createPlanItemSchedule(itemId, scheduleRequest);
      console.log(scheduleRequest.scheduleType.toString())
      if (scheduleResponse.code !== 200) {
        console.error('Schedule creation failed', scheduleResponse.message);
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

  build() {

      Flex({
        direction: FlexDirection.Column,
      }) {
        // Header
        Row() {
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#ffffff')
        .border({ width: { bottom: 1 }, color: '#e5e7eb' })

        Scroll() {
          Column() {
            // Type Selection
            Row() {
              Button('用药计划')
                .type(ButtonType.Normal)
                .backgroundColor(this.itemType === 'MEDICATION' ? '#2563eb' : '#f3f4f6')
                .fontColor(this.itemType === 'MEDICATION' ? '#ffffff' : '#374151')
                .borderRadius(4)
                .onClick(() => this.itemType = 'MEDICATION')
                .layoutWeight(1)
                .margin({ right: 8 })

              Button('康复计划')
                .type(ButtonType.Normal)
                .backgroundColor(this.itemType === 'REHAB' ? '#2563eb' : '#f3f4f6')
                .fontColor(this.itemType === 'REHAB' ? '#ffffff' : '#374151')
                .borderRadius(4)
                .onClick(() => this.itemType = 'REHAB')
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 16 })

            // Name
            Text('名称')
              .fontSize(14)
              .margin({ bottom: 6 })
            TextInput({ placeholder: '计划项名称', text: this.name })
              .onChange((value) => this.name = value)
              .width('100%')
              .height(40)
              .margin({ bottom: 16 })

            // Description
            Text('说明')
              .fontSize(14)
              .margin({ bottom: 6 })
            TextArea({ placeholder: '计划项说明（可选）', text: this.description })
              .onChange((value) => this.description = value)
              .width('100%')
              .height(60)
              .margin({ bottom: 16 })

            // Start Date
            Text('开始日期')
              .fontSize(14)
              .margin({ bottom: 6 })
            Row() {
              Text(dayjs(this.startDate).format('YYYY-MM-DD'))
                .fontSize(16)
                .fontColor('#111827')

              Image($r('app.media.ic_public_arrow_right')) // Assuming icon exists, or use Text '>'
                .width(16)
                .height(16)
                .fillColor('#9ca3af')
                .visibility(Visibility.Hidden) // Placeholder if no icon
            }
            .width('100%')
            .height(40)
            .padding({ left: 12, right: 12 })
            .backgroundColor('#ffffff')
            .borderRadius(4)
            .border({ width: 1, color: '#e5e7eb' })
            .margin({ bottom: 16 })
            .onClick(() => {
              DatePickerDialog.show({
                start: new Date("2000-1-1"),
                end: new Date("2100-12-31"),
                selected: this.startDate,
                onAccept: (value: DatePickerResult) => {
                  this.startDate.setFullYear(value.year, value.month, value.day)
                }
              })
            })

            // End Date
            Text('结束日期 (可选)')
              .fontSize(14)
              .margin({ bottom: 6 })
            Row() {
              Text(this.endDate ? dayjs(this.endDate).format('YYYY-MM-DD') : '未设置')
                .fontSize(16)
                .fontColor(this.endDate ? '#111827' : '#9ca3af')
            }
            .width('100%')
            .height(40)
            .padding({ left: 12, right: 12 })
            .backgroundColor('#ffffff')
            .borderRadius(4)
            .border({ width: 1, color: '#e5e7eb' })
            .margin({ bottom: 16 })
            .onClick(() => {
              DatePickerDialog.show({
                start: new Date("2000-1-1"),
                end: new Date("2100-12-31"),
                selected: this.endDate || new Date(),
                onAccept: (value: DatePickerResult) => {
                  if (!this.endDate) {
                    this.endDate = new Date();
                  }
                  this.endDate.setFullYear(value.year, value.month, value.day)
                }
              })
            })

            // Specific Fields
            if (this.itemType === 'MEDICATION') {
              Text('药品名称')
                .fontSize(14)
                .margin({ bottom: 6 })
              TextInput({ placeholder: '例如：阿司匹林', text: this.drugName })
                .onChange((value) => this.drugName = value)
                .width('100%')
                .height(40)
                .margin({ bottom: 16 })

              Text('剂量')
                .fontSize(14)
                .margin({ bottom: 6 })
              TextInput({ placeholder: '例如：100mg', text: this.dosage })
                .onChange((value) => this.dosage = value)
                .width('100%')
                .height(40)
                .margin({ bottom: 16 })

              Text('频次描述')
                .fontSize(14)
                .margin({ bottom: 6 })
              TextInput({ placeholder: '例如：每日一次', text: this.frequencyType })
                .onChange((value) => this.frequencyType = value)
                .width('100%')
                .height(40)
                .margin({ bottom: 16 })

              Text('用药指示')
                .fontSize(14)
                .margin({ bottom: 6 })
              TextArea({ placeholder: '例如：饭后服用', text: this.instructions })
                .onChange((value) => this.instructions = value)
                .width('100%')
                .height(60)
                .margin({ bottom: 16 })
            } else {
              Text('训练名称')
                .fontSize(14)
                .margin({ bottom: 6 })
              TextInput({ placeholder: '例如：下肢力量训练', text: this.exerciseName })
                .onChange((value) => this.exerciseName = value)
                .width('100%')
                .height(40)
                .margin({ bottom: 16 })

              Text('训练类型')
                .fontSize(14)
                .margin({ bottom: 6 })
              TextInput({ placeholder: '例如：力量', text: this.exerciseType })
                .onChange((value) => this.exerciseType = value)
                .width('100%')
                .height(40)
                .margin({ bottom: 16 })

              Text('指导链接 (可选)')
                .fontSize(14)
                .margin({ bottom: 6 })
              TextInput({ placeholder: 'https://...', text: this.guideUrl })
                .onChange((value) => this.guideUrl = value)
                .width('100%')
                .height(40)
                .margin({ bottom: 16 })
            }

            Divider().margin({ bottom: 16 })
            Text('日程设置').fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 16 })

            // Schedule Type
            Text('日程类型')
              .fontSize(14)
              .margin({ bottom: 6 })
            Select(this.scheduleTypeOptions)
              .selected(this.scheduleType === 'ONCE' ? 0 : (this.scheduleType === 'DAILY' ? 1 : 2))
              .value(this.scheduleType === 'ONCE' ? '一次性' : (this.scheduleType === 'DAILY' ? '每天' : '每周'))
              .font({ size: 16, weight: 400 })
              .fontColor('#111827')
              .selectedOptionFont({ size: 16, weight: 400 })
              .optionFont({ size: 16, weight: 400 })
              .onSelect((index: number, value: string) => {
                if (index === 0) {
                  this.scheduleType = 'ONCE';
                } else if (index === 1) {
                  this.scheduleType =
                    'DAILY';
                } else if (index === 2) {
                  this.scheduleType = 'WEEKLY';
                }
              })
              .width('100%')
              .height(40)
              .margin({ bottom: 16 })
              .backgroundColor('#ffffff')
              .borderRadius(4)

            // Weekdays (Only for WEEKLY)
            if (this.scheduleType === 'WEEKLY') {
              Text('重复周期')
                .fontSize(14)
                .margin({ bottom: 6 })
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.weekDayLabels, (label: string, index: number) => {
                  Row() {
                    Checkbox({ name: label, group: 'weekdays' })
                      .select(this.selectedWeekdays[index])
                      .onChange((value: boolean) => {
                        this.selectedWeekdays[index] = value
                      })
                    Text(label)
                      .fontSize(14)
                      .margin({ left: 4 })
                  }
                  .width('25%')
                  .margin({ bottom: 8 })
                })
              }
              .margin({ bottom: 16 })
            }

            // Schedule Time
            Text('执行时间')
              .fontSize(14)
              .margin({ bottom: 6 })
            Row() {
              Text(this.scheduleTime)
                .fontSize(16)
                .fontColor('#111827')
              Button('选择')
                .fontSize(12)
                .onClick(() => {
                  TimePickerDialog.show({
                    selected: new Date(`2000-01-01T${this.scheduleTime}:00`),
                    useMilitaryTime: true,
                    onAccept: (value: TimePickerResult) => {
                      this.scheduleTime =
                        `${value.hour.toString().padStart(2, '0')}:${value.minute.toString().padStart(2, '0')}`
                    }
                  })
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding(10)
            .backgroundColor('#ffffff')
            .borderRadius(4)
            .margin({ bottom: 16 })
            .border({ width: 1, color: '#e5e7eb' })

            // Submit
            Button(this.isSubmitting ? '提交中...' : '创建计划项')
              .type(ButtonType.Capsule)
              .width('100%')
              .onClick(() => {
                this.submit()
              })
              .enabled(!this.isSubmitting)
          }
          .padding(16)
          .flexGrow(1)
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f9fafb')

    // .onReady((ctx: NavDestinationContext) => {
    //   this.planId = (ctx.pathInfo.param as PlanItemFormRouteParams).planId
    //   console.log(this.planId.toString())
    // })
  }
}
