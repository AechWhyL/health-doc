@Component
export struct CareCard {
  @Builder
  private defaultContent() {
  }

  @BuilderParam content: () => void = this.defaultContent

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .padding({
      left: 12,
      right: 12,
      top: 12,
      bottom: 10
    })
    .borderRadius(18)
    .backgroundColor(Color.White)
    .shadow({
      radius: 8,
      color: '#14182614',
      offsetY: 4
    })
    .margin({ bottom: 10 })
  }
}

