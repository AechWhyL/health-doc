/**
 * 统一卡片容器组件
 * 提供一致的阴影、圆角和内边距
 */

@Component
export struct CardContainer {
  @Prop title: string = ''
  @BuilderParam content: () => void = this.defaultContent

  @Builder
  defaultContent() {
    // 默认空内容
  }

  build() {
    Column() {
      if (this.title) {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1e293b')
          .margin({ bottom: 16 })
      }
      this.content()
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(14)
    .shadow({ radius: 4, color: '#0f172a0a', offsetY: 1 })
    .margin({ bottom: 12 })
  }
}
