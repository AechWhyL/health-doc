/**
 * 空状态占位组件
 * 图标 + 提示文字 + 可选操作按钮
 */

@Component
export struct EmptyState {
  @Prop icon: string = '📋'
  @Prop title: string = '暂无数据'
  @Prop subtitle: string = ''
  @Prop actionText: string = ''
  onAction: () => void = () => {}

  build() {
    Column() {
      Text(this.icon)
        .fontSize(48)
        .margin({ bottom: 12 })
      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#374151')
      if (this.subtitle) {
        Text(this.subtitle)
          .fontSize(13)
          .fontColor('#9ca3af')
          .margin({ top: 6 })
          .textAlign(TextAlign.Center)
      }
      if (this.actionText) {
        Button(this.actionText)
          .type(ButtonType.Capsule)
          .height(36)
          .fontSize(14)
          .backgroundColor('#2563eb')
          .margin({ top: 16 })
          .onClick(() => {
            this.onAction()
          })
      }
    }
    .width('100%')
    .padding(32)
    .alignItems(HorizontalAlign.Center)
  }
}
