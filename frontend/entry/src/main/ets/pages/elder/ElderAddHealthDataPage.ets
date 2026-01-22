import { AddHealthDataForm } from '../../components/AddHealthDataForm';

export interface AddHealthDataParams {
  elderId: number;
  elderName: string;
}

@Component
export struct ElderAddHealthDataPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State elderId: number = 0;
  @State elderName: string = '';

  aboutToAppear(): void {
    const params = this.navPathStack.getParamByName('Elder_AddHealthData') as Object[];
    if (params && params.length > 0) {
      const data = params[0] as AddHealthDataParams;
      this.elderId = data.elderId;
      this.elderName = data.elderName;
    }
  }

  build() {
    NavDestination() {
      AddHealthDataForm({
        elderId: this.elderId,
        elderName: this.elderName,
        onSuccess: () => {
          this.navPathStack.pop(true); // Return true to signal refresh
        },
        onCancel: () => {
          this.navPathStack.pop();
        }
      })
    }
    .title('添加健康数据')
    .backgroundColor('#ffffff')
    .hideTitleBar(true)
  }
}

@Builder
export function ElderAddHealthDataPageBuilder() {
  ElderAddHealthDataPage()
}
