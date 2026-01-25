import { HealthRecordForm } from '../../components/medical/HealthRecordForm';
import {
  HealthRecordType,
  HealthRecordFormSubmitPayload,
  AddHealthRecordParams,
  CreateHealthRecordPayload,
  UpdateHealthRecordPayload
} from '../../models/HealthArchiveModels';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

/**
 * 添加/编辑健康档案页面
 * 独立的 NavDestination 页面,替代原有的 Dialog
 */
@Builder
export function AddHealthRecordPageBuilder() {
  AddHealthRecordPage()
}

@ComponentV2
export struct AddHealthRecordPage {
  // ==================== 导航参数 ====================
  @Local private params: AddHealthRecordParams = {
    elderId: 0,
    elderName: '',
    mode: 'create'
  };

  // ==================== 状态 ====================
  @Local private isSubmitting: boolean = false;
  @Local private selectedRecordType: HealthRecordType = 'MEDICAL_HISTORY';

  // ==================== 导航栈 ====================
  private navPathStack: NavPathStack = new NavPathStack();

  // ==================== 工具方法 ====================
  private getRecordTypeLabel(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '病史记录';
      case 'CHECK_REPORT': return '检查报告';
      case 'MEDICATION': return '用药记录';
      case 'ALLERGY': return '过敏记录';
    }
  }

  private getRecordTypeIcon(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '🏥';
      case 'CHECK_REPORT': return '🔬';
      case 'MEDICATION': return '💊';
      case 'ALLERGY': return '⚠️';
    }
  }

  private getRecordTypeColor(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '#1d4ed8';
      case 'CHECK_REPORT': return '#15803d';
      case 'MEDICATION': return '#b91c1c';
      case 'ALLERGY': return '#c2410c';
    }
  }

  private getRecordTypeBgColor(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '#eff6ff';
      case 'CHECK_REPORT': return '#f0fdf4';
      case 'MEDICATION': return '#fef2f2';
      case 'ALLERGY': return '#fff7ed';
    }
  }

  // ==================== 业务逻辑 ====================
  private async handleSubmit(payload: HealthRecordFormSubmitPayload): Promise<void> {
    if (this.isSubmitting) {
      return;
    }

    this.isSubmitting = true;

    try {
      if (this.params.mode === 'create') {
        await this.handleCreate(payload);
      } else {
        await this.handleEdit(payload);
      }
    } finally {
      this.isSubmitting = false;
    }
  }

  private async handleCreate(payload: HealthRecordFormSubmitPayload): Promise<void> {
    const createPayload: CreateHealthRecordPayload = {
      elder_id: this.params.elderId,
      record_type: payload.recordType,
      record_title: payload.recordTitle,
      record_date: payload.recordDate,
      content_structured: payload.contentStructured
    };

    try {
      const response = await httpRequest<ApiResponse<Object>, CreateHealthRecordPayload>({
        url: '/api/v1/elder-health/health-record',
        method: RequestEnum.POST,
        token: 'auth',
        params: createPayload
      });

      if (response.code !== 200) {
        const msg = response.message || '创建健康记录失败';
        this.getUIContext().getPromptAction().showToast({ message: msg });
        return;
      }

      this.getUIContext().getPromptAction().showToast({ message: '创建健康记录成功' });
      this.navPathStack.pop(true); // 返回并触发刷新
    } catch (_error) {
      this.getUIContext().getPromptAction().showToast({ message: '网络异常,创建健康记录失败' });
    }
  }

  private async handleEdit(payload: HealthRecordFormSubmitPayload): Promise<void> {
    if (!this.params.editRecord) {
      return;
    }

    const updatePayload: UpdateHealthRecordPayload = {
      record_type: payload.recordType,
      record_title: payload.recordTitle,
      record_date: payload.recordDate,
      content_structured: payload.contentStructured
    };

    try {
      const response = await httpRequest<ApiResponse<Object>, UpdateHealthRecordPayload>({
        url: '/api/v1/elder-health/health-record/' + this.params.editRecord.id.toString(),
        method: RequestEnum.PUT,
        token: 'auth',
        params: updatePayload
      });

      if (response.code !== 200) {
        const msg = response.message || '更新健康记录失败';
        this.getUIContext().getPromptAction().showToast({ message: msg });
        return;
      }

      this.getUIContext().getPromptAction().showToast({ message: '更新健康记录成功' });
      this.navPathStack.pop(true); // 返回并触发刷新
    } catch (_error) {
      this.getUIContext().getPromptAction().showToast({ message: '网络异常,更新健康记录失败' });
    }
  }

  private handleCancel(): void {
    this.navPathStack.pop();
  }

  // ==================== UI 构建 ====================
  @Builder
  private buildHeader() {
    Row() {
      Column() {
        Text(this.getRecordTypeIcon(this.selectedRecordType))
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .borderRadius(24)
      .backgroundColor(this.getRecordTypeBgColor(this.selectedRecordType))
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(this.params.mode === 'create' ? '新增' + this.getRecordTypeLabel(this.selectedRecordType) : '编辑' + this.getRecordTypeLabel(this.selectedRecordType))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1e293b')

        if (this.params.elderName) {
          Text('为 ' + this.params.elderName + ' 记录')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ top: 4 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  private buildTypeSelector() {
    if (this.params.mode === 'create') {
      Column() {
        Text('选择档案类型')
          .fontSize(13)
          .fontColor('#64748b')
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 12 })
          .alignSelf(ItemAlign.Start)

        Row({ space: 8 }) {
          this.TypeButton('MEDICAL_HISTORY', '🏥', '病史')
          this.TypeButton('CHECK_REPORT', '🔬', '检查')
          this.TypeButton('MEDICATION', '💊', '用药')
          this.TypeButton('ALLERGY', '⚠️', '过敏')
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })
      .backgroundColor(Color.White)
    }
  }

  @Builder
  private TypeButton(type: HealthRecordType, icon: string, label: string) {
    Column() {
      Text(icon)
        .fontSize(24)
        .margin({ bottom: 6 })
      Text(label)
        .fontSize(12)
        .fontColor(this.selectedRecordType === type ? this.getRecordTypeColor(type) : '#64748b')
        .fontWeight(this.selectedRecordType === type ? FontWeight.Medium : FontWeight.Regular)
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor(this.selectedRecordType === type ? this.getRecordTypeBgColor(type) : '#f8fafc')
    .borderRadius(12)
    .border({
      width: 2,
      color: this.selectedRecordType === type ? this.getRecordTypeColor(type) : '#e2e8f0'
    })
    .onClick(() => {
      this.selectedRecordType = type;
    })
  }

  build() {
    NavDestination() {
      Column() {
        // 页面头部
        this.buildHeader()

        // 类型选择器 (仅创建模式)
        this.buildTypeSelector()

        Divider()
          .strokeWidth(1)
          .color('#e2e8f0')

        // 表单内容
        Scroll() {
          HealthRecordForm({
            elderName: this.params.elderName,
            recordType: this.selectedRecordType,
            mode: this.params.mode,
            initialTitle: this.params.editRecord?.record_title || '',
            initialDate: this.params.editRecord?.record_date || '',
            initialContent: this.params.editRecord?.content_structured || null,
            onSubmit: (payload) => {
              this.handleSubmit(payload);
            },
            onCancel: () => {
              this.handleCancel();
            },
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f8fafc')
    }
    .title(this.params.mode === 'create' ? '添加健康档案' : '编辑健康档案')
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack;
      this.params = ctx.pathInfo.param as AddHealthRecordParams;
      // 初始化选中的类型
      this.selectedRecordType = this.params.recordType || 'MEDICAL_HISTORY';
    })
    .width('100%')
    .height('100%')
  }
}
