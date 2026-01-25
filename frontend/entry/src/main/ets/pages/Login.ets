import { promptAction } from '@kit.ArkUI';
import router from '@ohos.router';
import { httpRequest } from '../common/api/HttpUtil';
import { RequestEnum } from '../common/api/httpEnum';
import { preferenceUtils } from '../common/preferenceUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

interface RoleResponse {
  id: number;
  role_code: string;
  role_name: string;
  description: string | null;
}

interface UserWithRoleResponse {
  id: number;
  username: string;
  email: string | null;
  phone: string | null;
  real_name: string | null;
  avatar: string | null;
  status: 'active' | 'inactive' | 'locked';
  is_verified: boolean;
  last_login_at: string | null;
  last_login_ip: string | null;
  created_at: string;
  updated_at: string;
  roles: RoleResponse[];
}

interface LoginResponse {
  token: string;
  user: UserWithRoleResponse;
}

interface LoginFormState {
  username: string;
  password: string;
  rememberMe: boolean;
}

interface LoginPayload {
  username: string;
  password: string;
}

@Entry
@Component
struct Login {
  @State private form: LoginFormState = {
    username: '',
    password: '',
    rememberMe: false
  };

  @State private isSubmitting: boolean = false;
  @State private errorMessage: string = '';

  aboutToAppear(): void {
  }

  private async handleSubmit(): Promise<void> {
    if (this.isSubmitting) {
      return;
    }

    const username = this.form.username.trim();
    const password = this.form.password.trim();

    if (username === '' || password === '') {
      this.errorMessage = '请输入用户名和密码';
      promptAction.showToast({
        message: this.errorMessage
      });
      return;
    }

    this.errorMessage = '';
    this.isSubmitting = true;

    try {
      const payload: LoginPayload = {
        username: username,
        password: password
      };

      const response = await httpRequest<ApiResponse<LoginResponse>, LoginPayload>({
        url: '/api/v1/users/login',
        method: RequestEnum.POST,
        params: payload
      });

      if (response.code !== 200 || !response.data) {
        const msg = response.message || '登录失败';
        this.errorMessage = msg;
        promptAction.showToast({
          message: msg
        });
        this.isSubmitting = false;
        return;
      }

      const loginData = response.data;

      // 保存 token 和用户信息到 Preference
      const context = getContext(this);
      await preferenceUtils().set(context, 'token_store', 'token', loginData.token);
      await preferenceUtils().set(context, 'user_store', 'current_user', JSON.stringify(loginData.user));
      
      // 同时更新 AppStorage，方便应用内使用
      AppStorage.setOrCreate('currentUser', loginData.user);

      // 跳转到应用初始化页面，由其负责 WebSocket 初始化和角色路由
      router.pushUrl({
        url: 'pages/AppInitializer'
      }).catch(() => {});
    } catch (error) {
      console.log(error);
      this.errorMessage = '网络异常，请稍后重试';
      promptAction.showToast({
        message: this.errorMessage
      });
    } finally {
      this.isSubmitting = false;
    }
  }

  private handleGoRegister(): void {
    router.pushUrl({
      url: 'pages/Register'
    }).catch(() => {});
  }

  private toggleRememberMe(): void {
    this.form.rememberMe = !this.form.rememberMe;
  }

  private updateUsername(value: string): void {
    this.form.username = value;
  }

  private updatePassword(value: string): void {
    this.form.password = value;
  }

  build() {
    Column() {
      Column() {
        Text('老年人健康档案管理平台')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 8 });

        Text('统一登录入口，支持老人/家属/医护三端')
          .fontSize(12)
          .fontColor('#6b7280');
      }
      .width('100%')
      .padding({ top: 32, left: 24, right: 24 });

      Column() {
        Text('欢迎回来')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 4 });

        Text('使用手机号或邮箱登录，系统将自动识别角色')
          .fontSize(12)
          .fontColor('#6b7280');

        Column() {
          Text('手机号/邮箱')
            .fontSize(12)
            .fontColor('#6b7280');

          TextInput({ text: this.form.username,placeholder:'请输入手机号或邮箱' })
            .height(40)
            .fontSize(14)
            .padding({ left: 16, right: 16 })
            .borderRadius(20)
            .backgroundColor('#f9fafb')
            .onChange((value: string) => {
              this.updateUsername(value);
            });
        }
        .margin({ top: 24 });

        Column() {
          Text('密码')
            .fontSize(12)
            .fontColor('#6b7280');

          TextInput({ text: this.form.password,placeholder:'请输入登录密码' })
            .type(InputType.Password)
            .height(40)
            .fontSize(14)
            .padding({ left: 16, right: 16 })
            .borderRadius(20)
            .backgroundColor('#f9fafb')
            .onChange((value: string) => {
              this.updatePassword(value);
            });
        }
        .margin({ top: 16 });

        Row() {
          Checkbox({ name: 'remember', group: 'login-remember' })
            .select(this.form.rememberMe)
            .size({ width: 18, height: 18 })
            .onChange(() => {
              this.toggleRememberMe();
            });

          Text('记住我（使用更长有效期的刷新令牌）')
            .fontSize(12)
            .fontColor('#4b5563')
            .margin({ left: 8 });
        }
        .margin({ top: 12 });

        if (this.errorMessage !== '') {
          Text(this.errorMessage)
            .fontSize(12)
            .fontColor('#dc2626')
            .margin({ top: 8 });
        }

        Button(this.isSubmitting ? '正在登录...' : '立即登录')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(44)
          .margin({ top: 24 })
          .backgroundColor('#111827')
          .fontColor('#f9fafb')
          .enabled(!this.isSubmitting)
          .onClick(() => {
            this.handleSubmit();
          });

        Row() {
          Text('忘记密码')
            .fontSize(12)
            .fontColor('#2563eb');

          Blank();

          Text('还没有账号？立即注册')
            .fontSize(12)
            .fontColor('#2563eb')
            .onClick(() => {
              this.handleGoRegister();
            });
        }
        .margin({ top: 16 });
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 8 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f2f4f7');
  }
}
