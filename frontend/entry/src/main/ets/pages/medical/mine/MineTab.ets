import { Binding, promptAction, router, UIUtils } from '@kit.ArkUI';
import dayjs from 'dayjs';
import { httpRequest } from '../../../common/api/HttpUtil';
import { RequestEnum } from '../../../common/api/httpEnum';
import { preferenceUtils } from '../../../common/preferenceUtils';
import { CardContainer } from '../../../components/common/CardContainer';

interface MedicalStaffInfo {
  id: number;
  gender: number;
  birth_date: string | null;
  role_type: string;
  job_title: string | null;
  good_at_tags: string | null;
  enable_online_service: boolean;
}

interface UserWithRoleResponse {
  id: number;
  username: string;
  email: string | null;
  phone: string | null;
  real_name: string | null;
  avatar: string | null;
  medical_staff_info?: MedicalStaffInfo;
}

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
}

interface UpdateMedicalStaffPayload {
  real_name?: string;
  gender?: number;
  birth_date?: string;
  role_type?: string;
  job_title?: string;
  good_at_tags?: string;
  enable_online_service?: boolean;
}

// Editable field types
type EditableField = 'realName' | 'roleType' | 'jobTitle' | 'goodAtTags' | null;

@Component
export struct MineTab {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State user: UserWithRoleResponse | null = null;
  @State isLoading: boolean = false;
  @State isSaving: boolean = false;
  // Stored original values (from server)
  @State realName: string = '';
  @State gender: number = 0;
  @State birthDate: string = '';
  @State roleType: string = '';
  @State jobTitle: string = '';
  @State goodAtTags: string = '';
  @State enableOnlineService: boolean = false;
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
    if (this.gender === 0) {
      return '男';
    }
    if (this.gender === 1) {
      return '女';
    }
    return '其他';
  }

  // Format date to YYYY-MM-DD without timezone issues
  formatDateToYYYYMMDD(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // Format birth date for display (human readable)
  formatBirthDateForDisplay(): string {
    if (!this.birthDate) {
      return '请选择';
    }
    return dayjs(this.birthDate).format('YYYY年M月D日');
  }

  async loadUserInfo(): Promise<void> {
    this.isLoading = true;
    try {
      const response = await httpRequest<ApiResponse<UserWithRoleResponse>, void>({
        url: '/api/v1/users/current',
        method: RequestEnum.GET
      });

      if (response.code === 200 && response.data) {
        this.user = response.data;
        console.log("[Medical MineTab] " + this.user.medical_staff_info?.enable_online_service)
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

  initForm(user: UserWithRoleResponse): void {
    this.realName = user.real_name || '';
    if (user.medical_staff_info) {
      const info = user.medical_staff_info;
      this.gender = info.gender;
      this.birthDate = info.birth_date || '';
      this.roleType = info.role_type || '';
      this.jobTitle = info.job_title || '';
      this.goodAtTags = info.good_at_tags || '';
      this.enableOnlineService = info.enable_online_service;
    }
  }

  startEditing(field: EditableField): void {
    if (field === null) {
      return;
    }
    this.editingField = field;
    if (field === 'realName') {
      this.editingValue = this.realName;
    } else if (field === 'roleType') {
      this.editingValue =
        this.roleType;
    } else if (field === 'jobTitle') {
      this.editingValue = this.jobTitle;
    } else if (field ===
      'goodAtTags') {
      this.editingValue = this.goodAtTags;
    }
  }

  cancelEditing(): void {
    this.editingField = null;
    this.editingValue = '';
  }

  async saveField(field: EditableField): Promise<void> {
    if (field === null) {
      return;
    }
    const payload: UpdateMedicalStaffPayload = {
      gender: this.gender,
      role_type: this.roleType,
      enable_online_service: this.enableOnlineService
    };

    if (field === 'realName') {
      payload.real_name = this.editingValue;
    } else if (field === 'roleType') {
      payload.role_type =
        this.editingValue;
    } else if (field === 'jobTitle') {
      payload.job_title = this.editingValue;
    } else if (field ===
      'goodAtTags') {
      payload.good_at_tags = this.editingValue;
    }

    await this.submitUpdate(payload, () => {
      if (field === 'realName') {
        this.realName = this.editingValue;
      } else if (field === 'roleType') {
        this.roleType =
          this.editingValue;
      } else if (field === 'jobTitle') {
        this.jobTitle = this.editingValue;
      } else if (field ===
        'goodAtTags') {
        this.goodAtTags = this.editingValue;
      }
      this.cancelEditing();
    });
  }

  async saveGender(newGender: number): Promise<void> {
    const payload: UpdateMedicalStaffPayload = {
      gender: newGender,
      role_type: this.roleType,
      enable_online_service: this.enableOnlineService
    };
    await this.submitUpdate(payload, () => {
      this.gender = newGender;
    });
  }

  async saveBirthDate(newDate: string): Promise<void> {
    const payload: UpdateMedicalStaffPayload = {
      gender: this.gender,
      role_type: this.roleType,
      birth_date: newDate,
      enable_online_service: this.enableOnlineService
    };
    await this.submitUpdate(payload, () => {
      this.birthDate = newDate;
    });
  }

  async saveOnlineService(isOn: boolean): Promise<void> {
    const payload: UpdateMedicalStaffPayload = {
      gender: this.gender,
      role_type: this.roleType,
      enable_online_service: isOn
    };
    await this.submitUpdate(payload, () => {
      this.enableOnlineService = isOn;
    });
  }

  async submitUpdate(payload: UpdateMedicalStaffPayload, onSuccess: () => void): Promise<void> {
    if (this.isSaving) {
      return;
    }
    this.isSaving = true;
    try {
      const response = await httpRequest<ApiResponse, UpdateMedicalStaffPayload>({
        url: '/api/v1/users/me/medical-staff',
        method: RequestEnum.POST,
        params: payload
      });

      if (response.code === 200) {
        promptAction.showToast({ message: '保存成功' });
        onSuccess();
        // Reload user info to refresh UI with server data
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
        Text(this.gender === 1 ? '👩‍⚕️' : '👨‍⚕️')
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
  EditableTextRow(label: string, field: EditableField, value: Binding<string>, placeholder: string = '') {
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
            .padding({
              left: 12,
              right: 12,
              top: 10,
              bottom: 10
            })
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
        // Display mode - use passed value for reactivity
        Row() {
          Text(value.value || placeholder)
            .fontSize(15)
            .fontColor(value ? '#1e293b' : '#9ca3af')
            .layoutWeight(1)

          Text('修改')
            .fontSize(13)
            .fontColor('#2563eb')
            .onClick(() => {
              this.startEditing(field);
            })
        }
        .width('100%')
        .padding({ top: 10, bottom: 10 })
        .backgroundColor('#f8fafc')
        .borderRadius(8)
        .padding({
          left: 12,
          right: 12,
          top: 10,
          bottom: 10
        })
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
        { value: '男' } as SelectOption,
        { value: '女' } as SelectOption,
        { value: '其他' } as SelectOption
      ])
        .selected(this.gender)
        .value(this.getGenderLabel())
        .font({ size: 15, weight: 400 })
        .fontColor('#1e293b')
        .selectedOptionFont({ size: 15, weight: 500 })
        .optionFont({ size: 15, weight: 400 })
        .onSelect((index: number) => {
          if (index !== this.gender) {
            this.saveGender(index);
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

  @Builder
  BirthDatePickerRow() {
    Column() {
      Text('出生日期')
        .fontSize(13)
        .fontColor('#64748b')
        .width('100%')
        .margin({ bottom: 6 })

      Row() {
        if(this.birthDate){
          Text(dayjs(this.birthDate).format('YYYY年M月D日'))
            .fontSize(15)
            .fontColor(this.birthDate ? '#1e293b' : '#9ca3af')
            .layoutWeight(1)
        }else{
          Text(
            "请选择"
          )
            .fontSize(15)
            .fontColor(this.birthDate ? '#1e293b' : '#9ca3af')
            .layoutWeight(1)
        }


        Text('选择')
          .fontSize(13)
          .fontColor('#2563eb')
          .onClick(() => {
            DatePickerDialog.show({
              start: new Date('1920-1-1'),
              end: new Date(),
              selected: this.birthDate ? new Date(this.birthDate) : new Date('1970-1-1'),
              onDateAccept: (value: Date) => {
                // Use local date parts to avoid timezone issues
                const dateStr = this.formatDateToYYYYMMDD(value);
                this.saveBirthDate(dateStr);
              }
            });
          })
      }
      .width('100%')
      .padding({
        left: 12,
        right: 12,
        top: 10,
        bottom: 10
      })
      .backgroundColor('#f8fafc')
      .borderRadius(8)
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  @Builder
  OnlineServiceRow() {
    Row() {
      Column() {
        Text('开启在线咨询服务')
          .fontSize(15)
          .fontColor('#1e293b')
          .fontWeight(FontWeight.Medium)
        Text('开启后，患者可在咨询列表中找到您')
          .fontSize(12)
          .fontColor('#64748b')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.enableOnlineService })
        .selectedColor('#2563eb')
        .onChange((isOn: boolean) => {
          this.saveOnlineService(isOn);
        })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
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

            CardContainer({ title: '基本信息' }) {
              Column() {
                this.EditableTextRow('真实姓名', 'realName', UIUtils.makeBinding(() => this.realName), '请输入真实姓名')
                this.GenderPickerRow()
                this.BirthDatePickerRow()
              }
            }

            CardContainer({ title: '职业信息' }) {
              Column() {
                this.EditableTextRow('医护类型', 'roleType', UIUtils.makeBinding(() => this.roleType), '例如：医生、护士')
                this.EditableTextRow('职称', 'jobTitle', UIUtils.makeBinding(() => this.jobTitle), '例如：主任医师')
                this.EditableTextRow('擅长领域', 'goodAtTags', UIUtils.makeBinding(() => this.goodAtTags),
                  '多个标签用逗号分隔')
              }
            }

            CardContainer({ title: '服务设置' }) {
              this.OnlineServiceRow()
            }

            CardContainer({ title: '管理' }) {
              Column() {
                Row() {
                  Text('关联老人')
                    .fontSize(15)
                    .fontColor('#1e293b')
                    .layoutWeight(1)
                  
                  Text('查看/添加')
                    .fontSize(13)
                    .fontColor('#9ca3af')
                    .margin({ right: 4 })

                  Text('›')
                    .fontSize(18)
                    .fontColor('#cbd5e1')
                }
                .width('100%')
                .padding({ left: 12, right: 12, top: 14, bottom: 14 })
                .backgroundColor('#f8fafc')
                .borderRadius(8)
                .onClick(() => {
                  this.navPathStack.pushPath({ name: 'Common_AssociatedElders' });
                })
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
