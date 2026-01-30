import { ArchiveStats } from '../../models/HealthArchiveModels';
import { LengthMetrics } from '@kit.ArkUI';

@Component
export struct ElderCard {
  @Prop elderName: string = '';
  @Prop elderAge: number = 0;
  @Prop elderGender: number = 0; // 0=女, 1=男
  @Prop elderPhone: string = '';
  @Prop relationName: string = '';
  @Prop archiveStats: ArchiveStats = { total: 0, breakdown: {} };
  onCardClick: () => void = () => {};
  onViewArchive: () => void = () => {};

  private getGenderText(): string {
    return this.elderGender === 1 ? '男' : '女';
  }

  private getGenderIcon(): string {
    return this.elderGender === 1 ? '👴' : '👵';
  }

  private formatPhone(): string {
    return this.elderPhone;
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

      // 档案统计区
      Row() {
        Column() {
          Text(this.archiveStats.total.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e293b')
          Text('档案总数')
            .fontSize(12)
            .fontColor('#64748b')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Center)
        .width(80)

        // 垂直分割线
        Divider()
          .vertical(true)
          .height(30)
          .color('#e2e8f0')
          .margin({ left: 5, right: 5 })

        Column(){

        }
        // 摘要详情
        Flex({
          wrap:FlexWrap.Wrap,
          space:{
            main:LengthMetrics.vp(12),
            cross:LengthMetrics.vp(12)
          }
        }) {
          if (this.archiveStats.breakdown['MEDICAL_HISTORY']) {
            Text(`病史 ${this.archiveStats.breakdown['MEDICAL_HISTORY']}`)
              .fontSize(12)
              .fontColor('#64748b')
              .backgroundColor('#f1f5f9')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
          }
           if (this.archiveStats.breakdown['CHECK_REPORT']) {
            Text(`检查 ${this.archiveStats.breakdown['CHECK_REPORT']}`)
              .fontSize(12)
              .fontColor('#64748b')
              .backgroundColor('#f1f5f9')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
          }
          if (this.archiveStats.breakdown['MEDICATION']) {
            Text(`用药 ${this.archiveStats.breakdown['MEDICATION']}`)
              .fontSize(12)
              .fontColor('#64748b')
              .backgroundColor('#f1f5f9')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
          }
          if (this.archiveStats.breakdown['ALLERGY']) {
            Text(`过敏 ${this.archiveStats.breakdown['ALLERGY']}`)
              .fontSize(12)
              .fontColor('#64748b')
              .backgroundColor('#f1f5f9')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
          }
        }
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

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
