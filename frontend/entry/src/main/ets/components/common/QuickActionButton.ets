/**
 * 快捷操作按钮组件
 * 图标 + 文字，支持自定义颜色
 */

@Component
export struct QuickActionButton {
  @Prop icon: string = ''
  @Prop label: string = ''
  @Prop color: string = '#2563eb'
  @Prop bgColor: string = '#eff6ff'
  onPress: () => void = () => {}

  build() {
    Column() {
      Text(this.icon)
        .fontSize(20)
        .fontColor(this.color)
      Text(this.label)
        .fontSize(11)
        .fontColor(this.color)
        .margin({ top: 4 })
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(this.bgColor)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.onPress()
    })
  }
}
