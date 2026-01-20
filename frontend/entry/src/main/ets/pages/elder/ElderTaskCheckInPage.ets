import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { BASEURL, RequestEnum } from '../../common/api/httpEnum';
import { picker } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import axios, { AxiosError, AxiosProgressEvent, AxiosResponse, FormData } from '@ohos/axios';
import { fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { preferenceUtils } from '../../common/preferenceUtils';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

export interface CheckInNavParam {
  taskInstanceId: number;
  taskName: string;
}

interface CheckInResponse {
  task_instance_id: number;
  uploaded_images: string[];
}

@Builder
export function ElderTaskCheckInPageBuilder() {
  ElderTaskCheckInPage()
}

@Component
export struct ElderTaskCheckInPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State param: CheckInNavParam | null = null;
  @State remark: string = '';
  @State selectedImages: string[] = [];
  @State isSubmitting: boolean = false;

  aboutToAppear(): void {
    const params = this.navPathStack.getParamByName('Elder_TaskCheckIn') as CheckInNavParam[];
    if (params && params.length > 0) {
      this.param = params[params.length - 1];
    }
  }

  private async selectImages(): Promise<void> {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 9 - this.selectedImages.length;

      const photoViewPicker = new picker.PhotoViewPicker();
      const photoSelectResult = await photoViewPicker.select(photoSelectOptions);

      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        this.selectedImages = this.selectedImages.concat(photoSelectResult.photoUris);
      }

    } catch (error) {
      console.error('选择图片失败:', error);
      promptAction.showToast({ message: '选择图片失败' });
    }
  }

  private removeImage(index: number): void {
    this.selectedImages.splice(index, 1);
  }

  private async submitCheckIn(): Promise<void> {
    if (this.selectedImages.length === 0) {
      promptAction.showToast({ message: '请至少选择一张图片' });
      return;
    }

    if (!this.param) {
      promptAction.showToast({ message: '参数错误' });
      return;
    }

    this.isSubmitting = true;

    let context = this.getUIContext().getHostContext() as common.UIAbilityContext
    let cacheDir = context.cacheDir
    console.log("[check in upload img] " + "cacheDir: " + cacheDir)

    try {
      // 构建 FormData（用于 multi-part form 提交）
      const formData: FormData = new FormData();
      formData.append('task_instance_id', this.param.taskInstanceId.toString());

      if (this.remark) {
        formData.append('remark', this.remark);
      }

      // 添加所有图片
      for (let i = 0; i < this.selectedImages.length; i++) {
        let imageUri = this.selectedImages[i]
        // imageUri = decodeURI(imageUri)
        console.log("[check in upload img] " + "imageUri from picker:" + imageUri)
        try {

          // console.log("[check in upload img] " + "reading photo from media")
          // 使用 fs 模块读取用户选择的图片文件
          // const file = fs.openSync(imageUri, fs.OpenMode.READ_ONLY);
          // const stat = fs.statSync(imageUri);
          // const buffer = new ArrayBuffer(stat.size);
          // fs.readSync(file.fd, buffer);
          // fs.closeSync(file);


          console.log("[check in upload img] " + "copying photo to cache")
          const file = fs.openSync(imageUri, fs.OpenMode.CREATE);
          let cacheImgPath = cacheDir + `/${file.name}`
          console.log("[check in upload img] " + "cache img path: " + cacheImgPath)
          fs.copyFileSync(file.fd, cacheImgPath)

          formData.append('images', `internal://cache/${file.name}`);
        } catch (fileError) {
          console.error(`读取图片 ${i} 失败:`, JSON.stringify(fileError));
          promptAction.showToast({ message: `读取图片 ${i + 1} 失败` });
          this.isSubmitting = false;
          return;
        }
      }

      formData.forEach((value: string, key) => {
        console.log("[check in upload img] " + `key: ${key},value: ${value}`)
      })
      const token = preferenceUtils().get(context, 'token_store', 'token') as string;
      // 发送请求
      const response =
        await axios.post<string, AxiosResponse<string>, FormData>(`${BASEURL.baseUrl}/api/v1/intervention/check-in`,
          formData, {
            headers: {
              'Content-Type': 'multipart/form-data',
              'authorization': `Bearer ${token}`
            },
            context: getContext(this),
            onUploadProgress: (progressEvent: AxiosProgressEvent): void => {
              console.info(progressEvent && progressEvent.loaded && progressEvent.total ?
                Math.ceil(progressEvent.loaded / progressEvent.total * 100) + '%' : '0%');
            },
          }).then((res: AxiosResponse<string>) => {
          console.info("result" + JSON.stringify(res.data));
          promptAction.showToast({ message: '签到成功' });
          // 返回上一页
          this.navPathStack.pop();
        }).catch((err: AxiosError) => {
          console.error("error:" + JSON.stringify(err));
          promptAction.showToast({ message: '签到失败' });
        })
    } catch (error) {
      console.error('签到失败:', JSON.stringify(error));
      promptAction.showToast({ message: '签到失败，请稍后重试' });
    } finally {
      this.isSubmitting = false;
    }
  }

  @Builder
  private ImageGridBuilder() {
    Grid() {
      ForEach(this.selectedImages, (imageUri: string, index: number) => {
        GridItem() {
          Stack({ alignContent: Alignment.TopEnd }) {
            Image(imageUri)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
              .borderRadius(8)

            // 删除按钮
            Button() {
              Text('×')
                .fontSize(20)
                .fontColor(Color.White)
            }
            .width(24)
            .height(24)
            .backgroundColor('#dc2626')
            .borderRadius(12)
            .margin({ top: 4, right: 4 })
            .onClick(() => {
              this.removeImage(index);
            })
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .aspectRatio(1)
      }, (imageUri: string, index: number) => `${imageUri}_${index}`)

      // 添加图片按钮（最多9张）
      if (this.selectedImages.length < 9) {
        GridItem() {
          Column() {
            Text('+')
              .fontSize(32)
              .fontColor('#9ca3af')
            Text('添加图片')
              .fontSize(12)
              .fontColor('#9ca3af')
              .margin({ top: 4 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#f3f4f6')
          .borderRadius(8)
          .border({ width: 1, color: '#e5e7eb', style: BorderStyle.Dashed })
          .onClick(() => {
            this.selectImages();
          })
        }
        .width('100%')
        .aspectRatio(1)
      }
    }
    .columnsTemplate('1fr 1fr 1fr')
    .columnsGap(12)
    .rowsGap(12)
    .width('100%')
  }

  build() {
    NavDestination() {
      Column() {
        if (!this.param) {
          Column() {
            Text('加载中...')
              .fontSize(16)
              .fontColor('#64748b')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column() {
              // 任务信息
              Column() {
                Row() {
                  Text('📝')
                    .fontSize(18)
                  Text('任务信息')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#166534')
                    .margin({ left: 8 })
                }
                .width('100%')
                .margin({ bottom: 12 })

                Text(this.param.taskName)
                  .fontSize(15)
                  .fontColor('#1e293b')
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .margin({ bottom: 16 })

              // 签到图片
              Column() {
                Row() {
                  Text('📷')
                    .fontSize(18)
                  Text('签到图片')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#166534')
                    .margin({ left: 8 })
                  Text('（必填，最多9张）')
                    .fontSize(12)
                    .fontColor('#dc2626')
                    .margin({ left: 4 })
                }
                .width('100%')
                .margin({ bottom: 12 })

                this.ImageGridBuilder()
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .margin({ bottom: 16 })

              // 备注输入
              Column() {
                Row() {
                  Text('💬')
                    .fontSize(18)
                  Text('签到备注')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#166534')
                    .margin({ left: 8 })
                  Text('（可选）')
                    .fontSize(12)
                    .fontColor('#64748b')
                    .margin({ left: 4 })
                }
                .width('100%')
                .margin({ bottom: 12 })

                TextArea({ placeholder: '请输入签到备注，例如：今日已按时服药' })
                  .width('100%')
                  .height(120)
                  .fontSize(14)
                  .backgroundColor('#f8fafc')
                  .borderRadius(8)
                  .onChange((value: string) => {
                    this.remark = value;
                  })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .margin({ bottom: 16 })

              // 提交按钮
              Button(this.isSubmitting ? '提交中...' : '提交签到')
                .width('100%')
                .height(48)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .backgroundColor('#16a34a')
                .borderRadius(12)
                .enabled(!this.isSubmitting && this.selectedImages.length > 0)
                .opacity((!this.isSubmitting && this.selectedImages.length > 0) ? 1 : 0.5)
                .onClick(() => {
                  this.submitCheckIn();
                })
            }
            .padding({
              left: 16,
              right: 16,
              top: 16,
              bottom: 20
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f0fdf4')
    }
    .title('任务签到')
    .backgroundColor('#f0fdf4')
  }
}
