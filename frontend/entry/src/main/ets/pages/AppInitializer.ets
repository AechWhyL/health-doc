import router from '@ohos.router';
import { GlobalSocketManager } from '../components/GlobalSocketManager';

interface UserRole {
  id: number;
  role_code: string;
  role_name: string;
  description: string | null;
}

interface CurrentUser {
  id: number;
  username: string;
  email: string | null;
  phone: string | null;
  real_name: string | null;
  avatar: string | null;
  status: 'active' | 'inactive' | 'locked';
  is_verified: boolean;
  roles: UserRole[];
}

/**
 * 应用初始化中间层页面
 * 负责 WebSocket 初始化和角色路由
 */
@Entry
@Component
struct AppInitializer {
  @State private isInitializing: boolean = true;
  @State private statusText: string = '正在初始化连接...';
  private currentUser: CurrentUser | null = null;

  aboutToAppear(): void {
    // 从 AppStorage 读取当前用户信息
    const userStr = AppStorage.get<CurrentUser>('currentUser');
    if (userStr) {
      this.currentUser = userStr;
      console.log('[AppInitializer] Current user loaded:', JSON.stringify(this.currentUser));
    } else {
      console.error('[AppInitializer] No current user found, redirecting to login');
      this.redirectToLogin();
    }
  }

  /**
   * WebSocket 初始化完成回调
   */
  private onSocketInitialized = (): void => {
    console.log('[AppInitializer] WebSocket initialized, routing to main page');
    this.statusText = '连接成功，正在跳转...';
    
    // 延迟一小段时间，让用户看到成功提示
    setTimeout(() => {
      this.routeToMainPage();
    }, 500);
  }

  /**
   * 根据用户角色跳转到对应主页面
   */
  private routeToMainPage(): void {
    if (!this.currentUser || !this.currentUser.roles || this.currentUser.roles.length === 0) {
      console.error('[AppInitializer] Invalid user data, redirecting to login');
      this.redirectToLogin();
      return;
    }

    const roleCodes = this.currentUser.roles.map(role => role.role_code);
    let targetPage: string = '';

    // 根据角色确定目标页面
    if (roleCodes.indexOf('medical_staff') >= 0 || roleCodes.indexOf('MEDICAL_STAFF') >= 0) {
      targetPage = 'pages/medical/Index';
    } else if (roleCodes.indexOf('elder') >= 0 || roleCodes.indexOf('ELDER') >= 0) {
      targetPage = 'pages/elder/Index';
    } else if (roleCodes.indexOf('family') >= 0 || roleCodes.indexOf('FAMILY') >= 0) {
      targetPage = 'pages/family/Index';
    } else {
      console.error('[AppInitializer] Unknown role, redirecting to login');
      this.redirectToLogin();
      return;
    }

    console.log('[AppInitializer] Routing to:', targetPage);
    
    // 使用 replaceUrl 替换当前页面，避免用户返回到初始化页面
    router.replaceUrl({
      url: targetPage
    }).catch((err:string) => {
      console.error('[AppInitializer] Failed to route:', err);
      this.redirectToLogin();
    });
  }

  /**
   * 重定向到登录页面
   */
  private redirectToLogin(): void {
    router.replaceUrl({
      url: 'pages/Login'
    }).catch((err:string) => {
      console.error('[AppInitializer] Failed to redirect to login:', err);
    });
  }

  build() {
    Stack() {
      // 全局 WebSocket 管理器（隐藏的 Web 视图）
      GlobalSocketManager({
        onInitialized: this.onSocketInitialized
      })

      // 加载界面
      Column() {
        // Logo 或标题
        Text('老年人健康档案管理平台')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1f2937')
          .margin({ bottom: 40 })

        // 加载进度
        LoadingProgress()
          .width(48)
          .height(48)
          .color('#2563eb')
          .margin({ bottom: 16 })

        // 状态文本
        Text(this.statusText)
          .fontSize(14)
          .fontColor('#6b7280')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#f9fafb')
    }
    .width('100%')
    .height('100%')
  }
}
