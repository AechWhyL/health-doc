import { promptAction } from '@kit.ArkUI';
import { CareCard } from '../../components/medical/CareCard';
import { DocTab } from './doc/DocTab';
import { ElderArchive } from './doc/ElderArchive';
import { ChatPage } from './consultation/ChatPage'
import { ConsultationList } from './consultation/ConsultationList';
import { InterventionIndex } from './intervention/InterventionIndex'
import { ElderInterventionPlanList } from './intervention/ElderInterventionPlanList';
import { InterventionPlanForm } from './intervention/InterventionPlanForm';

type CareTabKey = 'elder' | 'data' | 'plan' | 'consult'

@Entry
@Component
struct MedicalIndex {
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @State private currentTab: CareTabKey = 'elder'

  private switchTab(tab: CareTabKey): void {
    this.currentTab = tab
  }

  private goBackToLogin(): void {
    this.navPathStack.pop();
  }

  @Builder
  private buildElderTab() {
    DocTab()
  }

  @Builder
  private buildDataTab() {
    Column() {
      CareCard({
        content: this.buildDataCardContent
      });
    }
    .padding({
      left: 16,
      right: 16,
      top: 10,
      bottom: 10
    })
  }

  @Builder
  private buildPlanTab() {
    Column() {
      InterventionIndex()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildConsultTab() {
    Column() {
      ConsultationList()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildDataCardContent() {
    Row() {
      Column() {
        Text('当前关联老人列表')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
        Text('支持按姓名筛选')
          .fontSize(11)
          .fontColor('#6b7280')
          .margin({ top: 2 })
      }
      .layoutWeight(1)

      Text('MyElders')
        .fontSize(11)
        .fontColor('#1d4ed8')
        .padding({
          left: 8,
          right: 8,
          top: 2,
          bottom: 2
        })
        .borderRadius(999)
        .backgroundColor('#eff6ff')
    }
    .margin({ bottom: 6 })

    Column() {
      Row() {
        Column() {
          Text('张阿姨 · 72 岁')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
          Text('关系：签约老人 · 高血压 · 糖尿病')
            .fontSize(11)
            .fontColor('#6b7280')
            .margin({ top: 2 })
        }
        .layoutWeight(1)

        Text('查看数据')
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
    }
  }

  @Builder
  private buildPlanCardContent() {
    Row() {
      Column() {
        Text('计划列表')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
        Text('按状态过滤，支持多老人')
          .fontSize(11)
          .fontColor('#6b7280')
          .margin({ top: 2 })
      }
      .layoutWeight(1)

      Text('所有计划')
        .fontSize(11)
        .fontColor('#1d4ed8')
        .padding({
          left: 8,
          right: 8,
          top: 2,
          bottom: 2
        })
        .borderRadius(999)
        .backgroundColor('#eff6ff')
    }
    .margin({ bottom: 6 })

    Column() {
      Row() {
        Column() {
          Text('高血压综合干预方案')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
          Text('执行中 · 张阿姨')
            .fontSize(11)
            .fontColor('#6b7280')
            .margin({ top: 2 })
        }
        .layoutWeight(1)

        Text('执行中')
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
    }

    Button('新建干预计划')
      .type(ButtonType.Capsule)
      .width('100%')
      .height(36)
      .margin({ top: 10 })
      .backgroundColor('#f9fafb')
      .fontColor('#111827')
      .border({
        width: 1,
        color: '#e5e7eb'
      })
      .onClick(() => {
        promptAction.showToast({ message: '功能开发中' })
      })
  }

  @Builder
  private buildBottomNavItem(tab: CareTabKey, icon: string, label: string) {
    Column() {
      Text(icon)
        .fontSize(18)
        .fontColor(this.currentTab === tab ? '#111827' : '#9ca3af')
      Text(label)
        .fontSize(10)
        .fontColor(this.currentTab === tab ? '#111827' : '#9ca3af')
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 4, bottom: 6 })
    .onClick(() => {
      this.switchTab(tab)
    })
  }

  @Builder
  private buildNavigationMenus() {
    Row() {
      Text('退出')
        .fontSize(12)
        .fontColor('#2563eb')
        .onClick(() => {
          this.goBackToLogin()
        })
        .padding({ right: 16 })
    }
  }

  @Builder
  private buildPageMap(name: string) {
    if (name === 'Medical_DocTab_ElderArchive') {
      ElderArchive()
    }
    if (name === 'Medical_ConsultationTab_ChatPage') {
      ChatPage()
    }
    if (name === 'Medical_Intervention_ElderPlanList') {
      ElderInterventionPlanList()
    }
    if (name === 'Medical_Intervention_PlanForm') {
      InterventionPlanForm()
    }
    // if (name === 'Medical_Intervention_PlanItemForm') {
    //   InterventionPlanItemForm()
    // }
    // if (name === 'Medical_Intervention_PlanItemDetail') {
    //   InterventionPlanItemDetail()
    // }
  }

  build() {
    Column() {
      Navigation(this.navPathStack) {
        Column() {
          if (this.currentTab === 'elder') {
            this.buildElderTab()
          } else if (this.currentTab === 'data') {
            this.buildDataTab()
          } else if (this.currentTab === 'plan') {
            this.buildPlanTab()
          } else if (this.currentTab === 'consult') {
            this.buildConsultTab()
          }
        }
        .layoutWeight(1)
        .linearGradient({
          angle: 180,
          colors: [['#f9fafb', 0.0], ['#f3f4f6', 0.5], ['#e5e7eb', 1]]
        })

        Row() {
          this.buildBottomNavItem('elder', '✧', '档案')
          this.buildBottomNavItem('data', '▴', '数据')
          this.buildBottomNavItem('plan', '✓', '干预')
          this.buildBottomNavItem('consult', '⌘', '咨询')
        }
        .width('100%')
        .border({
          width: { top: 1 },
          color: '#e5e7eb'
        })
        .backgroundColor(Color.White)
        .padding({
          left: 14,
          right: 14,
          bottom: 10,
          top: 4
        })
      }
      .width("100%")
      .title({ main: '健康关护 · 医护端', sub: '查看档案、分析数据、管理干预计划' })
      .titleMode(NavigationTitleMode.Mini)
      .hideBackButton(true)
      .mode(NavigationMode.Auto)
      .navDestination(this.buildPageMap)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f2f4f7')
  }
}
