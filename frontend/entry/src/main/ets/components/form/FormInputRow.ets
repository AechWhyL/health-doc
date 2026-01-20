/**
 * 统一表单输入行组件
 * 包含标签和输入框，支持单行和多行模式
 */

@Component
export struct FormInputRow {
  @Prop label: string = ''
  @Prop placeholder: string = ''
  @Prop required: boolean = false
  @Prop multiline: boolean = false
  @Link value: string

  build() {
    Column() {
      // 标签
      Row() {
        Text(this.label)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#374151')
        if (this.required) {
          Text(' *')
            .fontSize(14)
            .fontColor('#dc2626')
        }
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 输入框
      if (this.multiline) {
        TextArea({ text: this.value, placeholder: this.placeholder })
          .height(100)
          .fontSize(15)
          .backgroundColor('#f8fafc')
          .borderRadius(12)
          .onChange((val: string) => {
            this.value = val
          })
      } else {
        TextInput({ text: this.value, placeholder: this.placeholder })
          .height(48)
          .fontSize(15)
          .backgroundColor('#f8fafc')
          .borderRadius(12)
          .onChange((val: string) => {
            this.value = val
          })
      }
    }
    .width('100%')
    .margin({ bottom: 16 })
  }
}
