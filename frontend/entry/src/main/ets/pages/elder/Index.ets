import { ElderHomeTab } from './ElderHomeTab';
import { ElderHealthTab } from './ElderHealthTab';
import { ElderConsultationTab } from './ElderConsultationTab';
import { ElderProfileTab } from './ElderProfileTab';
import { InterventionIndex } from '../medical/intervention/InterventionIndex';

type ElderTabKey = 'home' | 'health' | 'intervention' | 'consult' | 'profile';

@Entry
@Component
struct ElderIndex {
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @State currentTab: ElderTabKey = 'home';

  private switchTab(tab: ElderTabKey): void {
    this.currentTab = tab;
  }

  @Builder
  private TabIcon(tab: ElderTabKey, icon: string, label: string) {
    Column() {
      Text(icon)
        .fontSize(22)
        .fontColor(this.currentTab === tab ? '#16a34a' : '#9ca3af')
      Text(label)
        .fontSize(10)
        .fontColor(this.currentTab === tab ? '#16a34a' : '#6b7280')
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 8, bottom: 8 })
    .onClick(() => {
      this.switchTab(tab);
    })
  }

  build() {
    Column() {
      Navigation(this.navPathStack) {
        Column() {
          // 主内容区域
          if (this.currentTab === 'home') {
            ElderHomeTab()
          } else if (this.currentTab === 'health') {
            ElderHealthTab()
          } else if (this.currentTab === 'consult') {
            ElderConsultationTab()
          } else if (this.currentTab === 'profile') {
            ElderProfileTab()
          }
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor('#f0fdf4')

        // 底部导航栏
        Row() {
          this.TabIcon('home', '🏠', '首页')
          this.TabIcon('health', '❤️', '健康')
          this.TabIcon('consult', '💬', '咨询')
          this.TabIcon('profile', '👤', '我的')
        }
        .width('100%')
        .backgroundColor(Color.White)
        .border({
          width: { top: 1 },
          color: '#e5e7eb'
        })
        .padding({
          left: 8,
          right: 8,
          bottom: 16
        })
      }
      .width('100%')
      .title('健康关护 · 长辈版')
      .titleMode(NavigationTitleMode.Mini)
      .hideBackButton(true)
      .mode(NavigationMode.Stack)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0fdf4')
  }
}
