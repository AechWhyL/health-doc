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

  build() {
    Column() {
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
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('90%')
  }
}
