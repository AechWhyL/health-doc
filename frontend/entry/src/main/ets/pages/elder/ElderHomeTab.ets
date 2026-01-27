import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

interface UserResponse {
  id: number;
  username: string;
  role: string;
  elder_info?: ElderResponse;
}

interface ElderResponse {
  id: number;
  name: string;
  gender: number;
  age: number;
  phone: string;
  address: string | null;
  emergency_contact: string | null;
  height: number | null;
  weight: number | null;
  blood_type: string | null;
  birth_date?: string;
}



// 新的今日任务API响应类型
export interface ElderTaskInstanceInfo {
  id: number;
  item_id: number;
  schedule_id: number | null;
  task_date: string;
  task_time: string | null;
  status: string;
  complete_time: string | null;
  remark: string | null;
  proof_image_url: string | null;
}

export interface ElderPlanItemInfo {
  id: number;
  plan_id: number;
  item_type: string;
  name: string;
  description: string | null;
  status: string;
  start_date: string;
  end_date: string | null;
  drug_name?: string;
  dosage?: string;
  frequency_type?: string;
  instructions?: string | null;
  exercise_name?: string;
  exercise_type?: string | null;
  guide_resource_url?: string | null;
}

export interface ElderPlanInfo {
  id: number;
  elder_user_id: number;
  title: string;
  description: string | null;
  status: string;
  start_date: string;
  end_date: string | null;
}

interface ElderTasksByPlanItem {
  plan_item: ElderPlanItemInfo;
  tasks: ElderTaskInstanceInfo[];
}

interface ElderTasksByPlan {
  plan: ElderPlanInfo;
  items: ElderTasksByPlanItem[];
}

interface ElderTodayTasksResponse {
  date: string;
  total_tasks: number;
  completed_tasks: number;
  plans: ElderTasksByPlan[];
}

// 用于传递给详情页的数据
export interface TaskDetailNavParam {
  task: ElderTaskInstanceInfo;
  plan_item: ElderPlanItemInfo;
  plan: ElderPlanInfo;
}

@Component
export struct ElderHomeTab {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State elderId: number = -1;
  @State elderName: string = '';
  @State elderInfo: ElderResponse | null = null;

  @State todayTasksData: ElderTodayTasksResponse | null = null;
  @State isLoading: boolean = true;
  @State profileIncomplete: boolean = false;
  @State missingFields: string[] = [];

  aboutToAppear(): void {
    this.loadData();
    this.navPathStack.setInterception({
      willShow: (from: NavDestinationContext | 'navBar', to: NavDestinationContext | 'navBar') => {
        if (typeof from === 'string') {
          let target = to as NavDestinationContext;
          console.info(`from page is navigation home -> ${target.pathInfo.name}`);
        } else if (typeof to === 'string') {
          let target = from as NavDestinationContext;
          console.info(`${target.pathInfo.name} -> to page is navigation home`);
          this.loadData()
        }
      }
    });
  }

  private async loadData(): Promise<void> {
    this.isLoading = true;

    try {
      // 在老人端，当前登录用户即为老人本人
      // 直接获取当前用户信息及档案
      const response = await httpRequest<ApiResponse<UserResponse>, void>({
        url: '/api/v1/users/current',
        method: RequestEnum.GET
      });

      if (response.code === 200 && response.data) {
        const user = response.data;
        this.elderId = user.id; // 当前用户ID即为老人ID
        
        if (user.elder_info) {
          const elder = user.elder_info;
          this.elderName = elder.name;
          this.elderInfo = elder;
          this.checkProfileCompleteness(elder);
        } else {
          // 只有基本用户账号，未完善老人信息
          this.elderName = user.username;
        }


        // 获取今日任务
        await this.loadTodayTasks();
      }
    } catch (error) {
      console.error('加载数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  private checkProfileCompleteness(elder: ElderResponse): void {
    const missing: string[] = [];
    if (!elder.address) {
      missing.push('家庭住址');
    }
    if (!elder.emergency_contact) {
      missing.push('紧急联系人');
    }
    if (!elder.height) {
      missing.push('身高');
    }
    if (!elder.weight) {
      missing.push('体重');
    }
    if (!elder.blood_type) {
      missing.push('血型');
    }
    this.missingFields = missing;
    this.profileIncomplete = missing.length > 0;
  }



  private async loadTodayTasks(): Promise<void> {
    try {
      const params: Record<string, Object> = {};
      const response = await httpRequest<ApiResponse<ElderTodayTasksResponse>, Record<string, Object>>({
        url: '/api/v1/intervention/elder/today-tasks',
        method: RequestEnum.GET,
        params: params
      });

      if (response.code === 200 && response.data) {
        this.todayTasksData = response.data;
      }
    } catch (error) {
      console.warn('获取今日任务失败:', error);
    }
  }



  private navigateToTaskDetail(task: ElderTaskInstanceInfo, planItem: ElderPlanItemInfo, plan: ElderPlanInfo): void {
    const param: TaskDetailNavParam = {
      task: task,
      plan_item: planItem,
      plan: plan
    };
    this.navPathStack.pushPathByName('Elder_TaskDetail', param);
  }



  @Builder
  private TodayTasksCard() {
    Column() {
      Row() {
        Text('📋 今日任务')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#166534')
        Blank()
        if (this.todayTasksData) {
          Text(this.todayTasksData.completed_tasks + '/' + this.todayTasksData.total_tasks + ' 已完成')
            .fontSize(12)
            .fontColor('#64748b')
        }
      }
      .width('100%')
      .margin({ bottom: 14 })

      if (!this.todayTasksData || this.todayTasksData.plans.length === 0) {
        Column() {
          Text('🎉')
            .fontSize(32)
          Text('今日暂无任务')
            .fontSize(14)
            .fontColor('#9ca3af')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(20)
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(this.todayTasksData.plans, (planGroup: ElderTasksByPlan, planIndex: number) => {
          // 计划分组标题
          Column() {
            if (planIndex > 0) {
              Divider()
                .strokeWidth(1)
                .color('#e5e7eb')
                .margin({ top: 12, bottom: 12 })
            }

            Row() {
              Text('📌')
                .fontSize(14)
              Text(planGroup.plan.title)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#374151')
                .margin({ left: 6 })
            }
            .width('100%')
            .margin({ bottom: 10 })

            // 计划项和任务列表
            ForEach(planGroup.items, (itemGroup: ElderTasksByPlanItem) => {
              ForEach(itemGroup.tasks, (task: ElderTaskInstanceInfo) => {
                Row() {
                  Column() {
                    Row() {
                      Text(itemGroup.plan_item.item_type === 'MEDICATION' ? '💊' : '🏃')
                        .fontSize(12)
                      Text(itemGroup.plan_item.name)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#1e293b')
                        .margin({ left: 4 })
                    }
                    if (task.task_time) {
                      Text(task.task_time)
                        .fontSize(12)
                        .fontColor('#64748b')
                        .margin({ top: 4 })
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  Text(task.status === 'COMPLETED' ? '✓ 已完成' : task.status === 'SKIPPED' ? '已跳过' : '待完成')
                    .fontSize(11)
                    .fontColor(task.status === 'COMPLETED' ? '#16a34a' : task.status === 'SKIPPED' ? '#9ca3af' : '#f59e0b')

                  Text('>')
                    .fontSize(14)
                    .fontColor('#9ca3af')
                    .margin({ left: 8 })
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#f8fafc')
                .borderRadius(10)
                .margin({ bottom: 8 })
                .onClick(() => {
                  this.navigateToTaskDetail(task, itemGroup.plan_item, planGroup.plan);
                })
              }, (task: ElderTaskInstanceInfo) => task.id.toString())
            }, (itemGroup: ElderTasksByPlanItem) => itemGroup.plan_item.id.toString())
          }
          .width('100%')
        }, (planGroup: ElderTasksByPlan) => planGroup.plan.id.toString())
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 6, color: '#0f172a0a', offsetY: 2 })
  }

  @Builder
  private ProfileCompletionBanner() {
    Row() {
      Column() {
        Row() {
          Text('⚠️')
            .fontSize(18)
          Text(' 个人信息待完善')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#92400e')
        }
        Text('缺少：' + this.missingFields.join('、'))
          .fontSize(12)
          .fontColor('#b45309')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('去完善 →')
        .fontSize(13)
        .fontColor('#d97706')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#fef3c7')
    .borderRadius(12)
    .margin({ bottom: 14 })
    .onClick(() => {
      promptAction.showToast({ message: '请前往"我的"页面完善个人信息' });
    })
  }

  build() {
    Column() {
      // 问候语
      Row() {
        Column() {
          Text('您好' + (this.elderName ? '，' + this.elderName : '') + ' 👋')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#166534')
          Text('祝您身体健康，生活愉快')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40)
          Text('加载中...').fontSize(14).fontColor('#64748b').margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 个人信息完善提示
            if (this.profileIncomplete) {
              this.ProfileCompletionBanner()
            }

            this.TodayTasksCard()
          }
          .constraintSize({
            minHeight:'100%'
          })
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
  }
}
