import router from '@ohos.router';
import { ConsultationService } from '../../../common/api/ConsultationService';
import { ConsultationQuestion } from '../../../models/ConsultationModels';

@Component
export struct ConsultationList {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State currentTab: number = 0;
  @State questions: ConsultationQuestion[] = [];
  @State isLoading: boolean = false;

  private tabs: string[] = ['全部', '待处理', '处理中', '已完成'];



  aboutToAppear() {
    this.fetchQuestions();
  }

  async fetchQuestions() {
    this.isLoading = true;
    try {
      let status: string | undefined = undefined;
      if (this.currentTab === 1) status = 'PENDING';
      else if (this.currentTab === 2) status = 'IN_PROGRESS';
      else if (this.currentTab === 3) status = 'COMPLETED';

      const params: Record<string, Object> = {};
      if (status) {
        params['status'] = status;
      }

      const response = await ConsultationService.getQuestionList(params);
      if (response.code === 200) {
        this.questions = response.data.items;
      }
    } catch (error) {
      console.error('Failed to fetch questions:', error);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Column() {
          Text('咨询列表')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          Text('待处理与进行中的咨询')
            .fontSize(12)
            .fontColor('#6B7280')
            .margin({ top: 4 })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      // Tabs
      Row() {
        ForEach(this.tabs, (item: string, index: number) => {
          Text(item)
            .fontSize(14)
            .fontColor(this.currentTab === index ? '#F9FAFB' : '#4B5563')
            .backgroundColor(this.currentTab === index ? '#111827' : '#F3F4F6')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
            .margin({ right: 8 })
            .onClick(() => {
              this.currentTab = index;
              this.fetchQuestions();
            })
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })
      .backgroundColor(Color.White)

      // List
      if (this.isLoading) {
        LoadingProgress().width(32).height(32).margin({ top: 20 })
      } else {
        List() {
          ForEach(this.questions, (item: ConsultationQuestion) => {
            ListItem() {
              this.QuestionItem(item)
            }
          }, (item: ConsultationQuestion) => item.id.toString())
        }
        .width('100%')
        .height(300)
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')
  }

  @Builder
  QuestionItem(item: ConsultationQuestion) {
    Column() {
      Row() {
        Column() {
          Text(`CQ${item.id.toString().padStart(6, '0')} · ${item.title}`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Row() {
            Text(this.getStatusText(item.status))
              .fontSize(12)
              .fontColor('#6B7280')
            Text(' · ')
              .fontSize(12)
              .fontColor('#6B7280')
            Text(item.priority === 'URGENT' ? '紧急' : '普通')
              .fontSize(12)
              .fontColor(item.priority === 'URGENT' ? '#DC2626' : '#6B7280')
            Text(' · ')
              .fontSize(12)
              .fontColor('#6B7280')
            Text(item.creator_type === 'ELDER' ? '来自老人' : '来自家属')
              .fontSize(12)
              .fontColor('#6B7280')
          }
          .margin({ top: 4 })
        }
        .layoutWeight(1)

        // Action Tag
        if (item.status === 'PENDING') {
          Text('去回复')
            .fontSize(12)
            .fontColor('#B91C1C')
            .backgroundColor('#FEE2E2')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12)
        } else if (item.status === 'IN_PROGRESS') {
           Text('继续跟进')
            .fontSize(12)
            .fontColor('#16A34A')
            .backgroundColor('#DCFCE7')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12)
        }
      }
      .width('100%')
      .padding(12)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .shadow({ radius: 4, color: '#0F172A14', offsetY: 2 })
    }
    .padding({ bottom: 10 })
    .onClick(() => {
      console.log("to chat")
      this.navPathStack.pushPath({
        name: 'Medical_ConsultationTab_ChatPage',
        param: item as Object
      });
    })
  }

  getStatusText(status: string): string {
    switch (status) {
      case 'PENDING': return '待处理';
      case 'IN_PROGRESS': return '处理中';
      case 'RESOLVED': return '已完成';
      case 'CLOSED': return '已关闭';
      default: return status;
    }
  }
}
