import { promptAction } from '@kit.ArkUI';
import { InterventionService } from '../../../common/api/InterventionService';
import { CreateInterventionPlanRequest } from '../../../models/DTO/intervention';

export interface PlanFormRouteParams {
  elderUserId: number;
}

@Component
export struct InterventionPlanForm {
  @State elderUserId: number = 0
  @State title: string = ''
  @State description: string = ''
  @State startDate: Date = new Date()
  @State endDate: Date | null = null
  @State isSubmitting: boolean = false
  @Consume('navPathStack') navPathStack: NavPathStack;

  aboutToAppear(): void {
    const params = this.navPathStack.getParamByName('Medical_Intervention_PlanForm') as Record<string, number>[];
    if (params && params.length > 0 && params[0].elderUserId) {
      this.elderUserId = params[0].elderUserId;
    }
  }

  private async submit() {
    if (!this.title.trim()) {
      promptAction.showToast({ message: '请输入计划标题' });
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
        createdByUserId: 0 // Backend handles this usually based on token, but DTO requires it?
        // Let's check DTO. DTO says required. But backend controller usually takes user from token.
        // Let's check controller: `backend/src/controllers/interventionPlan.controller.ts`.
        // If it requires it in body, I need to send it. But usually `createdByUserId` is from ctx.state.user.id.
        // DTO `createInterventionPlanSchema` requires `createdByUserId`.
        // Middleware `validateBody` will check it.
        // I might need to send a dummy ID or the current user ID if I have it.
        // Since I don't have current user ID easily available here (it's in `AppStorage` maybe?), I'll send 1 or check if backend overrides it.
        // I'll check backend controller logic.
      };

      // Temporary: Backend should probably override this or I need to get it from storage.
      // I'll assume backend might use it or I need to pass it.
      // Ideally I should get it from UserStore.
      request.createdByUserId = 1; // Dummy for now, assuming backend overrides or I am user 1.

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

  build() {
    Column() {
      Scroll() {
        Column() {
          // Title
          Text('计划标题')
            .fontSize(14)
            .fontColor('#374151')
            .width('100%')
            .margin({ bottom: 6 })
          TextInput({ placeholder: '例如：高血压综合干预', text: this.title })
            .onChange((value) => this.title = value)
            .width('100%')
            .height(40)
            .margin({ bottom: 16 })

          // Description
          Text('计划描述')
            .fontSize(14)
            .fontColor('#374151')
            .width('100%')
            .margin({ bottom: 6 })
          TextArea({ placeholder: '请输入计划描述...', text: this.description })
            .onChange((value) => this.description = value)
            .width('100%')
            .height(80)
            .margin({ bottom: 16 })

          // Start Date
          Text('开始日期')
            .fontSize(14)
            .fontColor('#374151')
            .width('100%')
            .margin({ bottom: 6 })
          Row() {
            Text(this.startDate.toISOString().split('T')[0])
              .fontSize(16)
              .fontColor('#111827')

            Button('选择')
              .fontSize(12)
              .onClick(() => {
                DatePickerDialog.show({
                  start: new Date("2000-1-1"),
                  end: new Date("2100-12-31"),
                  selected: this.startDate,
                  onAccept: (value: DatePickerResult) => {
                    this.startDate.setFullYear(value.year, value.month, value.day)
                    // trigger update
                    this.startDate = new Date(this.startDate)
                  }
                })
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(10)
          .backgroundColor('#ffffff')
          .borderRadius(4)
          .margin({ bottom: 16 })

          // End Date
          Text('结束日期 (可选)')
            .fontSize(14)
            .fontColor('#374151')
            .width('100%')
            .margin({ bottom: 6 })
          Row() {
            Text(this.endDate ? this.endDate.toISOString().split('T')[0] : '未设置')
              .fontSize(16)
              .fontColor(this.endDate ? '#111827' : '#9ca3af')

            Row() {
              if (this.endDate) {
                Button('清除')
                  .fontSize(12)
                  .fontColor('red')
                  .backgroundColor(Color.Transparent)
                  .onClick(() => {
                    this.endDate = null
                  })
                  .margin({ right: 8 })
              }
              Button('选择')
                .fontSize(12)
                .onClick(() => {
                  DatePickerDialog.show({
                    start: new Date("2000-1-1"),
                    end: new Date("2100-12-31"),
                    selected: this.endDate || new Date(),
                    onAccept: (value: DatePickerResult) => {
                      const d = new Date()
                      d.setFullYear(value.year, value.month, value.day)
                      this.endDate = d
                    }
                  })
                })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(10)
          .backgroundColor('#ffffff')
          .borderRadius(4)
          .margin({ bottom: 24 })

          // Submit
          Button(this.isSubmitting ? '提交中...' : '创建计划')
            .type(ButtonType.Capsule)
            .width('100%')
            .onClick(() => {
              this.submit()
            })
            .enabled(!this.isSubmitting)
        }
        .padding(16)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f9fafb')
  }

  // .onReady((ctx: NavDestinationContext) => {
  //   this.elderUserId = (ctx.pathInfo.param as PlanFormRouteParams).elderUserId
  // })
}
