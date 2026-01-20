import { HealthRecordForm } from './HealthRecordForm';
import { HealthRecordType, HealthRecordFormSubmitPayload } from '../../models/HealthRecordModels';

@CustomDialog
export struct HealthRecordDialog {
  controller?: CustomDialogController
  @Prop elderName: string = ''
  @Prop recordType: HealthRecordType = 'MEDICAL_HISTORY'
  @Prop mode: 'create' | 'edit' = 'create'
  @Prop initialTitle: string = ''
  @Prop initialDate: string = ''
  @Prop initialContent: Record<string, Object> | null = null
  onSubmit: (payload: HealthRecordFormSubmitPayload) => void = () => {}
  onCancel: () => void = () => {}

  private getRecordTypeLabel(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '病史记录'
      case 'CHECK_REPORT': return '检查报告'
      case 'MEDICATION': return '用药记录'
      case 'ALLERGY': return '过敏记录'
    }
  }

  private getRecordTypeIcon(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '🏥'
      case 'CHECK_REPORT': return '🔬'
      case 'MEDICATION': return '💊'
      case 'ALLERGY': return '⚠️'
    }
  }

  private getRecordTypeColor(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '#1d4ed8'
      case 'CHECK_REPORT': return '#15803d'
      case 'MEDICATION': return '#b91c1c'
      case 'ALLERGY': return '#c2410c'
    }
  }

  private getRecordTypeBgColor(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '#eff6ff'
      case 'CHECK_REPORT': return '#f0fdf4'
      case 'MEDICATION': return '#fef2f2'
      case 'ALLERGY': return '#fff7ed'
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Column() {
          Text(this.getRecordTypeIcon(this.recordType))
            .fontSize(24)
        }
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor(this.getRecordTypeBgColor(this.recordType))
        .justifyContent(FlexAlign.Center)

        Column() {
          Text(this.mode === 'create' ? '新增' + this.getRecordTypeLabel(this.recordType) : '编辑' + this.getRecordTypeLabel(this.recordType))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e293b')

          if (this.elderName) {
            Text('为 ' + this.elderName + ' 记录')
              .fontSize(13)
              .fontColor('#64748b')
              .margin({ top: 4 })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 14 })

        // Close button
        Column() {
          Text('✕')
            .fontSize(18)
            .fontColor('#9ca3af')
        }
        .width(36)
        .height(36)
        .borderRadius(18)
        .backgroundColor('#f1f5f9')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.onCancel()
          if (this.controller) {
            this.controller.close()
          }
        })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // Divider
      Divider()
        .strokeWidth(1)
        .color('#e2e8f0')
        .margin({ bottom: 16 })

      // Form content
      Scroll() {
        HealthRecordForm({
          elderName: this.elderName,
          recordType: this.recordType,
          mode: this.mode,
          initialTitle: this.initialTitle,
          initialDate: this.initialDate,
          initialContent: this.initialContent,
          onSubmit: (payload) => {
            this.onSubmit(payload)
            if (this.controller) {
              this.controller.close()
            }
          },
          onCancel: () => {
            this.onCancel()
            if (this.controller) {
              this.controller.close()
            }
          }
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('80%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(20)
  }
}
