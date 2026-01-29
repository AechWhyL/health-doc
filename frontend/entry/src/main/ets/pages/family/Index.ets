import { ElderOverviewTab } from './ElderOverviewTab';
import {InterventionIndex} from './intervention/InterventionIndex'
import { HealthDataTab } from './HealthDataTab';
import { FamilyConsultationTab } from './FamilyConsultationTab';
import { FamilyArchiveTab } from './FamilyArchiveTab';
import { FamilyMineTab } from './mine/FamilyMineTab';
import { GlobalSocketManager } from '../../components/GlobalSocketManager';
import { SocketService } from '../../common/api/SocketService';
import { NotificationService, ConsultationReplyNotification, TaskReminderNotification } from '../../services/NotificationService';
import { UserWithRoleResponse } from '../Login';

type FamilyTabKey = 'home' | 'archive' | 'health' | 'consult' | 'profile';

@Entry
@Component
struct FamilyIndex {
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @State currentTab: FamilyTabKey = 'home';

  private switchTab(tab: FamilyTabKey): void {
    this.currentTab = tab;
  }

  /**
   * WebSocket 初始化完成后的处理
   */
  private onSocketInitialized = (): void => {
    console.log('[FamilyIndex] WebSocket initialized, registering listeners');
    const socketService = SocketService.getInstance();
    
    // 1. 请求通知权限
    NotificationService.requestPermission();

    // 2. 注册咨询回复通知监听
    socketService.on<ConsultationReplyNotification>('notification:consultation_reply', (data) => {
      console.log('[FamilyIndex] Received consultation reply:', data);
      NotificationService.showConsultationReplyNotification(new ConsultationReplyNotification(data));
    });

    // 3. 注册任务提醒通知监听 (家属端关注老人的任务)
    socketService.on<TaskReminderNotification>('notification:task_reminder', (data) => {
      console.log('[FamilyIndex] Received task reminder:', data);
      NotificationService.showTaskReminderNotification(new TaskReminderNotification(data));
    });

    // 4. 绑定用户
    const user:UserWithRoleResponse|undefined = AppStorage.get<UserWithRoleResponse>('currentUser');
    if (user) {
      socketService.bindUser(user.id);
    }
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
    InterventionIndex()
  }

  @Builder
  private buildArchiveTab() {
    ElderOverviewTab()
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
    Stack() {
      // 全局 WebSocket 管理器 (隐藏视图，生命周期随此首页)
      GlobalSocketManager({
        onInitialized: this.onSocketInitialized
      })

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
            this.TabIcon('home', '🏠', '计划')
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
        .hideTitleBar(true)
        .hideBackButton(true)
        .mode(NavigationMode.Stack)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}
