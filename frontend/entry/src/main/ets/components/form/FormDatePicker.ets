/**
 * 统一日期选择器卡片组件
 * 点击弹出日期选择对话框
 */
import dayjs from 'dayjs'

@Component
export struct FormDatePicker {
  @Prop label: string = ''
  @Prop optional: boolean = false
  @Link value: Date | null

  private formatDate(): string {
    if (!this.value) {
      return this.optional ? '未设置' : '请选择'
    }
    return dayjs(this.value).format('YYYY-MM-DD')
  }

  private showPicker(): void {
    DatePickerDialog.show({
      start: new Date('2000-01-01'),
      end: new Date('2100-12-31'),
      selected: this.value || new Date(),
      onAccept: (result: DatePickerResult) => {
        const d = new Date()
        d.setFullYear(result.year, result.month, result.day)
        d.setHours(0, 0, 0, 0)
        this.value = d
      }
    })
  }

  build() {
    Column() {
      // 标签
      Row() {
        Text(this.label)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#374151')
        if (this.optional) {
          Text(' (可选)')
            .fontSize(12)
            .fontColor('#9ca3af')
        }
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 日期卡片
      Row() {
        Text(this.formatDate())
          .fontSize(15)
          .fontColor(this.value ? '#111827' : '#9ca3af')
          .layoutWeight(1)

        Row() {
          if (this.value && this.optional) {
            Text('清除')
              .fontSize(13)
              .fontColor('#dc2626')
              .margin({ right: 12 })
              .onClick(() => {
                this.value = null
              })
          }
          Text('📅')
            .fontSize(18)
        }
      }
      .width('100%')
      .height(48)
      .padding({ left: 14, right: 14 })
      .backgroundColor('#f8fafc')
      .borderRadius(12)
      .onClick(() => {
        this.showPicker()
      })
    }
    .width('100%')
    .margin({ bottom: 16 })
  }
}
