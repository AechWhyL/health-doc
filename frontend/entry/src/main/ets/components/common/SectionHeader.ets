/**
 * 区域标题组件
 * 支持右侧操作按钮
 */

@Component
export struct SectionHeader {
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop actionText: string = ''
  onAction: () => void = () => {}

  build() {
    Row() {
      Column() {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1e293b')
        if (this.subtitle) {
          Text(this.subtitle)
            .fontSize(12)
            .fontColor('#64748b')
            .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.actionText) {
        Text(this.actionText)
          .fontSize(13)
          .fontColor('#2563eb')
          .onClick(() => {
            this.onAction()
          })
      }
    }
    .width('100%')
    .padding({ top: 8, bottom: 12 })
  }
}
