import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';
import { CreateConsultationPageParams } from '../common/CreateConsultation';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

interface PaginationResponse<T> {
  items: T[];
  total: number;
}

interface ConsultationQuestion {
  id: number;
  title: string;
  description: string;
  status: string;
  priority: string;
  created_at: string;
}

interface CreateQuestionRequest {
  title: string;
  description: string;
  creator_type: string;
  creator_id?: number;
  target_staff_id: number;
  priority: string;
}

interface ConsultationParams {
  page?: number;
  pageSize?: number;
  status?: string;
}

interface MedicalStaffInfo {
  id: number;
  user_id: number;
  gender: number;
  role_type: string;
  job_title: string | null;
  good_at_tags: string | null;
  real_name: string | null;
  username: string;
  phone: string | null;
}

interface MedicalStaffListData {
  items: MedicalStaffInfo[];
  total: number;
}

interface SearchStaffParams {
  page: number;
  pageSize: number;
  goodAtTags?: string;
  phone?: string;
}

@Component
export struct FamilyConsultationTab {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State questions: ConsultationQuestion[] = [];
  @State isLoading: boolean = false;
  @State currentTab: number = 0;

  private tabs: string[] = ['全部', '待处理', '处理中', '已完成'];

  aboutToAppear(): void {
    this.fetchQuestions();
  }

  onPageShow(): void {
    this.fetchQuestions();
  }

  private async fetchQuestions(): Promise<void> {
    this.isLoading = true;
    try {
      const params: ConsultationParams = { page: 1, pageSize: 50 };
      if (this.currentTab === 1) params.status = 'PENDING';
      else if (this.currentTab === 2) params.status = 'IN_PROGRESS';
      else if (this.currentTab === 3) params.status = 'COMPLETED';

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

  private openCreatePage(): void {
    const pageParam:CreateConsultationPageParams = { creatorType: 'FAMILY' }
    this.navPathStack.pushPath({ name: 'Family_CreateConsultation', param: pageParam });
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'PENDING': return '待处理';
      case 'IN_PROGRESS': return '处理中';
      case 'COMPLETED': return '已完成';
      default: return status;
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'PENDING': return '#f59e0b';
      case 'IN_PROGRESS': return '#3b82f6';
      case 'COMPLETED': return '#10b981';
      default: return '#6b7280';
    }
  }

  @Builder
  QuestionItem(item: ConsultationQuestion) {
    Row() {
      Column() {
        Row() {
          Text(item.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1e293b')
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.getStatusText(item.status))
            .fontSize(11)
            .fontColor(this.getStatusColor(item.status))
            .backgroundColor(this.getStatusColor(item.status) + '1a')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(10)
        }
        .width('100%')

        Text(item.description || '无描述')
          .fontSize(13)
          .fontColor('#64748b')
          .margin({ top: 6 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.created_at?.substring(0, 10) || '')
          .fontSize(11)
          .fontColor('#9ca3af')
          .margin({ top: 6 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 10 })
    .onClick(() => {
      this.navPathStack.pushPath({ name: 'Family_ConsultationChat', param: item });
    })
  }

  build() {
    Stack() {
      // 主内容
      Column() {
        // 标题栏
        Row() {
          Column() {
            Text('咨询服务').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#1e293b')
            Text('向医护人员咨询健康问题').fontSize(13).fontColor('#64748b').margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('+ 新建咨询')
            .type(ButtonType.Capsule)
            .backgroundColor('#2563eb')
            .fontSize(13)
            .height(36)
            .onClick(() => { this.openCreatePage(); })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 12 })

        // Tab
        Row() {
          ForEach(this.tabs, (item: string, index: number) => {
            Text(item)
              .fontSize(14)
              .fontColor(this.currentTab === index ? '#ffffff' : '#64748b')
              .backgroundColor(this.currentTab === index ? '#1e293b' : '#f1f5f9')
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

        // 列表
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
            Text('💬').fontSize(48)
            Text('暂无咨询记录').fontSize(15).fontColor('#64748b').margin({ top: 16 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.questions, (item: ConsultationQuestion) => {
              ListItem() { this.QuestionItem(item) }
            }, (item: ConsultationQuestion) => item.id.toString())
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16, top: 8 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f8fafc')
    }
    .width('100%')
    .height('100%')
  }
}
