import apiService, { ApiResponse, UserSummary } from '../common/api/ApiService';
import router from '@ohos.router';

type UserRole = 'elder' | 'family' | 'medical';

@Entry
@Component
struct Register {
  @State role: UserRole = 'elder';
  @State contact: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State loading: boolean = false;
  @State error: string = '';
  @State success: string = '';

  private isEmail(value: string): boolean {
    return value.indexOf('@') >= 0;
  }

  private isPhone(value: string): boolean {
    const phoneReg = /^1[3-9]\d{9}$/;
    return phoneReg.test(value);
  }

  private isValidPassword(value: string): boolean {
    if (value.length < 8) {
      return false;
    }
    let hasLetter = false;
    let hasDigit = false;
    for (let i = 0; i < value.length; i++) {
      const ch = value.charAt(i);
      if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')) {
        hasLetter = true;
      } else if (ch >= '0' && ch <= '9') {
        hasDigit = true;
      }
      if (hasLetter && hasDigit) {
        return true;
      }
    }
    return false;
  }

  private async doRegister(): Promise<void> {
    if (!this.role) {
      this.error = '请选择注册角色';
      return;
    }
    if (!this.contact) {
      this.error = '请输入手机号或邮箱';
      return;
    }
    if (!this.isEmail(this.contact) && !this.isPhone(this.contact)) {
      this.error = '请输入有效的手机号或邮箱';
      return;
    }
    if (!this.password || !this.confirmPassword) {
      this.error = '请输入密码并确认密码';
      return;
    }
    if (this.password !== this.confirmPassword) {
      this.error = '两次输入的密码不一致';
      return;
    }
    if (!this.isValidPassword(this.password)) {
      this.error = '密码至少8位，且需包含字母和数字';
      return;
    }

    this.loading = true;
    this.error = '';
    this.success = '';
    try {
      let email: string | undefined = undefined;
      let phone: string | undefined = undefined;
      const username: string = this.contact;
      if (this.isEmail(this.contact)) {
        email = this.contact;
      } else {
        phone = this.contact;
      }

      const resp: ApiResponse<UserSummary> = await apiService.register(
        username,
        this.password,
        email,
        phone,
        undefined
      );
      if (resp.code === 200) {
        this.success = '注册成功，去完善信息';
        router.replaceUrl({ url: 'pages/Login' });
        return;
      }
      this.error = resp.message;
    } catch (e) {
      if (e instanceof Error) {
        const err = e as Error;
        this.error = err.message;
      } else {
        this.error = '注册失败';
      }
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      Text('注册账号')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 24 })

      Text('选择注册角色')
        .fontSize(16)
        .margin({ bottom: 8 })

      Row() {
        Button('老人')
          .type(this.role === 'elder' ? ButtonType.Capsule : ButtonType.Normal)
          .margin({ right: 8 })
          .onClick(() => {
            this.role = 'elder';
          })

        Button('家属')
          .type(this.role === 'family' ? ButtonType.Capsule : ButtonType.Normal)
          .margin({ right: 8 })
          .onClick(() => {
            this.role = 'family';
          })

        Button('医护人员')
          .type(this.role === 'medical' ? ButtonType.Capsule : ButtonType.Normal)
          .onClick(() => {
            this.role = 'medical';
          })
      }
      .margin({ bottom: 16 })

      TextInput({ placeholder: '手机号或邮箱' })
        .margin({ bottom: 12 })
        .onChange((value: string) => {
          this.contact = value;
        })

      TextInput({ placeholder: '设置登录密码' })
        .type(InputType.Password)
        .margin({ bottom: 12 })
        .onChange((value: string) => {
          this.password = value;
        })

      TextInput({ placeholder: '确认密码' })
        .margin({ bottom: 12 })
        .onChange((value: string) => {
          this.confirmPassword = value;
        })

      if (this.error) {
        Text(this.error)
          .fontColor(Color.Red)
          .margin({ bottom: 12 })
      }

      if (this.success) {
        Text(this.success)
          .fontColor(Color.Green)
          .margin({ bottom: 12 })
      }

      Button('立即注册')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(44)
        .onClick(() => {
          if (this.loading) {
            return;
          }
          this.doRegister();
        })
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .justifyContent(FlexAlign.Start)
  }
}
