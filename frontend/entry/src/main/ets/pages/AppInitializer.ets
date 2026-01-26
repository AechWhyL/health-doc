import router from '@ohos.router';

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
 * 职责：
 * 1. 验证用户信息
 * 2. 根据角色分发到对应主页
 * 
 * 注意：WebSocket 的全局初始化已移动到各端主页面的 Index.ets 中，
 * 以确保 SocketBridge 组件在应用生命周期内持续存在且不随此中间页面的销毁而失效。
 */
@Entry
@Component
struct AppInitializer {
  private currentUser: CurrentUser | null = null;

  aboutToAppear(): void {
    // 从 AppStorage 读取当前用户信息
    const user = AppStorage.get<CurrentUser>('currentUser');
    if (user) {
      this.currentUser = user;
      console.log('[AppInitializer] Current user loaded:', JSON.stringify(this.currentUser));
      // 立即执行路由分发
      this.routeToMainPage();
    } else {
      console.error('[AppInitializer] No current user found, redirecting to login');
      this.redirectToLogin();
    }
  }

  /**
   * 根据用户角色跳转到对应主页面
   */
  private routeToMainPage(): void {
    if (!this.currentUser || !this.currentUser.roles || this.currentUser.roles.length === 0) {
      console.error('[AppInitializer] Invalid user data or no roles, redirecting to login');
      this.redirectToLogin();
      return;
    }

    const roleCodes = this.currentUser.roles.map(role => role.role_code.toLowerCase());
    let targetPage: string = '';

    // 根据角色确定目标页面 (支持大写或小写匹配)
    if (roleCodes.includes('medical_staff')) {
      targetPage = 'pages/medical/Index';
    } else if (roleCodes.includes('elder')) {
      targetPage = 'pages/elder/Index';
    } else if (roleCodes.includes('family')) {
      targetPage = 'pages/family/Index';
    } else {
      console.error('[AppInitializer] Unknown role code(s):', roleCodes);
      this.redirectToLogin();
      return;
    }

    console.log('[AppInitializer] Routing to:', targetPage);
    
    // 使用 replaceUrl 确保初始化页面从栈中移除
    router.replaceUrl({
      url: targetPage
    }).catch((err: Error) => {
      console.error('[AppInitializer] Failed to route to ' + targetPage + ':', err.message);
      this.redirectToLogin();
    });
  }

  /**
   * 重定向到登录页面
   */
  private redirectToLogin(): void {
    router.replaceUrl({
      url: 'pages/Login'
    }).catch((err: Error) => {
      console.error('[AppInitializer] Critical: Failed to redirect to login:', err.message);
    });
  }

  build() {
    Column() {
      // 保持简洁的加载视图
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#2563eb')
        .margin({ bottom: 16 })
      
      Text('正在准备您的工作空间...')
        .fontSize(14)
        .fontColor('#6b7280')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#f9fafb')
  }
}
