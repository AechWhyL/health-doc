import { promptAction } from '@kit.ArkUI';
import router from '@ohos.router';
import { httpRequest } from '../common/api/HttpUtil';
import { RequestEnum } from '../common/api/httpEnum';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

type RoleCode = 'elder' | 'family' | 'medical_staff';

interface RegisterFormState {
  roleCode: RoleCode;
  phone: string;
  email: string;
  password: string;
  confirmPassword: string;
}

interface RegisterPayload {
  username: string;
  password: string;
  phone?: string;
  email?: string;
  role_code: RoleCode;
}

interface RoleChipConfig {
  code: RoleCode;
  title: string;
  caption: string;
}

const ROLE_CHIPS: RoleChipConfig[] = [
  {
    code: 'elder',
    title: '老人',
    caption: '用于自我管理健康档案与干预执行'
  },
  {
    code: 'family',
    title: '家属',
    caption: '可绑定老人，代录数据并发起咨询'
  },
  {
    code: 'medical_staff',
    title: '医护人员',
    caption: '管理档案与干预计划，需机构审核'
  }
];

interface CreateUserResponse {
  id: number;
}

@Entry
@Component
export struct Register {
  @State private form: RegisterFormState = {
    roleCode: 'elder',
    phone: '',
    email: '',
    password: '',
    confirmPassword: ''
  };

  @State private isSubmitting: boolean = false;
  @State private errorMessage: string = '';

  aboutToAppear(): void {
  }

  private selectRole(roleCode: RoleCode): void {
    this.form.roleCode = roleCode;
  }

  private updatePhone(value: string): void {
    this.form.phone = value;
  }

  private updateEmail(value: string): void {
    this.form.email = value;
  }

  private updatePassword(value: string): void {
    this.form.password = value;
  }

  private updateConfirmPassword(value: string): void {
    this.form.confirmPassword = value;
  }

  private validatePassword(password: string): boolean {
    if (password.length < 8) {
      return false;
    }
    let hasLetter: boolean = false;
    let hasDigit: boolean = false;
    for (let i = 0; i < password.length; i++) {
      const ch = password.charAt(i);
      if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')) {
        hasLetter = true;
      } else if (ch >= '0' && ch <= '9') {
        hasDigit = true;
      }
    }
    return hasLetter && hasDigit;
  }

  private async handleSubmit(): Promise<void> {
    if (this.isSubmitting) {
      return;
    }

    const phone = this.form.phone.trim();
    const email = this.form.email.trim();
    const password = this.form.password;
    const confirmPassword = this.form.confirmPassword;

    if (phone === '' && email === '') {
      this.errorMessage = '请至少填写手机号或邮箱';
      promptAction.showToast({
        message: this.errorMessage
      });
      return;
    }

    if (!this.validatePassword(password)) {
      this.errorMessage = '密码至少8位，且包含字母和数字';
      promptAction.showToast({
        message: this.errorMessage
      });
      return;
    }

    if (password !== confirmPassword) {
      this.errorMessage = '两次输入的密码不一致';
      promptAction.showToast({
        message: this.errorMessage
      });
      return;
    }

      this.errorMessage = '';
      this.isSubmitting = true;

    try {
      const username = phone !== '' ? phone : email;
      const payload: RegisterPayload = {
        username: username,
        password: password,
        phone: phone !== '' ? phone : undefined,
        email: email !== '' ? email : undefined,
        role_code: this.form.roleCode
      };

      const response = await httpRequest<ApiResponse<CreateUserResponse>, RegisterPayload>({
        url: '/api/v1/users',
        method: RequestEnum.POST,
        params: payload
      });

      if (response.code !== 200 || !response.data) {
        const msg = response.message || '注册失败';
        this.errorMessage = msg;
        promptAction.showToast({
          message: msg
        });
        this.isSubmitting = false;
        return;
      }

      promptAction.showToast({
        message: '注册成功，请使用账号登录'
      });

      router.replaceUrl({
        url: 'pages/Login'
      }).catch(() => {});
    } catch (error) {
      this.errorMessage = '网络异常，请稍后重试';
      promptAction.showToast({
        message: this.errorMessage
      });
    } finally {
      this.isSubmitting = false;
    }
  }

  private handleGoLogin(): void {
    router.replaceUrl({
      url: 'pages/Login'
    }).catch(() => {});
  }

  build() {
    Column() {
      Column() {
        Text('注册新账号')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 4 });

        Text('选择要注册的角色，支持老人、家属、医护人员')
          .fontSize(12)
          .fontColor('#6b7280');
      }
      .width('100%')
      .padding({ top: 32, left: 24, right: 24 });

      Column() {
        Column() {
          Text('注册角色')
            .fontSize(12)
            .fontColor('#6b7280');

          Row() {
            ForEach(ROLE_CHIPS, (chip: RoleChipConfig) => {
              Column() {
                Text(chip.title)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium);
              }
              .padding({ left: 10, right: 10, top: 8, bottom: 8 })
              .borderRadius(999)
              .border({
                width: 1,
                color: chip.code === this.form.roleCode ? '#111827' : '#e5e7eb'
              })
              .backgroundColor(chip.code === this.form.roleCode ? '#ffc2d4f8' : '#f9fafb')
              .layoutWeight(1)
              .margin({ right: 8 })
              .onClick(() => {
                this.selectRole(chip.code);
              });
            }, (chip: RoleChipConfig) => chip.code);
          }
          .margin({ top: 8 });
        }
        .margin({ top: 16 });

        Column() {
          Text('手机号')
            .fontSize(12)
            .fontColor('#6b7280');

          TextInput({ text: this.form.phone, placeholder: '用于登录与找回密码' })
            .height(40)
            .fontSize(14)
            .padding({ left: 16, right: 16 })
            .borderRadius(20)
            .backgroundColor('#f9fafb')
            .onChange((value: string) => {
              this.updatePhone(value);
            });
        }
        .margin({ top: 20 });

        // Column() {
        //   Text('邮箱（可选）')
        //     .fontSize(12)
        //     .fontColor('#6b7280');
        //
        //   TextInput({ text: this.form.email, placeholder: '也可作为登录账号' })
        //     .height(40)
        //     .fontSize(14)
        //     .padding({ left: 16, right: 16 })
        //     .borderRadius(20)
        //     .backgroundColor('#f9fafb')
        //     .onChange((value: string) => {
        //       this.updateEmail(value);
        //     });
        // }
        // .margin({ top: 16 });

        Column() {
          Text('登录密码')
            .fontSize(12)
            .fontColor('#6b7280');

          TextInput({ text: this.form.password, placeholder: '至少8位，包含字母和数字' })
            .type(InputType.Password)
            .height(40)
            .fontSize(14)
            .padding({ left: 16, right: 16 })
            .borderRadius(20)
            .backgroundColor('#f9fafb')
            .onChange((value: string) => {
              this.updatePassword(value);
            });

          Text('密码强度校验：长度≥8，包含字母和数字')
            .fontSize(11)
            .fontColor('#9ca3af')
            .margin({ top: 4 });
        }
        .margin({ top: 16 });

        Column() {
          Text('确认密码')
            .fontSize(12)
            .fontColor('#6b7280');

          TextInput({ text: this.form.confirmPassword, placeholder: '再次输入以确认密码' })
            .type(InputType.Password)
            .height(40)
            .fontSize(14)
            .padding({ left: 16, right: 16 })
            .borderRadius(20)
            .backgroundColor('#f9fafb')
            .onChange((value: string) => {
              this.updateConfirmPassword(value);
            });
        }
        .margin({ top: 16 });

        if (this.errorMessage !== '') {
          Text(this.errorMessage)
            .fontSize(12)
            .fontColor('#dc2626')
            .margin({ top: 8 });
        }

        Button(this.isSubmitting ? '正在注册...' : '立即注册并登录')
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

        Button('已有账号？去登录')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(42)
          .margin({ top: 12 })
          .backgroundColor('#f9fafb')
          .fontColor('#111827')
          .border({
            width: 1,
            color: '#e5e7eb'
          })
          .onClick(() => {
            this.handleGoLogin();
          });
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 8 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f2f4f7');
  }
}
