@Component
export struct ElderListItem {
  @Prop elderName: string = '';
  @Prop elderAge: number = 0;
  @Prop relationText: string = '';
  @Prop phoneText: string = '';
  onItemClick: () => void = () => {
  };

  build() {
    Row() {
      Column() {
        Text(this.elderName + ' · ' + this.elderAge + ' 岁')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
        Text(this.relationText + (this.phoneText !== '' ? ' · ' + this.phoneText : ''))
          .fontSize(11)
          .fontColor('#6b7280')
          .margin({ top: 2 })
      }
      .layoutWeight(1)

      Text('查看档案')
        .fontSize(11)
        .fontColor('#16a34a')
    }
    .padding({
      left: 8,
      right: 8,
      top: 6,
      bottom: 6
    })
    .borderRadius(12)
    .backgroundColor('#f9fafb')
    .margin({ bottom: 4 })
    .onClick(() => {
      this.onItemClick();
    })
  }
}
