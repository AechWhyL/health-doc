import { ElderInterventionIndex } from './intervention/ElderInterventionIndex';
import { InterventionPlanDetail } from './intervention/InterventionPlanDetail';
import { TaskCheckInPage } from './intervention/TaskCheckInPage';

@Entry
@Component
struct ElderIndex {
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @State currentIndex: number = 0;

  @Builder
  PageMap(name: string) {
    if (name === 'InterventionPlanDetail') {
      InterventionPlanDetail()
    } else if (name === 'TaskCheckInPage') {
      TaskCheckInPage()
    }
  }

  @Builder
  TabBuilder(index: number, name: string, icon: string, selectedIcon: string) {
    Column() {
      Text(icon) // 这里可以用 Image，暂时用 Text 模拟图标
        .fontSize(24)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#999')
        .margin({ bottom: 4 })
      Text(name)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Navigation(this.navPathStack) {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        // 首页 Tab (占位)
        TabContent() {
          Column() {
            Text('首页功能开发中...')
              .fontSize(20)
              .fontColor('#999')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
        .tabBar(this.TabBuilder(0, '首页', '🏠', '🏠'))

        // 干预 Tab
        TabContent() {
          ElderInterventionIndex()
        }
        .tabBar(this.TabBuilder(1, '干预', '📅', '📅'))

        // 我的 Tab (占位)
        TabContent() {
          Column() {
            Text('个人中心开发中...')
              .fontSize(20)
              .fontColor('#999')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
        .tabBar(this.TabBuilder(2, '我的', '👤', '👤'))
      }
      .scrollable(false)
      .onChange((index) => {
        this.currentIndex = index;
      })
    }
    .mode(NavigationMode.Stack)
    .title('健康关护 · 长辈版')
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .navDestination(this.PageMap)
  }
}
