import apiService, { ApiResponse, LoginResponseData, UserWithRolesSummary } from '../common/api/ApiService';
import router from '@ohos.router';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import HttpUtil from '../common/api/HttpUtil';

@Entry
@Component
struct Login {
  @State username: string = '';
  @State password: string = '';
  @State rememberMe: boolean = false;
  @State loading: boolean = false;
  @State error: string = '';
  private autoLoginChecked: boolean = false;

  aboutToAppear() {
    if (this.autoLoginChecked) {
      return;
    }
    this.autoLoginChecked = true;
    this.tryAutoLogin();
  }

  private async doLogin(): Promise<void> {
    this.loading = true;
    this.error = '';
    try {
      const resp: ApiResponse<LoginResponseData> = await apiService.login(this.username, this.password);
      if (resp.code === 200) {
        const data: LoginResponseData = resp.data;
        if (this.rememberMe) {
          this.saveLoginInfo(data);
        } else {
          this.clearLoginInfo();
        }
        const homeUrl: string = this.getHomeUrl(data);
        router.replaceUrl({ url: homeUrl });
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

  private tryAutoLogin(): void {
    const context = getContext(this);
    preferences.getPreferences(context, 'authStore', (err: BusinessError, pref: preferences.Preferences) => {
      if (err) {
        return;
      }
      pref.get('token', '', (getErr: BusinessError, tokenValue: preferences.ValueType) => {
        if (getErr) {
          return;
        }
        if (typeof tokenValue !== 'string') {
          return;
        }
        const token = tokenValue as string;
        if (!token || token.length === 0) {
          return;
        }
        pref.get('user', '', (userErr: BusinessError, userValue: preferences.ValueType) => {
          if (userErr) {
            return;
          }
          if (typeof userValue !== 'string') {
            return;
          }
          const userJson = userValue as string;
          let parsedUser: UserWithRolesSummary | null = null;
          try {
            const temp = JSON.parse(userJson) as UserWithRolesSummary;
            parsedUser = temp;
          } catch (parseError) {
            return;
          }
          if (parsedUser === null) {
            return;
          }
          const data: LoginResponseData = {
            token: token,
            user: parsedUser
          };
          HttpUtil.setAuthToken(token);
          const homeUrl: string = this.getHomeUrl(data);
          router.replaceUrl({ url: homeUrl });
        });
      });
    });
  }

  private saveLoginInfo(data: LoginResponseData): void {
    const context = getContext(this);
    preferences.getPreferences(context, 'authStore', (err: BusinessError, pref: preferences.Preferences) => {
      if (err) {
        return;
      }
      const userJson: string = JSON.stringify(data.user);
      pref.put('token', data.token, (putErr: BusinessError) => {
        if (putErr) {
          return;
        }
        pref.put('user', userJson, (userErr: BusinessError) => {
          if (userErr) {
            return;
          }
          pref.flush((flushErr: BusinessError) => {
            if (flushErr) {
              return;
            }
          });
        });
      });
    });
  }

  private clearLoginInfo(): void {
    const context = getContext(this);
    preferences.getPreferences(context, 'authStore', (err: BusinessError, pref: preferences.Preferences) => {
      if (err) {
        return;
      }
      pref.delete('token', (delErr: BusinessError) => {
        if (delErr) {
          return;
        }
      });
      pref.delete('user', (delUserErr: BusinessError) => {
        if (delUserErr) {
          return;
        }
      });
      pref.flush((flushErr: BusinessError) => {
        if (flushErr) {
          return;
        }
      });
    });
  }

  private getHomeUrl(data: LoginResponseData): string {
    const roles = data.user.roles;
    let hasAdmin: boolean = false;
    let hasMedical: boolean = false;
    let hasFamily: boolean = false;
    let hasElder: boolean = false;

    for (let i = 0; i < roles.length; i++) {
      const code = roles[i].role_code;
      if (code === 'admin') {
        hasAdmin = true;
      } else if (code === 'medical_staff') {
        hasMedical = true;
      } else if (code === 'family') {
        hasFamily = true;
      } else if (code === 'elder') {
        hasElder = true;
      }
    }

    if (hasAdmin || hasMedical) {
      return 'pages/medical/Index';
    }
    if (hasFamily) {
      return 'pages/family/Index';
    }
    if (hasElder) {
      return 'pages/elder/Index';
    }
    return 'pages/elder/Index';
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
