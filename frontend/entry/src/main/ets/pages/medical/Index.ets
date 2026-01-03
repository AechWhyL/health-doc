@Entry
@Component
struct MedicalIndex {
  @State currentIndex: number = 0;

  build() {
    Column() {
      Tabs({ index: this.currentIndex }) {
        TabContent() {
          Column() {
            Text('老人档案与分组')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 24, bottom: 16 })

            Text('这里支持按条件检索和浏览负责范围内的老人档案列表。')
              .fontSize(14)
              .margin({ bottom: 8 })

            Text('后续可以在此快速查看老人基础信息、既往病史、过敏史等。')
              .fontSize(14)
          }
          .padding(16)
        }
        .tabBar('档案分组')

        TabContent() {
          Column() {
            Text('诊疗与健康记录')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 24, bottom: 16 })

            Text('这里用于创建和维护门诊记录、住院记录、随访记录等专业健康记录。')
              .fontSize(14)
              .margin({ bottom: 8 })

            Text('后续可以在此录入检查报告摘要和评估结论。')
              .fontSize(14)
          }
          .padding(16)
        }
        .tabBar('诊疗记录')

        TabContent() {
          Column() {
            Text('健康数据与分析')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 24, bottom: 16 })

            Text('这里展示批量导入或录入的健康监测数据及其趋势图与统计分析结果。')
              .fontSize(14)
              .margin({ bottom: 8 })

            Text('后续可以在此识别高风险人群或异常波动，并生成建议。')
              .fontSize(14)
          }
          .padding(16)
        }
        .tabBar('数据分析')

        TabContent() {
          Column() {
            Text('干预计划与协同')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 24, bottom: 16 })

            Text('这里用于制定和调整用药计划、康复训练计划、随访计划等干预方案。')
              .fontSize(14)
              .margin({ bottom: 8 })

            Text('后续可以在此查看老人和家属反馈，并向双方推送建议与提醒。')
              .fontSize(14)
          }
          .padding(16)
        }
        .tabBar('干预与协同')
      }
      .barPosition(BarPosition.Start)
      .vertical(false)
    }
    .width('100%')
    .height('100%')
  }
}

