@Entry
@Component
struct FamilyIndex {
  @State currentIndex: number = 0;

  build() {
    Column() {
      Tabs({ index: this.currentIndex }) {
        TabContent() {
          Column() {
            Text('关联老人管理')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 24, bottom: 16 })

            Text('这里展示已绑定老人的列表，可选择某一位老人进入详情。')
              .fontSize(14)
              .margin({ bottom: 8 })

            Text('后续可以在此支持添加/解绑老人、管理授权等操作。')
              .fontSize(14)
          }
          .padding(16)
        }
        .tabBar('绑定老人')

        TabContent() {
          Column() {
            Text('老人健康档案')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 24, bottom: 16 })

            Text('这里展示所选老人的健康档案概要和历史健康记录列表。')
              .fontSize(14)
              .margin({ bottom: 8 })

            Text('后续可以在此查看就诊记录、检查报告、健康随访记录等详情。')
              .fontSize(14)
          }
          .padding(16)
        }
        .tabBar('健康档案')

        TabContent() {
          Column() {
            Text('健康数据与趋势')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 24, bottom: 16 })

            Text('这里展示老人血压、血糖、体重、心率等指标的趋势图和统计。')
              .fontSize(14)
              .margin({ bottom: 8 })

            Text('后续可以在此帮助老人录入测量结果，并查看异常提醒。')
              .fontSize(14)
          }
          .padding(16)
        }
        .tabBar('健康数据')

        TabContent() {
          Column() {
            Text('用药与沟通')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 24, bottom: 16 })

            Text('这里展示老人当前用药方案、执行记录以及系统或医护的提醒。')
              .fontSize(14)
              .margin({ bottom: 8 })

            Text('后续可以在此反馈实际用药情况，并向医护端发起沟通。')
              .fontSize(14)
          }
          .padding(16)
        }
        .tabBar('用药与沟通')
      }
      .barPosition(BarPosition.Start)
      .vertical(false)
    }
    .width('100%')
    .height('100%')
  }
}

