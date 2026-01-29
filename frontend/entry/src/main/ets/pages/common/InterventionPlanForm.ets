import { promptAction } from '@kit.ArkUI';
import { InterventionService } from '../../common/api/InterventionService';
import { CreateInterventionPlanRequest } from '../../models/DTO/intervention';
import { IUser } from '../../models/DTO/UserModels';
import { FormInputRow } from '../../components/form/FormInputRow'
import { FormDatePicker } from '../../components/form/FormDatePicker'
import { CardContainer } from '../../components/common/CardContainer'

@Builder
export function InterventionPlanFormBuilder() {
  InterventionPlanForm()
}

export interface PlanFormRouteParams {
  elderUserId: number;
}

@Component
export struct InterventionPlanForm {
  @State elderUserId: number = 0
  @State title: string = ''
  @State description: string = ''
  @State startDate: Date | null = new Date()
  @State endDate: Date | null = null
  @State isSubmitting: boolean = false
  @Consume('navPathStack') navPathStack: NavPathStack;

  private async submit() {
    if (!this.title.trim()) {
      promptAction.showToast({ message: '请输入计划标题' });
      return;
    }
    if (!this.startDate) {
      promptAction.showToast({ message: '请选择开始日期' });
      return;
    }

    this.isSubmitting = true;
    try {
      const request: CreateInterventionPlanRequest = {
        elderUserId: this.elderUserId,
        title: this.title,
        description: this.description,
        startDate: this.startDate.toISOString().split('T')[0],
        endDate: this.endDate ? this.endDate.toISOString().split('T')[0] : null,
        createdByUserId: this.getCurrentUserId()
      };

      const response = await InterventionService.createPlan(request);
      if (response.code === 200) {
        promptAction.showToast({ message: '创建成功' });
        this.navPathStack.pop();
      } else {
        promptAction.showToast({ message: response.message || '创建失败' });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络异常' });
    } finally {
      this.isSubmitting = false;
    }
  }

  private getCurrentUserId(): number {
    const user = AppStorage.get<IUser>('currentUser');
    if (user && user.id) {
      return user.id;
    }
    // Fallback or error handling if needed. 
    // Ideally this shouldn't happen if user is logged in.
    console.warn('[InterventionPlanForm] Failed to get current user ID, defaulting to 1');
    return 1; 
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            CardContainer({ title: '基本信息' }) {
              Column() {
                FormInputRow({
                  label: '计划标题',
                  placeholder: '例如：高血压综合干预',
                  required: true,
                  value: this.title
                })

                FormInputRow({
                  label: '计划描述',
                  placeholder: '请输入计划描述...',
                  multiline: true,
                  value: this.description
                })
              }
            }

            CardContainer({ title: '时间范围' }) {
              Column() {
                FormDatePicker({
                  label: '开始日期',
                  value: this.startDate
                })

                FormDatePicker({
                  label: '结束日期',
                  optional: true,
                  value: this.endDate
                })
              }
            }

            Button(this.isSubmitting ? '提交中...' : '创建计划')
              .type(ButtonType.Capsule)
              .width('100%')
              .height(48)
              .fontSize(16)
              .backgroundColor('#2563eb')
              .onClick(() => {
                this.submit()
              })
              .enabled(!this.isSubmitting)
              .margin({ top: 12 })
          }
          .padding(16)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f8fafc')
    }
    .title('新建干预计划')
    .onReady((ctx: NavDestinationContext) => {
      const params = ctx.pathInfo.param as PlanFormRouteParams;
      if (params && params.elderUserId) {
        this.elderUserId = params.elderUserId;
      }
    })
  }
}
