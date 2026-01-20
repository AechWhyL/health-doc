import { ElderOverviewTab } from './ElderOverviewTab';
import { HealthDataTab } from './HealthDataTab';
import { FamilyConsultationTab } from './FamilyConsultationTab';
import { FamilyArchiveTab } from './FamilyArchiveTab';
import { FamilyMineTab } from './mine/FamilyMineTab';

type FamilyTabKey = 'home' | 'archive' | 'health' | 'consult' | 'profile';

@Entry
@Component
struct FamilyIndex {
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @State currentTab: FamilyTabKey = 'home';

  private switchTab(tab: FamilyTabKey): void {
    this.currentTab = tab;
  }

  @Builder
  private TabIcon(tab: FamilyTabKey, icon: string, label: string) {
    Column() {
      Text(icon)
        .fontSize(22)
        .fontColor(this.currentTab === tab ? '#2563eb' : '#9ca3af')
      Text(label)
        .fontSize(10)
        .fontColor(this.currentTab === tab ? '#2563eb' : '#6b7280')
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 8, bottom: 8 })
    .onClick(() => {
      this.switchTab(tab);
    })
  }

  @Builder
  private buildHomeTab() {
    ElderOverviewTab()
  }

  @Builder
  private buildArchiveTab() {
    FamilyArchiveTab()
  }

  @Builder
  private buildHealthTab() {
    HealthDataTab()
  }

  @Builder
  private buildConsultTab() {
    FamilyConsultationTab()
  }

  @Builder
  private buildProfileTab() {
    FamilyMineTab()
  }

  build() {
    Column() {
      Navigation(this.navPathStack) {
        Column() {
          // 主内容区域
          if (this.currentTab === 'home') {
            this.buildHomeTab()
          } else if (this.currentTab === 'archive') {
            this.buildArchiveTab()
          } else if (this.currentTab === 'health') {
            this.buildHealthTab()
          } else if (this.currentTab === 'consult') {
            this.buildConsultTab()
          } else if (this.currentTab === 'profile') {
            this.buildProfileTab()
          }
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor('#f8fafc')

        // 底部导航栏
        Row() {
          this.TabIcon('home', '🏠', '首页')
          this.TabIcon('archive', '📋', '档案')
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
      .title('健康关护 · 家属端')
      .titleMode(NavigationTitleMode.Mini)
      .hideBackButton(true)
      .mode(NavigationMode.Stack)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}
