/**
 * 统一时间选择器卡片组件
 */

@Component
export struct FormTimePicker {
  @Prop label: string = ''
  @Link value: string // 格式 HH:mm

  private showPicker(): void {
    const parts = this.value.split(':')
    const hour = parts.length >= 1 ? parseInt(parts[0]) : 8
    const minute = parts.length >= 2 ? parseInt(parts[1]) : 0

    TimePickerDialog.show({
      selected: new Date(2000, 0, 1, hour, minute),
      useMilitaryTime: true,
      onAccept: (result: TimePickerResult) => {
        this.value = `${result.hour.toString().padStart(2, '0')}:${result.minute.toString().padStart(2, '0')}`
      }
    })
  }

  build() {
    Column() {
      // 标签
      Text(this.label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#374151')
        .width('100%')
        .margin({ bottom: 8 })

      // 时间卡片
      Row() {
        Text(this.value || '请选择')
          .fontSize(15)
          .fontColor(this.value ? '#111827' : '#9ca3af')
          .layoutWeight(1)

        Text('🕐')
          .fontSize(18)
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
