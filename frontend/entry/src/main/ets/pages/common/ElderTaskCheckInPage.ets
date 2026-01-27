import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { BASEURL, RequestEnum } from '../../common/api/httpEnum';
import { picker } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import axios, { AxiosError, AxiosProgressEvent, AxiosResponse, FormData } from '@ohos/axios';
import { fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { preferenceUtils } from '../../common/preferenceUtils';
import dayjs from 'dayjs';

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

export interface TaskInstanceDetail {
  id: number;
  item_id: number;
  schedule_id?: number | null;
  task_date: string;
  task_time?: string | null;
  status: 'PENDING' | 'COMPLETED' | 'SKIPPED' | 'MISSED';
  complete_time?: string | null;
  remark?: string | null;
  proof_image_url?: string | null;
  created_at: string;
  updated_at: string;
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
  @State isLoading: boolean = true;
  @State taskDetail: TaskInstanceDetail | null = null;

  async aboutToAppear(): Promise<void> {
    const params = this.navPathStack.getParamByName('Elder_TaskCheckIn') as CheckInNavParam[];
    if (params && params.length > 0) {
      this.param = params[params.length - 1];
      await this.fetchTaskDetail();
    }
  }

  private async fetchTaskDetail(): Promise<void> {
    if (!this.param) return;
    
    this.isLoading = true;
    try {
      const params: Record<string, Object> = {};
      const response = await httpRequest<ApiResponse<TaskInstanceDetail>, Record<string, Object>>({
        url: `/api/v1/intervention/tasks/${this.param.taskInstanceId}`,
        method: RequestEnum.GET,
        params: params
      });
      
      if (response.code === 200 && response.data) {
        this.taskDetail = response.data;
        
        // If already completed, parse the images
        if (this.taskDetail.status === 'COMPLETED' && this.taskDetail.proof_image_url) {
          try {
            const images = JSON.parse(this.taskDetail.proof_image_url) as string[];
            this.selectedImages = images.map((img: string) => `${BASEURL.baseUrl}${img}`);
          } catch (e) {
            console.error('Failed to parse proof images:', e);
          }
        }
      }
    } catch (error) {
      console.error('获取任务详情失败:', error);
      promptAction.showToast({ message: '获取任务状态失败' });
    } finally {
      this.isLoading = false;
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
    if (this.taskDetail?.status === 'COMPLETED') return;
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
        try {
          const file = fs.openSync(imageUri, fs.OpenMode.CREATE);
          let cacheImgPath = cacheDir + `/${file.name}`
          fs.copyFileSync(file.fd, cacheImgPath)

          formData.append('images', `internal://cache/${file.name}`);
        } catch (fileError) {
          console.error(`读取图片 ${i} 失败:`, JSON.stringify(fileError));
          promptAction.showToast({ message: `读取图片 ${i + 1} 失败` });
          this.isSubmitting = false;
          return;
        }
      }

      const token = preferenceUtils().get(context, 'token_store', 'token') as string;
      // 发送请求
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

            if (!this.taskDetail || this.taskDetail.status !== 'COMPLETED') {
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
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .aspectRatio(1)
      }, (imageUri: string, index: number) => `${imageUri}_${index}`)

      if ((!this.taskDetail || this.taskDetail.status !== 'COMPLETED') && this.selectedImages.length < 9) {
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

  @Builder
  private CheckInFormView() {
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

          Text(this.param?.taskName)
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
      .constraintSize({
        minHeight:'100%'
      })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  private CompletedDetailView() {
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
            
            Text('（已完成）')
              .fontSize(14)
              .fontColor('#16a34a')
              .margin({ left: 4 })
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .margin({ bottom: 12 })

          Text(this.param?.taskName)
            .fontSize(15)
            .fontColor('#1e293b')
            .width('100%')
            
          if (this.taskDetail?.complete_time) {
            Row() {
              Text('完成时间：')
                .fontSize(14)
                .fontColor('#64748b')
              Text(dayjs(this.taskDetail.complete_time).format("YYYY-MM-DD，hh时mm分"))
                .fontSize(14)
                .fontColor('#1e293b')
            }
            .margin({ top: 8 })
            .width('100%')
          }
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
          }
          .width('100%')
          .margin({ bottom: 12 })

          if (this.selectedImages.length === 0) {
             Text('无图片')
              .fontSize(14)
              .fontColor('#94a3b8')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding(20)
          } else {
            this.ImageGridBuilder()
          }
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
          }
          .width('100%')
          .margin({ bottom: 12 })

          Text(this.taskDetail?.remark || '无备注')
            .fontSize(14)
            .fontColor(this.taskDetail?.remark ? '#1e293b' : '#94a3b8')
            .width('100%')
            .padding(8)
            .backgroundColor('#f8fafc')
            .borderRadius(8)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ bottom: 16 })
      }
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 20
      })
      .constraintSize({
        minHeight:'100%'
      })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  build() {
    NavDestination() {
      Column() {
        if (!this.param || this.isLoading) {
          Column() {
            LoadingProgress()
              .color('#16a34a')
              .width(50)
              .height(50)
            Text(this.isLoading ? '加载中...' : '参数加载中...')
              .fontSize(16)
              .fontColor('#64748b')
              .margin({ top: 12 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.taskDetail?.status === 'COMPLETED') {
          this.CompletedDetailView()
        } else {
          this.CheckInFormView()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f0fdf4')
    }
    .title(this.taskDetail?.status === 'COMPLETED' ? '任务详情' : '任务签到')
    .backgroundColor('#f0fdf4')
  }
}
