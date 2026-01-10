import router from '@ohos.router';
import {ElderInfo} from './home/ElderInfo'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State loading: boolean = false;
  @State error: string = '';

  build() {
    Column() {
      Tabs({ index: this.currentIndex }) {
        TabContent() {
          if(this.currentIndex===0){
            ElderInfo()
          }
        }
        .tabBar('我的档案')

        TabContent() {
          Column() {
            Text('健康数据与趋势')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 24, bottom: 16 })

            Text('这里展示老人录入的血压、血糖、体重、心率等健康数据的趋势图和统计结果。')
              .fontSize(14)
              .margin({ bottom: 8 })

            Text('后续可以在此页面提供手动录入健康数据的表单。')
              .fontSize(14)
          }
          .padding(16)
        }
        .tabBar('我的健康数据')

        TabContent() {
          Column() {
            Text('用药与干预计划')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 24, bottom: 16 })

            Text('这里展示医护制定的用药计划、康复训练计划以及执行记录。')
              .fontSize(14)
              .margin({ bottom: 8 })

            Text('老人可以在此查看每天需要执行的任务，并标记已完成情况。')
              .fontSize(14)
          }
          .padding(16)
        }
        .tabBar('用药与计划')
      }
      .barPosition(BarPosition.Start)
      .vertical(false)
    }
    .width('100%')
    .height('100%')
  }
}
