import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';

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
  // 全屏创建咨询状态
  @State showCreatePage: boolean = false;
  @State createStep: number = 1; // 1=选择医护, 2=填写表单
  @State staffList: MedicalStaffInfo[] = [];
  @State isLoadingStaff: boolean = false;
  @State selectedStaff: MedicalStaffInfo | null = null;
  @State searchKeyword: string = '';
  @State searchPhone: string = '';
  @State questionTitle: string = '';
  @State questionContent: string = '';
  @State isSubmitting: boolean = false;

  private tabs: string[] = ['全部', '待处理', '处理中', '已完成'];

  aboutToAppear(): void {
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

  private async loadMedicalStaff(): Promise<void> {
    this.isLoadingStaff = true;
    try {
      const params: SearchStaffParams = { page: 1, pageSize: 50 };
      if (this.searchKeyword.trim()) params.goodAtTags = this.searchKeyword.trim();
      if (this.searchPhone.trim()) params.phone = this.searchPhone.trim();

      const response = await httpRequest<ApiResponse<MedicalStaffListData>, SearchStaffParams>({
        url: '/api/v1/users/online-medical-staff',
        method: RequestEnum.GET,
        params: params
      });

      if (response.code === 200 && response.data) {
        const data = response.data as Object;
        if (Array.isArray((data as MedicalStaffListData).items)) {
          this.staffList = (data as MedicalStaffListData).items;
        } else if (Array.isArray((data as Record<string, MedicalStaffInfo[]>)['records'])) {
          this.staffList = (data as Record<string, MedicalStaffInfo[]>)['records'];
        }
      }
    } catch (error) {
      console.error('获取医护人员列表失败:', error);
    } finally {
      this.isLoadingStaff = false;
    }
  }

  private async submitQuestion(): Promise<void> {
    if (!this.selectedStaff) {
      promptAction.showToast({ message: '请选择咨询对象' });
      return;
    }
    if (!this.questionTitle.trim()) {
      promptAction.showToast({ message: '请输入标题' });
      return;
    }
    if (!this.questionContent.trim()) {
      promptAction.showToast({ message: '请输入内容' });
      return;
    }

    this.isSubmitting = true;
    try {
      const data: CreateQuestionRequest = {
        title: this.questionTitle.trim(),
        description: this.questionContent.trim(),
        creator_type: 'FAMILY',
        target_staff_id: this.selectedStaff.user_id,
        priority: 'NORMAL'
      };

      const response = await httpRequest<ApiResponse<ConsultationQuestion>, CreateQuestionRequest>({
        url: '/api/v1/consultation/questions',
        method: RequestEnum.POST,
        params: data
      });

      if (response.code === 200 || response.code === 201) {
        promptAction.showToast({ message: '咨询已提交' });
        this.closeCreatePage();
        this.fetchQuestions();
      } else {
        promptAction.showToast({ message: response.message || '提交失败' });
      }
    } catch (error) {
      console.error('创建咨询失败:', error);
      promptAction.showToast({ message: '提交失败' });
    } finally {
      this.isSubmitting = false;
    }
  }

  private openCreatePage(): void {
    this.showCreatePage = true;
    this.createStep = 1;
    this.staffList = [];
    this.selectedStaff = null;
    this.searchKeyword = '';
    this.searchPhone = '';
    this.questionTitle = '';
    this.questionContent = '';
    this.loadMedicalStaff();
  }

  private closeCreatePage(): void {
    this.showCreatePage = false;
    this.createStep = 1;
  }

  private getRoleTypeText(roleType: string): string {
    switch (roleType) {
      case 'doctor': return '医生';
      case 'nurse': return '护士';
      case 'therapist': return '治疗师';
      default: return '医护';
    }
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

  @Builder
  StaffCard(staff: MedicalStaffInfo) {
    Row() {
      Column() {
        Text(staff.gender === 0 ? '👨‍⚕️' : '👩‍⚕️').fontSize(26)
      }
      .width(50)
      .height(50)
      .borderRadius(25)
      .backgroundColor('#f1f5f9')
      .justifyContent(FlexAlign.Center)

      Column() {
        Row() {
          Text(staff.real_name || staff.username)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1e293b')
          Text(this.getRoleTypeText(staff.role_type))
            .fontSize(10)
            .fontColor('#2563eb')
            .backgroundColor('#eff6ff')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(6)
            .margin({ left: 8 })
        }
        if (staff.job_title) {
          Text(staff.job_title).fontSize(12).fontColor('#64748b').margin({ top: 3 })
        }
        if (staff.good_at_tags) {
          Text('擅长: ' + staff.good_at_tags).fontSize(11).fontColor('#94a3b8').margin({ top: 2 }).maxLines(1)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      Button('选择')
        .type(ButtonType.Capsule)
        .backgroundColor('#2563eb')
        .fontSize(12)
        .height(32)
        .onClick(() => {
          this.selectedStaff = staff;
          this.createStep = 2;
        })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 10 })
  }

  @Builder
  CreatePageContent() {
    Column() {
      // 顶部栏
      Row() {
        Text(this.createStep === 1 ? '✕' : '←')
          .fontSize(20)
          .fontColor('#374151')
          .onClick(() => {
            if (this.createStep === 2) {
              this.createStep = 1;
            } else {
              this.closeCreatePage();
            }
          })

        Text(this.createStep === 1 ? '选择咨询对象' : '填写咨询内容')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1e293b')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('').width(20)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      .border({ width: { bottom: 1 }, color: '#e5e7eb' })

      if (this.createStep === 1) {
        // 搜索栏
        Column() {
          TextInput({ text: this.searchKeyword, placeholder: '搜索擅长领域...' })
            .height(40)
            .fontSize(14)
            .backgroundColor('#f1f5f9')
            .borderRadius(10)
            .onChange((v: string) => { this.searchKeyword = v; })
            .onSubmit(() => { this.loadMedicalStaff(); })

          Row() {
            TextInput({ text: this.searchPhone, placeholder: '手机号搜索...' })
              .height(40)
              .fontSize(14)
              .backgroundColor('#f1f5f9')
              .borderRadius(10)
              .layoutWeight(1)
              .onChange((v: string) => { this.searchPhone = v; })
              .onSubmit(() => { this.loadMedicalStaff(); })

            Button('搜索')
              .type(ButtonType.Capsule)
              .backgroundColor('#2563eb')
              .height(40)
              .width(70)
              .margin({ left: 10 })
              .onClick(() => { this.loadMedicalStaff(); })
          }
          .width('100%')
          .margin({ top: 10 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)

        // 医护列表
        if (this.isLoadingStaff) {
          Column() {
            LoadingProgress().width(36).height(36)
            Text('加载中...').fontSize(13).fontColor('#64748b').margin({ top: 10 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.staffList.length === 0) {
          Column() {
            Text('👨‍⚕️').fontSize(48)
            Text('暂无可用医护人员').fontSize(15).fontColor('#64748b').margin({ top: 12 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column() {
              ForEach(this.staffList, (staff: MedicalStaffInfo) => {
                this.StaffCard(staff)
              }, (staff: MedicalStaffInfo) => staff.id.toString())
            }
            .width('100%')
            .padding(16)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      } else {
        // 填写表单
        Scroll() {
          Column() {
            // 已选医护
            Row() {
              Text(this.selectedStaff?.gender === 0 ? '👨‍⚕️' : '👩‍⚕️').fontSize(22)
              Column() {
                Text('咨询对象').fontSize(11).fontColor('#64748b')
                Text(this.selectedStaff?.real_name || this.selectedStaff?.username || '')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 10 })
              .layoutWeight(1)

              Text('更换').fontSize(13).fontColor('#2563eb').onClick(() => { this.createStep = 1; })
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#f8fafc')
            .borderRadius(10)
            .margin({ bottom: 20 })

            Text('咨询标题').fontSize(14).fontColor('#374151').alignSelf(ItemAlign.Start)
            TextInput({ text: this.questionTitle, placeholder: '简要描述您的问题' })
              .height(46)
              .fontSize(14)
              .backgroundColor('#f8fafc')
              .borderRadius(10)
              .margin({ top: 6, bottom: 18 })
              .onChange((v: string) => { this.questionTitle = v; })

            Text('详细描述').fontSize(14).fontColor('#374151').alignSelf(ItemAlign.Start)
            TextArea({ text: this.questionContent, placeholder: '详细描述您的问题...' })
              .height(140)
              .fontSize(14)
              .backgroundColor('#f8fafc')
              .borderRadius(10)
              .margin({ top: 6, bottom: 24 })
              .onChange((v: string) => { this.questionContent = v; })

            Button(this.isSubmitting ? '提交中...' : '提交咨询')
              .type(ButtonType.Capsule)
              .backgroundColor('#2563eb')
              .width('100%')
              .height(48)
              .enabled(!this.isSubmitting)
              .onClick(() => { this.submitQuestion(); })
          }
          .width('100%')
          .padding(20)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f1f5f9')
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

      // 全屏创建咨询页面
      if (this.showCreatePage) {
        this.CreatePageContent()
      }
    }
    .width('100%')
    .height('100%')
  }
}
