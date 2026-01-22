import { DailyHealthDataView } from '../../../components/DailyHealthDataView';
import { AddHealthDataParams } from './MedicalAddHealthDataPage';

export interface MedicalHealthDataParams {
  elderId: number;
  elderName: string;
}

@Component
export struct MedicalHealthDataPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State elderId: number = 0;
  @State elderName: string = '';

  aboutToAppear(): void {
    const params = this.navPathStack.getParamByName('Medical_HealthDataPage') as Object[];
    if (params && params.length > 0) {
      const data = params[0] as MedicalHealthDataParams;
      this.elderId = data.elderId;
      this.elderName = data.elderName;
    }
  }

  build() {
    NavDestination() {
      Column() {
        if (this.elderId > 0) {
          DailyHealthDataView({
            elderId: this.elderId,
            onAddClick: () => {
              this.navPathStack.pushPath({
                name: 'Medical_AddHealthData',
                param: {
                  elderId: this.elderId,
                  elderName: this.elderName
                } as AddHealthDataParams,
                onPop: () => {
                   // Refresh trick
                   const id = this.elderId;
                   this.elderId = -1;
                   setTimeout(() => {
                     this.elderId = id;
                   }, 10);
                }
              });
            }
          })
        } else {
           Text('参数错误').margin(20)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f8fafc')
    }
    .title(`${this.elderName}的健康数据`)
    .backgroundColor('#f8fafc')
  }
}

@Builder
export function MedicalHealthDataPageBuilder() {
  MedicalHealthDataPage()
}
