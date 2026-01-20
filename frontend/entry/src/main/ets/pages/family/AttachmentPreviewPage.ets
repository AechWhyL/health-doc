import { webview } from '@kit.ArkWeb';

export interface AttachmentPreviewParams {
  url: string;
  name?: string;
}

@Component
export struct AttachmentPreviewPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State url: string = '';
  @State name: string = '附件预览';
  @State isLoading: boolean = true;
  @State loadProgress: number = 0;
  private controller: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    const params = this.navPathStack.getParamByName('Family_AttachmentPreview') as Object[];
    if (params && params.length > 0) {
      const data = params[0] as AttachmentPreviewParams;
      this.url = data.url;
      if (data.name) {
        this.name = data.name;
      }
    }
  }

  build() {
    NavDestination() {
      Stack() {
        if (this.url) {
          Web({ src: this.url, controller: this.controller })
            .width('100%')
            .height('100%')
            .onProgressChange((event) => {
              if (event) {
                this.loadProgress = event.newProgress;
                if (event.newProgress >= 100) {
                  this.isLoading = false;
                }
              }
            })
            .onPageEnd(() => {
              this.isLoading = false;
            })
            .onErrorReceive((event) => {
              console.error('WebView error:', event?.error);
              this.isLoading = false;
            })
        } else {
          Column() {
            Text('📄')
              .fontSize(48)
            Text('无效的附件链接')
              .fontSize(16)
              .fontColor('#64748b')
              .margin({ top: 16 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }

        // 加载进度条
        if (this.isLoading && this.url) {
          Column() {
            Progress({ value: this.loadProgress, total: 100, type: ProgressType.Linear })
              .width('100%')
              .height(3)
              .color('#2563eb')
              .backgroundColor('#e2e8f0')
          }
          .width('100%')
          .position({ x: 0, y: 0 })
        }
      }
      .width('100%')
      .height('100%')
    }
    .title(this.name)
    .backgroundColor('#ffffff')
  }
}

@Builder
export function AttachmentPreviewPageBuilder() {
  AttachmentPreviewPage()
}
