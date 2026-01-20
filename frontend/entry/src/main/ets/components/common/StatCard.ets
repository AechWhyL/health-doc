/**
 * 统计卡片组件
 * 显示数值和标签，用于概览页面
 */

@Component
export struct StatCard {
  @Prop value: string = '0'
  @Prop label: string = ''
  @Prop icon: string = ''
  @Prop color: string = '#2563eb'
  @Prop bgColor: string = '#eff6ff'

  build() {
    Column() {
      if (this.icon) {
        Text(this.icon)
          .fontSize(24)
          .margin({ bottom: 4 })
      }
      Text(this.value)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.color)
      Text(this.label)
        .fontSize(12)
        .fontColor('#64748b')
        .margin({ top: 4 })
    }
    .padding(16)
    .backgroundColor(this.bgColor)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }
}
