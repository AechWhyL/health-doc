import { DocTab } from './doc/DocTab';
import { ConsultationList } from './consultation/ConsultationList';
import { InterventionIndex } from './intervention/InterventionIndex'
import { DataTab } from './data/DataTab';
import { MineTab } from './mine/MineTab';
import { GlobalSocketManager } from '../../components/GlobalSocketManager';
import { SocketService } from '../../common/api/SocketService';
import { NotificationService, ConsultationReplyNotification, TaskCheckinNotification, TaskReminderNotification } from '../../services/NotificationService';
import { UserWithRoleResponse } from '../Login';

type CareTabKey = 'elder' | 'data' | 'plan' | 'consult' | 'mine'

@Entry
@Component
struct MedicalIndex {
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @State private currentTab: CareTabKey = 'elder'

  private switchTab(tab: CareTabKey): void {
    this.currentTab = tab
  }

  /**
   * WebSocket 初始化完成后的处理
   */
  private onSocketInitialized = (): void => {
    console.log('[MedicalIndex] WebSocket initialized, registering listeners');
    const socketService = SocketService.getInstance();
    
    // 1. 请求通知权限
    NotificationService.requestPermission();

    // 2. 注册咨询回复通知监听
    socketService.on<ConsultationReplyNotification>('notification:consultation_reply', (data) => {
      console.log('[MedicalIndex] Received consultation reply:', data);
      NotificationService.showConsultationReplyNotification(new ConsultationReplyNotification(data));
    });

    // 3. 注册任务签到通知监听 (医护端关注)
    socketService.on<TaskCheckinNotification>('notification:task_checkin', (data) => {
      console.log('[MedicalIndex] Received task checkin:', data);
      NotificationService.showTaskCheckinNotification(new TaskCheckinNotification(data));
    });

    // 4. 绑定用户
    const user:UserWithRoleResponse|undefined = AppStorage.get<UserWithRoleResponse>('currentUser');
    if (user) {
      socketService.bindUser(user.id);
    }
  }

  @Builder
  private buildElderTab() {
    DocTab()
  }

  @Builder
  private buildDataTab() {
    DataTab()
  }

  @Builder
  private buildPlanTab() {
    InterventionIndex()
  }

  @Builder
  private buildConsultTab() {
    ConsultationList()
  }

  @Builder
  private buildMineTab() {
     MineTab()
  }

  @Builder
  private buildBottomNavItem(tab: CareTabKey, icon: string, label: string) {
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
    .padding({ top: 4, bottom: 6 })
    .onClick(() => {
      this.switchTab(tab)
    })
  }

  @Builder
  private buildNavigationMenus() {
    Row() {
    }
  }

  build() {
    Stack() {
      // 全局 WebSocket 管理器 (隐藏视图，生命周期随此首页)
      GlobalSocketManager({
        onInitialized: this.onSocketInitialized
      })

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
            } else if (this.currentTab === 'mine') {
              this.buildMineTab()
            }
          }
          .layoutWeight(1)
          .backgroundColor('#f8fafc')

          Row() {
            this.buildBottomNavItem('elder', '📋', '档案')
            this.buildBottomNavItem('data', '📊', '数据')
            this.buildBottomNavItem('plan', '💊', '干预')
            this.buildBottomNavItem('consult', '💬', '咨询')
            this.buildBottomNavItem('mine', '👤', '我的')
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
            top: 8,
            bottom: 16
          })
        }
        .width("100%")
        .titleMode(NavigationTitleMode.Mini)
        .hideTitleBar(true)
        .hideBackButton(true)
        .mode(NavigationMode.Stack)
        .menus(this.buildNavigationMenus)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}
