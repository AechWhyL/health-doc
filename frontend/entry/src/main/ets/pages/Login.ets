import apiService, { ApiResponse, LoginResponseData } from '../common/api/ApiService';
import router from '@ohos.router';

@Entry
@Component
struct Login {
  @State username: string = '';
  @State password: string = '';
  @State rememberMe: boolean = false;
  @State loading: boolean = false;
  @State error: string = '';

  private async doLogin(): Promise<void> {
    this.loading = true;
    this.error = '';
    try {
      const resp: ApiResponse<LoginResponseData> = await apiService.login(this.username, this.password);
      if (resp.code === 200) {
        router.replaceUrl({ url: 'pages/Index' });
        return;
      }
      this.error = resp.message;
    } catch (e) {
      if ((e as Object) instanceof Error) {
        const err = e as Error;
        this.error = err.message;
      } else {
        this.error = '登录失败';
      }
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      Text('老年人健康档案管理平台')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 24 })

      TextInput({ placeholder: '用户名/邮箱/手机号' })
        .margin({ bottom: 12 })
        .onChange((value: string) => {
          this.username = value;
        })

      TextInput({ placeholder: '密码' })
        .type(InputType.Password)
        .margin({ bottom: 12 })
        .onChange((value: string) => {
          this.password = value;
        })

      Row() {
        Checkbox({ name: 'remember' })
          .select(this.rememberMe)
          .onChange((checked: boolean) => {
            this.rememberMe = checked;
          })
        Text('记住我')
          .fontSize(16)
          .margin({ left: 8 })
      }
      .margin({ bottom: 16 })

      if (this.error) {
        Text(this.error)
          .fontColor(Color.Red)
          .margin({ bottom: 12 })
      }

      Button('立即登录')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(44)
        .onClick(() => {
          if (this.loading) {
            return;
          }
          this.doLogin();
        })

      Button('没有账号？去注册')
        .type(ButtonType.Normal)
        .width('100%')
        .height(44)
        .margin({ top: 12 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/Register' });
        })
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .justifyContent(FlexAlign.Start)
  }
}
