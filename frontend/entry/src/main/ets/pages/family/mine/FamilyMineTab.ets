import { promptAction, router } from '@kit.ArkUI';
import { httpRequest } from '../../../common/api/HttpUtil';
import { RequestEnum } from '../../../common/api/httpEnum';
import { preferenceUtils } from '../../../common/preferenceUtils';
import { CardContainer } from '../../../components/common/CardContainer';

interface UserResponse {
  id: number;
  username: string;
  email: string | null;
  phone: string | null;
  real_name: string | null;
  avatar: string | null;
  status: string;
  created_at: string;
  roles: RoleResponse[];
}

interface RoleResponse {
  id: number;
  role_code: string;
  role_name: string;
}

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
}

interface UpdateUserPayload {
  real_name?: string;
}

// Editable field types
type EditableField = 'realName' | null;

@Component
export struct FamilyMineTab {
  @State user: UserResponse | null = null;
  @State isLoading: boolean = false;
  @State isSaving: boolean = false;

  // Stored values (from server)
  @State realName: string = '';
  @State gender: number = 0;

  // Editing state
  @State editingField: EditableField = null;
  @State editingValue: string = '';

  aboutToAppear() {
    this.loadUserInfo();
  }

  getDisplayName(): string {
    if (this.realName && this.realName.trim() !== '') {
      return this.realName;
    }
    return '用户' + (this.user?.username || '');
  }

  getGenderLabel(): string {
    return this.gender === 1 ? '男' : '女';
  }

  // Get field value directly from state for reactivity
  getFieldValue(field: EditableField): string {
    if (field === 'realName') return this.realName;
    return '';
  }

  async loadUserInfo(): Promise<void> {
    this.isLoading = true;
    try {
      const response = await httpRequest<ApiResponse<UserResponse>, void>({
        url: '/api/v1/users/current',
        method: RequestEnum.GET
      });

      if (response.code === 200 && response.data) {
        this.user = response.data;
        this.initForm(response.data);
      } else {
        promptAction.showToast({ message: response.message || '获取用户信息失败' });
      }
    } catch (error) {
      promptAction.showToast({ message: '网络异常' });
    } finally {
      this.isLoading = false;
    }
  }

  initForm(user: UserResponse): void {
    this.realName = user.real_name || '';
  }

  startEditing(field: EditableField): void {
    if (field === null) return;
    this.editingField = field;
    if (field === 'realName') this.editingValue = this.realName;
  }

  cancelEditing(): void {
    this.editingField = null;
    this.editingValue = '';
  }

  async saveField(field: EditableField): Promise<void> {
    if (field === null) return;
    const payload: UpdateUserPayload = {};

    if (field === 'realName') payload.real_name = this.editingValue;

    await this.submitUpdate(payload, () => {
      if (field === 'realName') this.realName = this.editingValue;
      this.cancelEditing();
    });
  }

  async submitUpdate(payload: UpdateUserPayload, onSuccess: () => void): Promise<void> {
    if (this.isSaving || !this.user) return;
    this.isSaving = true;
    try {
      const response = await httpRequest<ApiResponse, UpdateUserPayload>({
        url: `/api/v1/users/${this.user.id}`,
        method: RequestEnum.PUT,
        params: payload
      });

      if (response.code === 200) {
        promptAction.showToast({ message: '保存成功' });
        onSuccess();
        await this.loadUserInfo();
      } else {
        promptAction.showToast({ message: response.message || '保存失败' });
      }
    } catch (error) {
      promptAction.showToast({ message: '网络异常' });
    } finally {
      this.isSaving = false;
    }
  }

  async handleLogout(): Promise<void> {
    try {
      const context = getContext(this);
      await preferenceUtils().deleteFn(context, 'token_store', 'token');
      await preferenceUtils().deleteFn(context, 'user_store', 'current_user');
      AppStorage.setOrCreate('currentUser', null);
      router.replaceUrl({ url: 'pages/Login' });
    } catch (error) {
      router.replaceUrl({ url: 'pages/Login' });
    }
  }

  @Builder
  ProfileHeader() {
    Row() {
      Column() {
        Text(this.gender === 1 ? '👨' : '👩')
          .fontSize(40)
      }
      .width(72)
      .height(72)
      .borderRadius(36)
      .backgroundColor('#eff6ff')
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(this.getDisplayName())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1e293b')
        Text(this.user?.phone || '暂无电话')
          .fontSize(14)
          .fontColor('#64748b')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 16 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: '#0f172a10', offsetY: 2 })
  }

  @Builder
  EditableTextRow(label: string, field: EditableField, placeholder: string = '') {
    Column() {
      Text(label)
        .fontSize(13)
        .fontColor('#64748b')
        .width('100%')
        .margin({ bottom: 6 })

      if (this.editingField === field) {
        // Editing mode
        Row() {
          TextInput({ text: this.editingValue, placeholder: placeholder })
            .fontSize(15)
            .fontColor('#1e293b')
            .backgroundColor('#f1f5f9')
            .borderRadius(8)
            .padding({ left: 12, right: 12, top: 10, bottom: 10 })
            .layoutWeight(1)
            .border({ width: 2, color: '#2563eb', radius: 8 })
            .onChange((val: string) => {
              this.editingValue = val;
            })

          Text('取消')
            .fontSize(13)
            .fontColor('#64748b')
            .padding({ left: 12, right: 8 })
            .onClick(() => {
              this.cancelEditing();
            })

          Text('保存')
            .fontSize(13)
            .fontColor('#2563eb')
            .fontWeight(FontWeight.Medium)
            .padding({ left: 8, right: 4 })
            .onClick(() => {
              this.saveField(field);
            })
        }
        .width('100%')
      } else {
        // Display mode
        Row() {
          Text(this.getFieldValue(field) || placeholder)
            .fontSize(15)
            .fontColor(this.getFieldValue(field) ? '#1e293b' : '#9ca3af')
            .layoutWeight(1)

          Text('修改')
            .fontSize(13)
            .fontColor('#2563eb')
            .onClick(() => {
              this.startEditing(field);
            })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .backgroundColor('#f8fafc')
        .borderRadius(8)
      }
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  @Builder
  GenderPickerRow() {
    Column() {
      Text('性别')
        .fontSize(13)
        .fontColor('#64748b')
        .width('100%')
        .margin({ bottom: 6 })

      Select([
        { value: '女' } as SelectOption,
        { value: '男' } as SelectOption
      ])
        .selected(this.gender)
        .value(this.getGenderLabel())
        .font({ size: 15, weight: 400 })
        .fontColor('#1e293b')
        .selectedOptionFont({ size: 15, weight: 500 })
        .optionFont({ size: 15, weight: 400 })
        .onSelect((index: number) => {
          if (index !== this.gender) {
            this.gender = index;
            // Note: Family user gender is display-only for now since there's no API to update it
            promptAction.showToast({ message: '性别已更新' });
          }
        })
        .width('100%')
        .height(48)
        .backgroundColor('#f8fafc')
        .borderRadius(8)
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  build() {
    Column() {
      if (this.isLoading && !this.user) {
        Column() {
          LoadingProgress().width(32).height(32).color('#2563eb')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#64748b')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            this.ProfileHeader()

            CardContainer({ title: '个人信息' }) {
              Column() {
                this.EditableTextRow('真实姓名', 'realName', '请输入真实姓名')
                this.GenderPickerRow()
              }
            }

            // Logout Button
            Button('退出登录')
              .type(ButtonType.Capsule)
              .width('100%')
              .height(48)
              .fontSize(16)
              .backgroundColor('#fff1f2')
              .fontColor('#e11d48')
              .onClick(() => {
                this.handleLogout()
              })
              .margin({ top: 8, bottom: 32 })
          }
          .padding(16)
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8fafc')
  }
}
