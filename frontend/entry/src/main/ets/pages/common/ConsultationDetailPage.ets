import { ConsultationQuestion, UserInfo, MedicalStaffInfo } from '../../models/ConsultationModels';
import { ConsultationService } from '../../common/api/ConsultationService';
import dayjs from 'dayjs';

export interface ConsultationDetailParams {
  id: number;
}


@Builder
export function ConsultationDetailPageBuilder() {
  ConsultationDetailPage()
}

@ComponentV2
export struct ConsultationDetailPage {
  @Local private questionId: number = 0;
  @Local private consultation: ConsultationQuestion | null = null;
  @Local private isLoading: boolean = true;
  @Local private loadError: string = '';
  private navPathStack: NavPathStack = new NavPathStack();

  private async loadData(): Promise<void> {
    this.isLoading = true;
    this.loadError = '';

    try {
      const response = await ConsultationService.getQuestionById(this.questionId);
      if (response.code !== 200) {
        this.loadError = response.message || '加载咨询详情失败';
        this.isLoading = false;
        return;
      }
      this.consultation = response.data || null;
      this.isLoading = false;
    } catch (_error) {
      this.loadError = '网络异常，加载咨询详情失败';
      this.isLoading = false;
    }
  }

  private formatDate(dateStr: string | undefined): string {
    if (!dateStr) return '未知';
    return dayjs(dateStr).format('YYYY-MM-DD HH:mm:ss');
  }

  private getRoleLabel(role: string): string {
    switch (role) {
      case 'ELDER': return '老人';
      case 'FAMILY': return '家属';
      case 'STAFF': return '医护人员';
      default: return role;
    }
  }

  private getDisplayGender(gender: number | undefined): string {
    if (gender === 0) return '男';
    if (gender === 1) return '女';
    return '未知';
  }

  @Builder
  private InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#64748b')
        .width(80)
      Text(value)
        .fontSize(14)
        .fontColor('#1e293b')
        .layoutWeight(1)
        .wordBreak(WordBreak.BREAK_ALL)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .padding({ top: 8, bottom: 8 })
    .border({ width: { bottom: 1 }, color: '#f1f5f9' })
  }

  @Builder
  private SectionTitle(title: string) {
    Text(title)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor('#0f172a')
      .margin({ top: 20, bottom: 12 })
      .width('100%')
  }

  @Builder
  private UserCard(title: string, user: UserInfo | undefined | null, roleLabel: string) {
    Column() {
      this.SectionTitle(title)
      
      Column() {
        if (user) {
          Row() {
             // Avatar fallback
             Text(user.real_name?.substring(0, 1) || user.username?.substring(0, 1) || '?')
               .fontSize(20)
               .fontWeight(FontWeight.Bold)
               .fontColor(Color.White)
               .width(48)
               .height(48)
               .borderRadius(24)
               .backgroundColor('#3b82f6')
               .textAlign(TextAlign.Center)
               .margin({ right: 16 })
             
             Column() {
               Text(user.real_name || user.username)
                 .fontSize(16)
                 .fontWeight(FontWeight.Medium)
                 .fontColor('#1e293b')
               
               Row({space: 8}) {
                 Text(roleLabel)
                   .fontSize(12)
                   .fontColor('#64748b')
                   .backgroundColor('#f1f5f9')
                   .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                   .borderRadius(4)
                 
                 if (user.phone) {
                    Text(user.phone)
                      .fontSize(12)
                      .fontColor('#64748b')
                 }
               }
               .margin({ top: 4 })
             }
             .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#f8fafc')
          .borderRadius(12)

          // Detailed Info
          Column() {
             if (user.gender !== undefined) {
               this.InfoRow('性别', this.getDisplayGender(user.gender))
             }
             if (user.birth_date) {
               this.InfoRow('年龄', dayjs().diff(dayjs(user.birth_date),'year').toString())
             }
             if ((user as MedicalStaffInfo).job_title) {
               this.InfoRow('职称', (user as MedicalStaffInfo).job_title || '')
             }
             if ((user as MedicalStaffInfo).good_at_tags) {
               this.InfoRow('擅长', (user as MedicalStaffInfo).good_at_tags || '')
             }
          }
          .padding({ top: 12 })
          
        } else {
          Text('暂无信息')
            .fontSize(14)
            .fontColor('#94a3b8')
            .padding(16)
        }
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .padding(16)
      .shadow({ radius: 2, color: '#0f172a08', offsetY: 1 })
    }
    .width('100%')
  }

  build() {
    NavDestination() {
       Column() {
          if (this.isLoading) {
            Column() {
              LoadingProgress().width(48).height(48).color('#2563eb')
              Text('加载中...').fontSize(14).fontColor('#64748b').margin({ top: 12 })
            }
            .width('100%').height('100%').justifyContent(FlexAlign.Center)
          } else if (this.loadError) {
             Column() {
               Text('😕').fontSize(48)
               Text(this.loadError).fontSize(14).fontColor('#64748b').margin({ top: 12 })
               Button('重试')
                 .onClick(() => this.loadData())
                 .margin({ top: 20 })
             }
             .width('100%').height('100%').justifyContent(FlexAlign.Center)
          } else if (this.consultation) {
             Scroll() {
               Column() {
                  // Basic Info
                  Column() {
                    Text(this.consultation.title)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#1e293b')
                      .margin({ bottom: 8 })

                    Row() {
                      Text(`${this.consultation.description}`)
                        .fontSize(14)
                        .fontColor('#ff6b7583')
                        .margin({ bottom: 8 })
                    }
                    
                    Row() {
                      Text(`编号: CQ${this.consultation.id}`)
                        .fontSize(12)
                        .fontColor('#94a3b8')
                        .margin({ right: 16 })
                      
                      Text(this.formatDate(this.consultation.created_at))
                        .fontSize(12)
                        .fontColor('#94a3b8')
                    }
                  }
                  .width('100%')
                  .padding(20)
                  .backgroundColor(Color.White)
                  .borderRadius(12)
                  .shadow({ radius: 2, color: '#0f172a08', offsetY: 1 })

                  // Creator Info
                  this.UserCard('咨询发起人', this.consultation.creator_info, this.getRoleLabel(this.consultation.creator_type))

                  // Target Staff Info
                  this.UserCard('目标医护人员', this.consultation.target_staff, '医护人员')

               }
               .padding(16)
               .width('100%')
               .constraintSize({ minHeight: '100%' })
             }
             .scrollBar(BarState.Off)
             .layoutWeight(1)
          }
       }
       .width('100%')
       .height('100%')
       .backgroundColor('#f8fafc')
    }
    .title('咨询详情')
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack;
      const params = ctx.pathInfo.param as ConsultationDetailParams;
      if (params && params.id) {
         this.questionId = params.id;
         this.loadData();
      }
    })
  }
}
