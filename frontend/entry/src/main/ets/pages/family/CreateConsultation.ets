import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
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

interface SearchParams {
  page: number;
  pageSize: number;
  goodAtTags?: string;
  phone?: string;
}

interface CreateQuestionRequest {
  title: string;
  description: string;
  creator_type: string;
  creator_id: number;
  target_staff_id: number;
  priority: string;
}

interface ConsultationQuestion {
  id: number;
  title: string;
}

@Component
export struct CreateConsultation {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State staffList: MedicalStaffInfo[] = [];
  @State isLoading: boolean = true;
  @State selectedStaff: MedicalStaffInfo | null = null;
  @State searchKeyword: string = '';
  @State searchPhone: string = '';
  @State questionTitle: string = '';
  @State questionContent: string = '';
  @State isSubmitting: boolean = false;
  @State showForm: boolean = false;

  aboutToAppear(): void {
    this.loadMedicalStaff();
  }

  private async loadMedicalStaff(): Promise<void> {
    this.isLoading = true;
    try {
      const params: SearchParams = { page: 1, pageSize: 50 };
      if (this.searchKeyword.trim()) {
        params.goodAtTags = this.searchKeyword.trim();
      }
      if (this.searchPhone.trim()) {
        params.phone = this.searchPhone.trim();
      }

      const response = await httpRequest<ApiResponse<MedicalStaffListData>, SearchParams>({
        url: '/api/v1/users/online-medical-staff',
        method: RequestEnum.GET,
        params: params
      });

      console.info('医护人员API响应:', JSON.stringify(response));

      if (response.code === 200 && response.data) {
        // 兼容两种可能的数据结构
        const data = response.data as Object;
        if (Array.isArray((data as MedicalStaffListData).items)) {
          this.staffList = (data as MedicalStaffListData).items;
        } else if (Array.isArray((data as Record<string, MedicalStaffInfo[]>)['records'])) {
          this.staffList = (data as Record<string, MedicalStaffInfo[]>)['records'];
        } else {
          this.staffList = [];
        }
      }
    } catch (error) {
      console.error('获取医护人员列表失败:', error);
      promptAction.showToast({ message: '加载失败，请重试' });
    } finally {
      this.isLoading = false;
    }
  }

  private selectStaff(staff: MedicalStaffInfo): void {
    this.selectedStaff = staff;
    this.showForm = true;
  }

  private async submitQuestion(): Promise<void> {
    if (!this.selectedStaff) {
      promptAction.showToast({ message: '请选择咨询对象' });
      return;
    }
    if (this.questionTitle.trim() === '') {
      promptAction.showToast({ message: '请输入咨询标题' });
      return;
    }
    if (this.questionContent.trim() === '') {
      promptAction.showToast({ message: '请输入咨询内容' });
      return;
    }

    this.isSubmitting = true;
    try {
      const data: CreateQuestionRequest = {
        title: this.questionTitle.trim(),
        description: this.questionContent.trim(),
        creator_type: 'FAMILY',
        creator_id: 0,
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
        this.navPathStack.pop();
      } else {
        promptAction.showToast({ message: response.message || '提交失败' });
      }
    } catch (error) {
      console.error('创建咨询失败:', error);
      promptAction.showToast({ message: '提交失败，请重试' });
    } finally {
      this.isSubmitting = false;
    }
  }

  private getRoleTypeText(roleType: string): string {
    switch (roleType) {
      case 'doctor': return '医生';
      case 'nurse': return '护士';
      case 'therapist': return '治疗师';
      default: return '医护人员';
    }
  }

  @Builder
  private SearchBar() {
    Column() {
      Row() {
        TextInput({ text: this.searchKeyword, placeholder: '搜索擅长领域...' })
          .height(40)
          .fontSize(14)
          .backgroundColor('#f1f5f9')
          .borderRadius(10)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
          .onSubmit(() => {
            this.loadMedicalStaff();
          })
      }
      .width('100%')

      Row() {
        TextInput({ text: this.searchPhone, placeholder: '手机号搜索...' })
          .height(40)
          .fontSize(14)
          .backgroundColor('#f1f5f9')
          .borderRadius(10)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchPhone = value;
          })
          .onSubmit(() => {
            this.loadMedicalStaff();
          })

        Button('搜索')
          .type(ButtonType.Capsule)
          .backgroundColor('#2563eb')
          .height(40)
          .width(70)
          .margin({ left: 10 })
          .onClick(() => {
            this.loadMedicalStaff();
          })
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
  }

  @Builder
  private StaffCard(staff: MedicalStaffInfo) {
    Row() {
      // 头像
      Column() {
        Text(staff.gender === 0 ? '👨‍⚕️' : '👩‍⚕️')
          .fontSize(28)
      }
      .width(56)
      .height(56)
      .borderRadius(28)
      .backgroundColor('#f1f5f9')
      .justifyContent(FlexAlign.Center)

      // 信息
      Column() {
        Row() {
          Text(staff.real_name || staff.username)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1e293b')
          Text(this.getRoleTypeText(staff.role_type))
            .fontSize(11)
            .fontColor('#2563eb')
            .backgroundColor('#eff6ff')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)
            .margin({ left: 8 })
        }

        if (staff.job_title) {
          Text(staff.job_title)
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ top: 4 })
        }

        if (staff.good_at_tags) {
          Text('擅长: ' + staff.good_at_tags)
            .fontSize(12)
            .fontColor('#94a3b8')
            .margin({ top: 4 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })

      // 选择按钮
      Button('咨询')
        .type(ButtonType.Capsule)
        .backgroundColor('#2563eb')
        .fontSize(13)
        .height(34)
        .width(64)
        .onClick(() => {
          this.selectStaff(staff);
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(14)
    .shadow({ radius: 4, color: '#0f172a0a', offsetY: 1 })
    .margin({ bottom: 10 })
  }

  @Builder
  private FormSection() {
    Column() {
      // 已选医护人员信息
      Row() {
        Column() {
          Text(this.selectedStaff?.gender === 0 ? '👨‍⚕️' : '👩‍⚕️')
            .fontSize(24)
        }
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor('#eff6ff')
        .justifyContent(FlexAlign.Center)

        Column() {
          Text('咨询对象')
            .fontSize(12)
            .fontColor('#64748b')
          Text(this.selectedStaff?.real_name || this.selectedStaff?.username || '')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1e293b')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .layoutWeight(1)

        Text('更换')
          .fontSize(13)
          .fontColor('#2563eb')
          .onClick(() => {
            this.showForm = false;
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#f8fafc')
      .borderRadius(12)
      .margin({ bottom: 20 })

      // 标题输入
      Text('咨询标题')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#374151')
        .alignSelf(ItemAlign.Start)
      TextInput({ text: this.questionTitle, placeholder: '请简要描述您的问题' })
        .height(48)
        .fontSize(15)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
        .margin({ top: 8, bottom: 20 })
        .onChange((value: string) => {
          this.questionTitle = value;
        })

      // 内容输入
      Text('详细描述')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#374151')
        .alignSelf(ItemAlign.Start)
      TextArea({ text: this.questionContent, placeholder: '请详细描述您的问题或疑惑，以便医护人员更好地为您解答...' })
        .height(160)
        .fontSize(15)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
        .margin({ top: 8, bottom: 24 })
        .onChange((value: string) => {
          this.questionContent = value;
        })

      // 提交按钮
      Button(this.isSubmitting ? '提交中...' : '提交咨询')
        .type(ButtonType.Capsule)
        .backgroundColor('#2563eb')
        .width('100%')
        .height(50)
        .fontSize(16)
        .enabled(!this.isSubmitting)
        .onClick(() => {
          this.submitQuestion();
        })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 20, bottom: 30 })
  }

  build() {
    NavDestination() {
      Column() {
        if (!this.showForm) {
          // 医护人员列表页面
          this.SearchBar()

          if (this.isLoading) {
            Column() {
              LoadingProgress().width(40).height(40)
              Text('正在加载...').fontSize(14).fontColor('#64748b').margin({ top: 12 })
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          } else if (this.staffList.length === 0) {
            Column() {
              Text('👨‍⚕️')
                .fontSize(48)
              Text('暂无可用的医护人员')
                .fontSize(16)
                .fontColor('#64748b')
                .margin({ top: 16 })
              Text('请联系管理员添加医护人员')
                .fontSize(13)
                .fontColor('#9ca3af')
                .margin({ top: 8 })
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
              .padding({ left: 16, right: 16, top: 12, bottom: 20 })
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
          }
        } else {
          // 填写咨询表单页面
          Scroll() {
            this.FormSection()
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f1f5f9')
    }
    .title(this.showForm ? '填写咨询' : '选择咨询对象')
    .backgroundColor('#f1f5f9')
  }
}

@Builder
export function CreateConsultationBuilder() {
  CreateConsultation()
}
