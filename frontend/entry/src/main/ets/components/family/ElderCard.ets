// 老人健康数据摘要
interface HealthSummary {
  latestSbp?: number;
  latestDbp?: number;
  latestFpg?: number;
  hasWarning: boolean;
  warningText?: string;
}

interface StatusResult {
  text: string;
  color: string;
  icon: string;
}

@Component
export struct ElderCard {
  @Prop elderName: string = '';
  @Prop elderAge: number = 0;
  @Prop elderGender: number = 0; // 0=女, 1=男
  @Prop elderPhone: string = '';
  @Prop relationName: string = '';
  @Prop healthSummary: HealthSummary = { hasWarning: false };
  onCardClick: () => void = () => {};
  onViewArchive: () => void = () => {};

  private getGenderText(): string {
    return this.elderGender === 1 ? '男' : '女';
  }

  private getGenderIcon(): string {
    return this.elderGender === 1 ? '👴' : '👵';
  }

  private formatPhone(): string {
    if (this.elderPhone.length >= 11) {
      return this.elderPhone.substring(0, 3) + '****' + this.elderPhone.substring(7);
    }
    return this.elderPhone;
  }

  private getBpStatus(): StatusResult {
    const sbp = this.healthSummary.latestSbp;
    const dbp = this.healthSummary.latestDbp;
    if (sbp === undefined || dbp === undefined) {
      const result: StatusResult = { text: '暂无数据', color: '#9ca3af', icon: '—' };
      return result;
    }
    if (sbp >= 140 || dbp >= 90) {
      const result: StatusResult = { text: '偏高', color: '#dc2626', icon: '⚠️' };
      return result;
    }
    if (sbp < 90 || dbp < 60) {
      const result: StatusResult = { text: '偏低', color: '#f59e0b', icon: '⚡' };
      return result;
    }
    const result: StatusResult = { text: '正常', color: '#16a34a', icon: '✓' };
    return result;
  }

  private getFpgStatus(): StatusResult {
    const fpg = this.healthSummary.latestFpg;
    if (fpg === undefined) {
      const result: StatusResult = { text: '暂无数据', color: '#9ca3af', icon: '—' };
      return result;
    }
    if (fpg >= 7.0) {
      const result: StatusResult = { text: '偏高', color: '#dc2626', icon: '⚠️' };
      return result;
    }
    if (fpg < 3.9) {
      const result: StatusResult = { text: '偏低', color: '#f59e0b', icon: '⚡' };
      return result;
    }
    const result: StatusResult = { text: '正常', color: '#16a34a', icon: '✓' };
    return result;
  }

  build() {
    Column() {
      // 顶部信息区
      Row() {
        // 头像区域
        Column() {
          Text(this.getGenderIcon())
            .fontSize(32)
        }
        .width(56)
        .height(56)
        .borderRadius(28)
        .backgroundColor('#f1f5f9')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        // 基本信息
        Column() {
          Row() {
            Text(this.elderName)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1e293b')
            Text(' · ' + this.getGenderText() + ' · ' + this.elderAge + '岁')
              .fontSize(14)
              .fontColor('#64748b')
          }

          Text('联系电话：' + this.formatPhone())
            .fontSize(13)
            .fontColor('#94a3b8')
            .margin({ top: 4 })

          if (this.relationName && this.relationName !== '') {
            Text('关系：' + this.relationName)
              .fontSize(12)
              .fontColor('#2563eb')
              .backgroundColor('#eff6ff')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(10)
              .margin({ top: 6 })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 14 })
      }
      .width('100%')

      // 分隔线
      Divider()
        .strokeWidth(1)
        .color('#e2e8f0')
        .margin({ top: 14, bottom: 14 })

      // 健康摘要区
      Row() {
        // 血压
        Column() {
          Row() {
            Text('💓')
              .fontSize(14)
            Text(' 血压')
              .fontSize(13)
              .fontColor('#64748b')
          }
          Row() {
            if (this.healthSummary.latestSbp !== undefined && this.healthSummary.latestDbp !== undefined) {
              Text(this.healthSummary.latestSbp + '/' + this.healthSummary.latestDbp)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1e293b')
            } else {
              Text('—')
                .fontSize(16)
                .fontColor('#9ca3af')
            }
            Text(' ' + this.getBpStatus().icon + ' ' + this.getBpStatus().text)
              .fontSize(12)
              .fontColor(this.getBpStatus().color)
              .margin({ left: 4 })
          }
          .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 血糖
        Column() {
          Row() {
            Text('🩸')
              .fontSize(14)
            Text(' 血糖')
              .fontSize(13)
              .fontColor('#64748b')
          }
          Row() {
            if (this.healthSummary.latestFpg !== undefined) {
              Text(Number(this.healthSummary.latestFpg).toFixed(1))
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1e293b')
            } else {
              Text('—')
                .fontSize(16)
                .fontColor('#9ca3af')
            }
            Text(' ' + this.getFpgStatus().icon + ' ' + this.getFpgStatus().text)
              .fontSize(12)
              .fontColor(this.getFpgStatus().color)
              .margin({ left: 4 })
          }
          .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      // 预警提示
      if (this.healthSummary.hasWarning && this.healthSummary.warningText) {
        Row() {
          Text('⚠️ ' + this.healthSummary.warningText)
            .fontSize(12)
            .fontColor('#b45309')
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#fef3c7')
        .borderRadius(8)
        .margin({ top: 12 })
      }

      // 操作按钮
      Row() {
        Blank()
        Text('查看详情 →')
          .fontSize(14)
          .fontColor('#2563eb')
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.onViewArchive();
          })
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: '#0f172a14',
      offsetY: 2
    })
    .margin({ bottom: 14 })
    .onClick(() => {
      this.onCardClick();
    })
  }
}
