import { promptAction } from '@kit.ArkUI';
import dayjs from 'dayjs';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';
import { CardContainer } from '../../components/common/CardContainer';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
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

export interface ElderInfoEditRouteParams {
  elderId: number;
}

// Editable field types
type EditableField = 'name' | 'address' | 'height' | 'weight' | 'emergencyContact' | null;

@Builder
export function ElderInfoEditPageBuilder() {
  ElderInfoEditPage()
}

@Component
export struct ElderInfoEditPage {
  @State elder: ElderResponse | null = null;
  @State isLoading: boolean = true;
  @State isSaving: boolean = false;

  // Route params
  private elderId: number = 0;

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

  @Consume('navPathStack') navPathStack: NavPathStack;

  private async loadElderInfo(): Promise<void> {
    if (!this.elderId) {
      promptAction.showToast({ message: '缺少老人ID参数' });
      return;
    }

    this.isLoading = true;

    try {
      const response = await httpRequest<ApiResponse<ElderResponse>, void>({
        url: `/api/v1/elder-health/elder/${this.elderId}`,
        method: RequestEnum.GET
      });

      if (response.code === 200 && response.data) {
        this.elder = response.data;
        this.initForm(this.elder);
      } else {
        promptAction.showToast({ message: response.message || '加载失败' });
      }
    } catch (error) {
      console.error('加载老人信息失败:', error);
      promptAction.showToast({ message: '网络异常' });
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
        await this.loadElderInfo();
      } else {
        promptAction.showToast({ message: response.message || '保存失败' });
      }
    } catch (error) {
      promptAction.showToast({ message: '网络异常' });
    } finally {
      this.isSaving = false;
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
          Text(this.elderName || '老人')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#166534')

          if (this.elder) {
            Text(this.getGenderLabel() + ' · ' + this.elder.age + '岁')
              .fontSize(14)
              .fontColor('#64748b')
              .margin({ top: 4 })
          }

          if (this.elder?.phone) {
            Text('📱 ' + this.elder.phone)
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
    NavDestination() {
      Column() {
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
                  this.EditableTextRow('身高(cm)', 'height', '请输入身高', InputType.NUMBER_DECIMAL)
                  this.EditableTextRow('体重(kg)', 'weight', '请输入体重', InputType.NUMBER_DECIMAL)
                  this.BloodTypePickerRow()
                }
              }
            }
            .padding({ left: 16, right: 16, bottom: 30 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f8fafc')
    }
    .title('老人信息')
    .onReady((ctx: NavDestinationContext) => {
      const params = ctx.pathInfo.param as ElderInfoEditRouteParams
      if (params && params.elderId) {
        this.elderId = params.elderId
        this.loadElderInfo()
      } else {
        promptAction.showToast({ message: '缺少老人ID参数' })
      }
    })
  }
}
