import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../common/api/HttpUtil';
import { RequestEnum } from '../common/api/httpEnum';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
}

interface HealthDataRequest {
  elder_id: number;
  measured_at: string;
  sbp: number;
  dbp: number;
  fpg: number;
  ppg_2h: number;
  weight: number;
  source: string;
  remark?: string;
}

interface HealthDataResponse {
  id: number;
  elder_id: number;
  measured_at: string;
  sbp: number;
  dbp: number;
  fpg: number;
  ppg_2h: number;
  weight: number;
}

@Component
export struct AddHealthDataForm {
  @Prop elderId: number = 0;
  @Prop elderName: string = '';
  @State sbp: string = '';
  @State dbp: string = '';
  @State fpg: string = '';
  @State ppg2h: string = '';
  @State weight: string = '';
  @State remark: string = '';
  @State isSubmitting: boolean = false;
  onSuccess: () => void = () => {};
  onCancel: () => void = () => {};

  private validateForm(): boolean {
    if (!this.sbp || isNaN(parseFloat(this.sbp))) {
      promptAction.showToast({ message: '请输入有效的收缩压' });
      return false;
    }
    if (!this.dbp || isNaN(parseFloat(this.dbp))) {
      promptAction.showToast({ message: '请输入有效的舒张压' });
      return false;
    }
    if (!this.fpg || isNaN(parseFloat(this.fpg))) {
      promptAction.showToast({ message: '请输入有效的空腹血糖' });
      return false;
    }
    if (!this.ppg2h || isNaN(parseFloat(this.ppg2h))) {
      promptAction.showToast({ message: '请输入有效的餐后血糖' });
      return false;
    }
    if (!this.weight || isNaN(parseFloat(this.weight))) {
      promptAction.showToast({ message: '请输入有效的体重' });
      return false;
    }
    return true;
  }

  private async submitForm(): Promise<void> {
    if (!this.validateForm()) return;

    this.isSubmitting = true;
    try {
      const now = new Date().toISOString();
      const data: HealthDataRequest = {
        elder_id: this.elderId,
        measured_at: now,
        sbp: parseFloat(this.sbp),
        dbp: parseFloat(this.dbp),
        fpg: parseFloat(this.fpg),
        ppg_2h: parseFloat(this.ppg2h),
        weight: parseFloat(this.weight),
        source: 'MANUAL',
        remark: this.remark || undefined
      };

      const response = await httpRequest<ApiResponse<HealthDataResponse>, HealthDataRequest>({
        url: '/api/v1/elder-health/daily-health',
        method: RequestEnum.POST,
        params: data
      });

      if (response.code === 200 || response.code === 201) {
        promptAction.showToast({ message: '健康数据添加成功' });
        this.clearForm();
        this.onSuccess();
      } else {
        promptAction.showToast({ message: response.message || '添加失败' });
      }
    } catch (error) {
      console.error('添加健康数据失败:', error);
      promptAction.showToast({ message: '添加失败，请重试' });
    } finally {
      this.isSubmitting = false;
    }
  }

  private clearForm(): void {
    this.sbp = '';
    this.dbp = '';
    this.fpg = '';
    this.ppg2h = '';
    this.weight = '';
    this.remark = '';
  }

  @Builder
  private SectionTitle(icon: string, title: string) {
    Row() {
      Text(icon).fontSize(18)
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1e293b')
        .margin({ left: 8 })
    }
    .width('100%')
    .margin({ top: 20, bottom: 12 })
  }

  @Builder
  private InputField(label: string, placeholder: string, value: string, unit: string, onChange: (v: string) => void) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#64748b')
        .width(80)
      TextInput({ text: value, placeholder: placeholder })
        .height(44)
        .fontSize(15)
        .backgroundColor('#f8fafc')
        .borderRadius(10)
        .layoutWeight(1)
        .type(InputType.NUMBER_DECIMAL)
        .onChange(onChange)
      Text(unit)
        .fontSize(13)
        .fontColor('#94a3b8')
        .width(50)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('✕')
          .fontSize(20)
          .fontColor('#64748b')
          .onClick(() => { this.onCancel(); })
        Text('添加健康数据')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1e293b')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('').width(20)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      .border({ width: { bottom: 1 }, color: '#e5e7eb' })

      Scroll() {
        Column() {
          // 老人信息
          Row() {
            Text('👴').fontSize(24)
            Column() {
              Text('数据归属').fontSize(12).fontColor('#64748b')
              Text(this.elderName || `老人ID: ${this.elderId}`)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#f8fafc')
          .borderRadius(12)

          // 血压
          this.SectionTitle('💓', '血压')
          this.InputField('收缩压', '如 120', this.sbp, 'mmHg', (v: string) => { this.sbp = v; })
          this.InputField('舒张压', '如 80', this.dbp, 'mmHg', (v: string) => { this.dbp = v; })

          // 血糖
          this.SectionTitle('🩸', '血糖')
          this.InputField('空腹血糖', '如 5.6', this.fpg, 'mmol/L', (v: string) => { this.fpg = v; })
          this.InputField('餐后血糖', '如 7.8', this.ppg2h, 'mmol/L', (v: string) => { this.ppg2h = v; })

          // 体重
          this.SectionTitle('⚖️', '体重')
          this.InputField('体重', '如 65.5', this.weight, 'kg', (v: string) => { this.weight = v; })

          // 备注
          this.SectionTitle('📝', '备注（选填）')
          TextArea({ text: this.remark, placeholder: '可填写特殊情况说明...' })
            .height(80)
            .fontSize(14)
            .backgroundColor('#f8fafc')
            .borderRadius(10)
            .onChange((v: string) => { this.remark = v; })

          // 提交按钮
          Button(this.isSubmitting ? '提交中...' : '提交数据')
            .type(ButtonType.Capsule)
            .backgroundColor('#2563eb')
            .width('100%')
            .height(48)
            .margin({ top: 30, bottom: 30 })
            .enabled(!this.isSubmitting)
            .onClick(() => { this.submitForm(); })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
  }
}
