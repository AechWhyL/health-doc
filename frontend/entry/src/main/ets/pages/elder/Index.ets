import { ElderHomeTab } from './ElderHomeTab';
import { ElderHealthTab } from './ElderHealthTab';
import { ElderConsultationTab } from './ElderConsultationTab';
import { ElderProfileTab } from './ElderProfileTab';
import { InterventionIndex } from '../medical/intervention/InterventionIndex';
import { GlobalSocketManager } from '../../components/GlobalSocketManager';
import { SocketService } from '../../common/api/SocketService';
import { NotificationService, ConsultationReplyNotification, TaskReminderNotification } from '../../services/NotificationService';
import { UserWithRoleResponse } from '../Login';

type ElderTabKey = 'home' | 'health' | 'intervention' | 'consult' | 'profile';

@Entry
@Component
struct ElderIndex {
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @State currentTab: ElderTabKey = 'home';

  private switchTab(tab: ElderTabKey): void {
    this.currentTab = tab;
  }

  /**
   * WebSocket 初始化完成后的处理
   */
  private onSocketInitialized = (): void => {
    console.log('[ElderIndex] WebSocket initialized, registering listeners');
    const socketService = SocketService.getInstance();
    
    // 1. 请求通知权限
    NotificationService.requestPermission();

    // 2. 注册咨询回复通知监听
    socketService.on<ConsultationReplyNotification>('notification:consultation_reply', (data) => {
      console.log('[ElderIndex] Received consultation reply:', data);
      NotificationService.showConsultationReplyNotification(new ConsultationReplyNotification(data));
    });

    // 3. 注册任务提醒通知监听 (老人端关注自己的待办)
    socketService.on<TaskReminderNotification>('notification:task_reminder', (data) => {
      console.log('[ElderIndex] Received task reminder:', data);
      NotificationService.showTaskReminderNotification(new TaskReminderNotification(data));
    });

    // 4. 绑定用户
    const user:UserWithRoleResponse|undefined = AppStorage.get<UserWithRoleResponse>('currentUser');
    if (user) {
      socketService.bindUser(user.id);
    }
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0fdf4')
  }
}
