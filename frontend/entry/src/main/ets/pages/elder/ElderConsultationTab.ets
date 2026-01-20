import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

interface ConsultationQuestion {
  id: number;
  title: string;
  content: string;
  priority: string;
  status: string;
  creator_id: number;
  creator_type: string;
  created_at: string;
  updated_at: string;
}

interface PaginationResponse<T> {
  items: T[];
  total: number;
}

interface CreateQuestionRequest {
  title: string;
  content: string;
  priority: string;
}

interface ConsultationParams {
  creator_type: string;
  status?: string;
}

@Component
export struct ElderConsultationTab {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State questions: ConsultationQuestion[] = [];
  @State isLoading: boolean = false;
  @State currentTab: number = 0;
  @State showCreateDialog: boolean = false;
  @State newQuestionTitle: string = '';
  @State newQuestionContent: string = '';

  private tabs: string[] = ['全部', '待处理', '处理中', '已完成'];

  aboutToAppear(): void {
    this.fetchQuestions();
  }

  private async fetchQuestions(): Promise<void> {
    this.isLoading = true;
    try {
      const params: ConsultationParams = {
        creator_type: 'ELDER'
      };

      if (this.currentTab === 1) {
        params.status = 'PENDING';
      } else if (this.currentTab === 2) {
        params.status = 'IN_PROGRESS';
      } else if (this.currentTab === 3) {
        params.status = 'COMPLETED';
      }

      const response = await httpRequest<ApiResponse<PaginationResponse<ConsultationQuestion>>, ConsultationParams>({
        url: '/api/v1/consultation/questions',
        method: RequestEnum.GET,
        params: params
      });

      if (response.code === 200 && response.data) {
        this.questions = response.data.items || [];
      }
    } catch (error) {
      console.error('获取咨询列表失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  private async createQuestion(): Promise<void> {
    if (this.newQuestionTitle.trim() === '' || this.newQuestionContent.trim() === '') {
      promptAction.showToast({ message: '请填写标题和内容' });
      return;
    }

    try {
      const data: CreateQuestionRequest = {
        title: this.newQuestionTitle.trim(),
        content: this.newQuestionContent.trim(),
        priority: 'NORMAL'
      };

      const response = await httpRequest<ApiResponse<ConsultationQuestion>, CreateQuestionRequest>({
        url: '/api/v1/consultation/questions',
        method: RequestEnum.POST,
        params: data
      });

      if (response.code === 200 || response.code === 201) {
        promptAction.showToast({ message: '咨询已提交' });
        this.showCreateDialog = false;
        this.newQuestionTitle = '';
        this.newQuestionContent = '';
        this.fetchQuestions();
      } else {
        promptAction.showToast({ message: response.message || '提交失败' });
      }
    } catch (error) {
      console.error('创建咨询失败:', error);
      promptAction.showToast({ message: '提交失败，请重试' });
    }
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'PENDING':
        return '待处理';
      case 'IN_PROGRESS':
        return '处理中';
      case 'RESOLVED':
        return '已完成';
      case 'CLOSED':
        return '已关闭';
      default:
        return status;
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'PENDING':
        return '#f59e0b';
      case 'IN_PROGRESS':
        return '#16a34a';
      case 'RESOLVED':
        return '#2563eb';
      case 'CLOSED':
        return '#9ca3af';
      default:
        return '#64748b';
    }
  }

  private formatDate(dateStr: string): string {
    const d = new Date(dateStr);
    return (d.getMonth() + 1) + '月' + d.getDate() + '日';
  }

  private openChat(question: ConsultationQuestion): void {
    this.navPathStack.pushPath({
      name: 'Elder_ConsultationChat',
      param: question as Object
    });
  }

  @Builder
  private QuestionItem(item: ConsultationQuestion) {
    Column() {
      Row() {
        Column() {
          Text(item.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1e293b')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(item.content)
            .fontSize(13)
            .fontColor('#64748b')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 6 })

          Row() {
            Text(this.getStatusText(item.status))
              .fontSize(11)
              .fontColor(this.getStatusColor(item.status))
              .backgroundColor(this.getStatusColor(item.status) + '20')
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(10)

            Text(this.formatDate(item.created_at))
              .fontSize(11)
              .fontColor('#9ca3af')
              .margin({ left: 10 })
          }
          .margin({ top: 10 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text('→')
          .fontSize(20)
          .fontColor('#cbd5e1')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(14)
      .shadow({ radius: 4, color: '#0f172a0a', offsetY: 1 })
    }
    .margin({ bottom: 10 })
    .onClick(() => {
      this.openChat(item);
    })
  }

  build() {
    Stack() {
      Column() {
        // 页面标题
        Row() {
          Column() {
            Text('咨询服务')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#166534')
            Text('有问题随时向医护咨询')
              .fontSize(13)
              .fontColor('#64748b')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('+ 新咨询')
            .type(ButtonType.Capsule)
            .backgroundColor('#16a34a')
            .fontSize(13)
            .height(36)
            .onClick(() => {
              this.showCreateDialog = true;
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 12 })

        // Tab切换
        Row() {
          ForEach(this.tabs, (item: string, index: number) => {
            Text(item)
              .fontSize(14)
              .fontColor(this.currentTab === index ? '#ffffff' : '#64748b')
              .backgroundColor(this.currentTab === index ? '#166534' : '#f1f5f9')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .borderRadius(18)
              .margin({ right: 8 })
              .onClick(() => {
                this.currentTab = index;
                this.fetchQuestions();
              })
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })

        // 咨询列表
        if (this.isLoading) {
          Column() {
            LoadingProgress().width(36).height(36)
            Text('加载中...').fontSize(13).fontColor('#64748b').margin({ top: 10 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.questions.length === 0) {
          Column() {
            Text('💬')
              .fontSize(48)
            Text('暂无咨询记录')
              .fontSize(15)
              .fontColor('#64748b')
              .margin({ top: 16 })
            Text('有问题就点击右上角发起咨询')
              .fontSize(13)
              .fontColor('#9ca3af')
              .margin({ top: 8 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.questions, (item: ConsultationQuestion) => {
              ListItem() {
                this.QuestionItem(item)
              }
            }, (item: ConsultationQuestion) => item.id.toString())
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16, top: 8 })
        }
      }
      .width('100%')
      .height('100%')

      // 新建咨询弹窗
      if (this.showCreateDialog) {
        Column() {
          Column() {
            Text('新建咨询')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#166534')
              .margin({ bottom: 16 })

            Text('问题标题')
              .fontSize(13)
              .fontColor('#64748b')
              .alignSelf(ItemAlign.Start)
            TextInput({ text: this.newQuestionTitle, placeholder: '简述您的问题' })
              .height(44)
              .fontSize(14)
              .backgroundColor('#f0fdf4')
              .borderRadius(10)
              .margin({ top: 6, bottom: 14 })
              .onChange((value: string) => {
                this.newQuestionTitle = value;
              })

            Text('详细描述')
              .fontSize(13)
              .fontColor('#64748b')
              .alignSelf(ItemAlign.Start)
            TextArea({ text: this.newQuestionContent, placeholder: '请详细描述您的问题或疑惑...' })
              .height(120)
              .fontSize(14)
              .backgroundColor('#f0fdf4')
              .borderRadius(10)
              .margin({ top: 6, bottom: 20 })
              .onChange((value: string) => {
                this.newQuestionContent = value;
              })

            Row() {
              Button('取消')
                .type(ButtonType.Capsule)
                .backgroundColor('#f1f5f9')
                .fontColor('#64748b')
                .layoutWeight(1)
                .height(44)
                .margin({ right: 10 })
                .onClick(() => {
                  this.showCreateDialog = false;
                })

              Button('提交')
                .type(ButtonType.Capsule)
                .backgroundColor('#16a34a')
                .layoutWeight(1)
                .height(44)
                .onClick(() => {
                  this.createQuestion();
                })
            }
            .width('100%')
          }
          .width('90%')
          .padding(24)
          .backgroundColor(Color.White)
          .borderRadius(20)
          .shadow({ radius: 20, color: '#0002' })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000066')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showCreateDialog = false;
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
