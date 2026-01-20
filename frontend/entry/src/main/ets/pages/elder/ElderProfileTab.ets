import { promptAction } from '@kit.ArkUI';
import dayjs from 'dayjs';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';
import { preferenceUtils } from '../../common/preferenceUtils';
import { CardContainer } from '../../components/common/CardContainer';
import router from '@ohos.router';

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
}

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
  elder_info?: ElderResponse;
}

interface ElderResponse {
  id: number;
  name: string;
  gender: number;
  birth_date: string;
  phone: string;
  address: string | null;
  emergency_contact: string;
  height: number | null;
  weight: number | null;
  blood_type: string | null;
  age: number;
}

interface UpdateElderPayload {
  name?: string;
  gender?: number;
  birth_date?: string;
  address?: string;
  height?: number | null;
  weight?: number | null;
  blood_type?: string;
  emergency_contact?: string;
}

// Editable field types
type EditableField = 'name' | 'address' | 'height' | 'weight' | 'emergencyContact' | null;

@Component
export struct ElderProfileTab {
  @State user: UserResponse | null = null;
  @State elder: ElderResponse | null = null;
  @State isLoading: boolean = true;
  @State isSaving: boolean = false;

  // Editable fields - stored values
  @State elderName: string = '';
  @State elderGender: number = 1;
  @State elderBirthDate: string = '';
  @State elderAddress: string = '';
  @State elderHeight: string = '';
  @State elderWeight: string = '';
  @State elderBloodType: string = '';
  @State elderEmergencyContact: string = '';

  // Editing state
  @State editingField: EditableField = null;
  @State editingValue: string = '';

  aboutToAppear(): void {
    this.loadUserInfo();
  }

  private async loadUserInfo(): Promise<void> {
    this.isLoading = true;

    try {
      // 优先从服务器获取最新用户信息
      const response = await httpRequest<ApiResponse<UserResponse>, void>({
        url: '/api/v1/users/current',
        method: RequestEnum.GET
      });

      if (response.code === 200 && response.data) {
        this.user = response.data;
        // 如果是老人用户，直接从 elder_info 获取档案
        if (this.user.elder_info) {
          this.elder = this.user.elder_info;
          this.initForm(this.elder);
        }
        
        // 更新本地存储
        const context = getContext(this);
        await preferenceUtils().set(context, 'user_store', 'current_user', JSON.stringify(this.user));
      } else {
        // 失败时尝试读取本地缓存
        const context = getContext(this);
        const userStr = await preferenceUtils().get(context, 'user_store', 'current_user') as string;
        if (userStr) {
          this.user = JSON.parse(userStr) as UserResponse;
          if (this.user.elder_info) {
            this.elder = this.user.elder_info;
            this.initForm(this.elder);
          }
        }
      }
    } catch (error) {
      console.error('加载用户信息失败:', error);
      // 网络异常时也尝试读取本地缓存
      const context = getContext(this);
        const userStr = await preferenceUtils().get(context, 'user_store', 'current_user') as string;
        if (userStr) {
          this.user = JSON.parse(userStr) as UserResponse;
          if (this.user.elder_info) {
            this.elder = this.user.elder_info;
            this.initForm(this.elder);
          }
        }
    } finally {
      this.isLoading = false;
    }
  }

  initForm(elder: ElderResponse): void {
    this.elderName = elder.name || '';
    this.elderGender = elder.gender;
    this.elderBirthDate = elder.birth_date || '';
    this.elderAddress = elder.address || '';
    this.elderHeight = elder.height ? String(elder.height) : '';
    this.elderWeight = elder.weight ? String(elder.weight) : '';
    this.elderBloodType = elder.blood_type || '';
    this.elderEmergencyContact = elder.emergency_contact || '';
  }

  getFieldValue(field: EditableField): string {
    if (field === 'name') return this.elderName;
    if (field === 'address') return this.elderAddress;
    if (field === 'height') return this.elderHeight;
    if (field === 'weight') return this.elderWeight;
    if (field === 'emergencyContact') return this.elderEmergencyContact;
    return '';
  }

  startEditing(field: EditableField): void {
    if (field === null) return;
    this.editingField = field;
    this.editingValue = this.getFieldValue(field);
  }

  cancelEditing(): void {
    this.editingField = null;
    this.editingValue = '';
  }

  async saveField(field: EditableField): Promise<void> {
    if (field === null || !this.elder) return;
    const payload: UpdateElderPayload = {};

    if (field === 'name') payload.name = this.editingValue;
    else if (field === 'address') payload.address = this.editingValue;
    else if (field === 'height') payload.height = this.editingValue ? parseFloat(this.editingValue) : null;
    else if (field === 'weight') payload.weight = this.editingValue ? parseFloat(this.editingValue) : null;
    else if (field === 'emergencyContact') payload.emergency_contact = this.editingValue;

    await this.submitUpdate(payload, () => {
      if (field === 'name') this.elderName = this.editingValue;
      else if (field === 'address') this.elderAddress = this.editingValue;
      else if (field === 'height') this.elderHeight = this.editingValue;
      else if (field === 'weight') this.elderWeight = this.editingValue;
      else if (field === 'emergencyContact') this.elderEmergencyContact = this.editingValue;
      this.cancelEditing();
    });
  }

  async saveGender(newGender: number): Promise<void> {
    if (!this.elder) return;
    const payload: UpdateElderPayload = { gender: newGender };
    await this.submitUpdate(payload, () => {
      this.elderGender = newGender;
    });
  }

  async saveBirthDate(dateStr: string): Promise<void> {
    if (!this.elder) return;
    const payload: UpdateElderPayload = { birth_date: dateStr };
    await this.submitUpdate(payload, () => {
      this.elderBirthDate = dateStr;
    });
  }

  async saveBloodType(bloodType: string): Promise<void> {
    if (!this.elder) return;
    const payload: UpdateElderPayload = { blood_type: bloodType };
    await this.submitUpdate(payload, () => {
      this.elderBloodType = bloodType;
    });
  }

  async submitUpdate(payload: UpdateElderPayload, onSuccess: () => void): Promise<void> {
    if (this.isSaving || !this.elder) return;
    this.isSaving = true;
    try {
      const response = await httpRequest<ApiResponse, UpdateElderPayload>({
        url: `/api/v1/elder-health/elder/${this.elder.id}`,
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

  private async handleLogout(): Promise<void> {
    try {
      const context = getContext(this);
      await preferenceUtils().deleteFn(context, 'token_store', 'token');
      await preferenceUtils().deleteFn(context, 'user_store', 'current_user');

      router.replaceUrl({
        url: 'pages/Login'
      });
    } catch (error) {
      console.error('退出登录失败:', error);
      promptAction.showToast({ message: '退出失败，请重试' });
    }
  }

  getGenderLabel(): string {
    return this.elderGender === 1 ? '男' : '女';
  }

  formatBirthDateForDisplay(): string {
    if (!this.elderBirthDate) return '请选择';
    return dayjs(this.elderBirthDate).format('YYYY年M月D日');
  }

  formatDateToYYYYMMDD(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  @Builder
  ProfileCard() {
    Column() {
      // 头像和基本信息
      Row() {
        Column() {
          Text(this.elderGender === 1 ? '👴' : '👵')
            .fontSize(48)
        }
        .width(80)
        .height(80)
        .borderRadius(40)
        .backgroundColor('#dcfce7')
        .justifyContent(FlexAlign.Center)

        Column() {
          Text(this.elderName || this.user?.real_name || this.user?.username || '用户')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#166534')

          if (this.elder) {
            Text(this.getGenderLabel() + ' · ' + this.elder.age + '岁')
              .fontSize(14)
              .fontColor('#64748b')
              .margin({ top: 4 })
          }

          if (this.user?.phone) {
            Text('📱 ' + this.user.phone)
              .fontSize(13)
              .fontColor('#94a3b8')
              .margin({ top: 6 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 6, color: '#0f172a0a', offsetY: 2 })
    .margin({ bottom: 16 })
  }

  @Builder
  EditableTextRow(label: string, field: EditableField, placeholder: string = '', keyboardType?: InputType) {
    Column() {
      Text(label)
        .fontSize(13)
        .fontColor('#64748b')
        .width('100%')
        .margin({ bottom: 6 })

      if (this.editingField === field) {
        Row() {
          TextInput({ text: this.editingValue, placeholder: placeholder })
            .fontSize(15)
            .fontColor('#1e293b')
            .backgroundColor('#f1f5f9')
            .borderRadius(8)
            .padding({ left: 12, right: 12, top: 10, bottom: 10 })
            .layoutWeight(1)
            .border({ width: 2, color: '#16a34a', radius: 8 })
            .type(keyboardType || InputType.Normal)
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
            .fontColor('#16a34a')
            .fontWeight(FontWeight.Medium)
            .padding({ left: 8, right: 4 })
            .onClick(() => {
              this.saveField(field);
            })
        }
        .width('100%')
      } else {
        Row() {
          Text(this.getFieldValue(field) || placeholder)
            .fontSize(15)
            .fontColor(this.getFieldValue(field) ? '#1e293b' : '#9ca3af')
            .layoutWeight(1)

          Text('修改')
            .fontSize(13)
            .fontColor('#16a34a')
            .onClick(() => {
              this.startEditing(field);
            })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .backgroundColor('#f0fdf4')
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
        .selected(this.elderGender)
        .value(this.getGenderLabel())
        .font({ size: 15, weight: 400 })
        .fontColor('#1e293b')
        .selectedOptionFont({ size: 15, weight: 500 })
        .optionFont({ size: 15, weight: 400 })
        .onSelect((index: number) => {
          if (index !== this.elderGender) {
            this.saveGender(index);
          }
        })
        .width('100%')
        .height(48)
        .backgroundColor('#f0fdf4')
        .borderRadius(8)
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  @Builder
  BirthDatePickerRow() {
    Column() {
      Text('出生日期')
        .fontSize(13)
        .fontColor('#64748b')
        .width('100%')
        .margin({ bottom: 6 })

      Row() {
        Text(this.formatBirthDateForDisplay())
          .fontSize(15)
          .fontColor(this.elderBirthDate ? '#1e293b' : '#9ca3af')
          .layoutWeight(1)

        Text('选择')
          .fontSize(13)
          .fontColor('#16a34a')
          .onClick(() => {
            DatePickerDialog.show({
              start: new Date('1920-1-1'),
              end: new Date(),
              selected: this.elderBirthDate ? new Date(this.elderBirthDate) : new Date('1950-1-1'),
              onDateAccept: (value: Date) => {
                const dateStr = this.formatDateToYYYYMMDD(value);
                this.saveBirthDate(dateStr);
              }
            });
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .backgroundColor('#f0fdf4')
      .borderRadius(8)
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  @Builder
  BloodTypePickerRow() {
    Column() {
      Text('血型')
        .fontSize(13)
        .fontColor('#64748b')
        .width('100%')
        .margin({ bottom: 6 })

      Select([
        { value: '未选择' } as SelectOption,
        { value: 'A' } as SelectOption,
        { value: 'B' } as SelectOption,
        { value: 'AB' } as SelectOption,
        { value: 'O' } as SelectOption
      ])
        .selected(this.elderBloodType ? ['', 'A', 'B', 'AB', 'O'].indexOf(this.elderBloodType) : 0)
        .value(this.elderBloodType || '未选择')
        .font({ size: 15, weight: 400 })
        .fontColor('#1e293b')
        .selectedOptionFont({ size: 15, weight: 500 })
        .optionFont({ size: 15, weight: 400 })
        .onSelect((index: number) => {
          const bloodTypes = ['', 'A', 'B', 'AB', 'O'];
          const newBloodType = bloodTypes[index];
          if (newBloodType !== this.elderBloodType) {
            this.saveBloodType(newBloodType);
          }
        })
        .width('100%')
        .height(48)
        .backgroundColor('#f0fdf4')
        .borderRadius(8)
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  build() {
    Column() {
      // 页面标题
      Row() {
        Text('个人中心')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#166534')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#16a34a')
          Text('加载中...').fontSize(14).fontColor('#64748b').margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            this.ProfileCard()

            CardContainer({ title: '基本信息' }) {
              Column() {
                this.EditableTextRow('姓名', 'name', '请输入姓名')
                this.GenderPickerRow()
                this.BirthDatePickerRow()
              }
            }

            CardContainer({ title: '联系信息' }) {
              Column() {
                this.EditableTextRow('家庭住址', 'address', '请输入家庭住址')
                this.EditableTextRow('紧急联系人', 'emergencyContact', '请输入紧急联系人')
              }
            }

            CardContainer({ title: '健康档案' }) {
              Column() {
                this.EditableTextRow('身高(cm)', 'height', '请输入身高', InputType.Number)
                this.EditableTextRow('体重(kg)', 'weight', '请输入体重', InputType.Number)
                this.BloodTypePickerRow()
              }
            }

            // 退出登录按钮
            Button('退出登录')
              .type(ButtonType.Capsule)
              .width('100%')
              .height(48)
              .backgroundColor('#fef2f2')
              .fontColor('#dc2626')
              .fontSize(15)
              .margin({ top: 8, bottom: 32 })
              .onClick(() => {
                this.handleLogout();
              })
          }
          .padding({ left: 16, right: 16, bottom: 30 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
  }
}
