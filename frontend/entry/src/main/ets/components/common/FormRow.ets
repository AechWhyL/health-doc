/**
 * 表单行组件 - 左侧label，右侧内容
 */
@Component
export struct FormRow {
  @Prop label: string = ''
  @Prop required: boolean = false
  @Builder defaultBuilder() {}
  @BuilderParam content: () => void = this.defaultBuilder

  build() {
    Row() {
      Row() {
        Text(this.label).fontSize(14).fontColor('#374151')
        if (this.required) {
          Text(' *').fontSize(14).fontColor('#dc2626')
        }
      }.width(90)
      Column() {
        this.content()
      }.layoutWeight(1)
    }.width('100%').margin({ bottom: 14 }).alignItems(VerticalAlign.Center)
  }
}
