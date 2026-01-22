import { promptAction } from '@kit.ArkUI';
import { DailyHealthDataView } from '../../components/DailyHealthDataView';
import { AddHealthDataParams } from './ElderAddHealthDataPage';

interface UserResponse {
  id: number;
  username: string;
  role: string;
  elder_info?: ElderResponse;
}

interface ElderResponse {
  id: number;
  name: string;
}

@Component
export struct ElderHealthTab {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State elderId: number = -1;
  @State elderName: string = '';
  @State refreshTrigger: number = 0;

  aboutToAppear(): void {
    this.loadData();
  }

  private loadData(): void {
    // Get current user from AppStorage
    const currentUser = AppStorage.get<UserResponse>('currentUser');
    if (currentUser) {
       this.elderId = currentUser.id;
       if (currentUser.elder_info) {
         this.elderName = currentUser.elder_info.name;
       } else {
         this.elderName = currentUser.username;
       }
    }
  }

  private onAddClick() {
    const params: AddHealthDataParams = {
      elderId: this.elderId,
      elderName: this.elderName
    };
    
    this.navPathStack.pushPathByName('Elder_AddHealthData', params, (popInfo) => {
      // Check if we need to refresh (result is true)
      if (popInfo.result === true) {
        this.refreshTrigger++;
      }
    });
  }

  build() {
    Column() {
      // 页面标题
      Row() {
        Column() {
          Text('健康数据')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#166534')
          Text('记录您的日常健康指标')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()

      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })

      // Content
      Column() {
        if (this.elderId > 0) {
          DailyHealthDataView({
            elderId: this.elderId,
            refreshTrigger: this.refreshTrigger,
            onAddClick: () => {
              this.onAddClick();
            }
          })
        } else {
           // Fallback loading or empty state if elderId is not yet ready
           Column() {
             LoadingProgress().width(32).height(32)
           }
           .width('100%')
           .height(200)
           .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#f8fafc') 
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
  }
}
