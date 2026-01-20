/**
 * 统一下拉选择卡片组件
 */

interface SelectItem {
  value: string
  label: string
}

@Component
export struct FormSelect {
  @Prop label: string = ''
  @Prop options: SelectItem[] = []
  @Link selectedValue: string

  private getSelectedLabel(): string {
    const item = this.options.find(opt => opt.value === this.selectedValue)
    return item ? item.label : '请选择'
  }

  private getSelectedIndex(): number {
    return this.options.findIndex(opt => opt.value === this.selectedValue)
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

      // 选择器
      Select(this.options.map(opt => {
        const selOpt: SelectOption = { value: opt.label }
        return selOpt
      }))
        .selected(this.getSelectedIndex() >= 0 ? this.getSelectedIndex() : 0)
        .value(this.getSelectedLabel())
        .font({ size: 15, weight: 400 })
        .fontColor('#111827')
        .selectedOptionFont({ size: 15, weight: 500 })
        .optionFont({ size: 15, weight: 400 })
        .onSelect((index: number) => {
          if (index >= 0 && index < this.options.length) {
            this.selectedValue = this.options[index].value
          }
        })
        .width('100%')
        .height(48)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
    }
    .width('100%')
    .margin({ bottom: 16 })
  }
}
