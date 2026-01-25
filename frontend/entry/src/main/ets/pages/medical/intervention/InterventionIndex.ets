import { promptAction } from '@kit.ArkUI';
import { InterventionService } from '../../../common/api/InterventionService';
import { ApiResponse } from '../../../models/DTO/types';
import {
  MyEldersListData,
  UserElderRelationItem,
  PlanTaskInstanceResponse,
  InterventionPlanResponse,
  TodayTaskStatsResponse,
  ElderTaskStats
} from '../../../models/DTO/intervention';
import { SectionHeader } from '../../../components/common/SectionHeader';
import { StatCard } from '../../../components/common/StatCard';
import { EmptyState } from '../../../components/common/EmptyState';
import { CardContainer } from '../../../components/common/CardContainer';
import { PlanFormRouteParams } from './InterventionPlanForm';

interface PlanStats {
  active: number;
  pending: number;
  total: number;
}

@Component
export struct InterventionIndex {
  @State private elders: UserElderRelationItem[] = []
  @State private isLoadingElders: boolean = false
  @State private todayStats: TodayTaskStatsResponse | null = null
  @State private isLoadingStats: boolean = false
  @State private planStats: PlanStats = { active: 0, pending: 0, total: 0 }
  @Consume('navPathStack') navPathStack: NavPathStack;

  aboutToAppear(): void {
    this.loadElders()
  }

  private async loadElders(): Promise<void> {
    this.isLoadingElders = true
    try {
      const response = await InterventionService.getMyElders(1, 100)
      if (response.code === 200 && response.data) {
        this.elders = response.data.items || []
        // 加载今日任务统计和计划统计
        this.loadTodayStats()
        this.loadPlanStats()
      }
    } catch (error) {
      console.error('Failed to load elders')
    } finally {
      this.isLoadingElders = false
    }
  }

  private async loadTodayStats(): Promise<void> {
    if (this.elders.length === 0) {
      return
    }
    this.isLoadingStats = true
    try {
      const response = await InterventionService.getTodayTaskStats()
      if (response.code === 200 && response.data) {
        this.todayStats = response.data
      }
    } catch (error) {
      console.error('Failed to load today stats', error)
    } finally {
      this.isLoadingStats = false
    }
  }

  private async loadPlanStats(): Promise<void> {
    let active = 0
    let pending = 0
    let total = 0

    try {
      // 这里的统计逻辑还是保留原样，或者后端也能提供更好
      // 暂时保留前端循环统计，因为只是 plan 列表，不像 task 那样 N*M
      for (const elder of this.elders) {
        const elderUserId = elder.elder_user_id ?? elder.elder_id;
        const response = await InterventionService.getPlansByElderUserId(elderUserId, {
          page: 1,
          pageSize: 100
        })
        if (response.code === 200 && response.data) {
          for (const plan of response.data.records) {
            total++
            if (plan.status === 'ACTIVE') {
              active++
            }
          }
        }
      }
      this.planStats = { active, pending, total }
    } catch (error) {
      console.error('Failed to load plan stats')
    }
  }

  private openElderPlanList(elder: UserElderRelationItem): void {
    this.navPathStack.pushPathByName(
      'Medical_Intervention_ElderPlanList',
      elder
    )
  }

  private goToCreatePlan(): void {
    if (this.elders.length === 0) {
      promptAction.showToast({ message: '请先添加老人' })
      return
    }
    // 默认为第一个老人创建
    // FIX: Use elder_user_id (user account ID) instead of elder_id (elder_basic_info.id)
    const elderUserId = this.elders[0].elder_user_id ?? this.elders[0].elder_id
    const param: PlanFormRouteParams = { elderUserId: elderUserId }
    this.navPathStack.pushPath({
      name: 'Medical_Intervention_PlanForm',
      param: param as Object
    })
  }

  @Builder
  private buildTodayTasksPanel() {
    CardContainer({ title: '今日待办' }) {
      Column() {
        if (this.isLoadingStats) {
          Row() {
            LoadingProgress().width(20).height(20).color('#2563eb')
            Text('统计中...')
              .fontSize(12)
              .fontColor('#64748b')
              .margin({ left: 8 })
          }
          .padding(12)
        } else if (this.todayStats) {
          Row() {
            Column() {
              Text(this.todayStats.completed_tasks.toString())
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#16a34a')
              Text('已完成')
                .fontSize(12)
                .fontColor('#64748b')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Center)
            .layoutWeight(1)

            Divider().vertical(true).height(30).color('#e2e8f0')

            Column() {
              Text(this.todayStats.total_tasks.toString())
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1e293b')
              Text('今日任务总数')
                .fontSize(12)
                .fontColor('#64748b')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Center)
            .layoutWeight(1)
          }
          .padding({ top: 12, bottom: 12 })
          
          if (this.todayStats.total_tasks > 0) {
              Progress({ value: this.todayStats.completed_tasks, total: this.todayStats.total_tasks, type: ProgressType.Linear })
              .color('#16a34a')
              .backgroundColor('#f1f5f9')
              .height(6)
              .margin({ top: 12 })
              .width('100%')
          }
        } else {
           Text('暂无任务统计')
            .fontSize(14)
            .fontColor('#64748b')
            .padding(12)
        }
      }
    }
  }

  @Builder
  private buildStatsBar() {
    Row({ space: 12 }) {
      StatCard({
        value: this.planStats.active.toString(),
        label: '执行中',
        color: '#16a34a',
        bgColor: '#f0fdf4'
      })

      StatCard({
        value: this.planStats.pending.toString(),
        label: '待开始',
        color: '#ca8a04',
        bgColor: '#fefce8'
      })


    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  private getElderStats(elderId: number): ElderTaskStats | undefined {
    return this.todayStats?.elder_stats.find(s => s.elder_id === elderId)
  }

  @Builder
  private buildElderCard(item: UserElderRelationItem) {

    CardContainer() {
      Row() {
        Text(item.elder.gender === 1 ? '👴' : '👵')
          .fontSize(32)
          .margin({ right: 12 })

        Column() {
          Text(item.elder.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e293b')
          Text(`${item.elder.age}岁`)
            .fontSize(12)
            .fontColor('#64748b')
            .margin({ top: 2 })
            
          if (this.getElderStats(item.elder_id)) {
             Row() {
               Text(`今日任务: ${this.getElderStats(item.elder_id)!.completed_tasks}/${this.getElderStats(item.elder_id)!.total_tasks}`)
                .fontSize(12)
                .fontColor(this.getElderStats(item.elder_id)!.completed_tasks === this.getElderStats(item.elder_id)!.total_tasks && this.getElderStats(item.elder_id)!.total_tasks > 0 ? '#16a34a' : '#64748b')
                .backgroundColor(this.getElderStats(item.elder_id)!.completed_tasks === this.getElderStats(item.elder_id)!.total_tasks && this.getElderStats(item.elder_id)!.total_tasks > 0 ? '#f0fdf4' : '#f8fafc')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ top: 6 })
             }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('管理计划 →')
          .fontSize(13)
          .fontColor('#2563eb')
      }
      .width('100%')
      .onClick(() => {
        this.openElderPlanList(item)
      })
    }
  }

  build() {
    Column() {
      if (this.isLoadingElders && this.elders.length === 0) {
        Column() {
          LoadingProgress().width(32).height(32).color('#2563eb')
          Text('加载中...')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.elders.length === 0) {
        EmptyState({
          icon: '📋',
          title: '暂无关联老人',
          subtitle: '请先在档案页面添加老人后再创建干预计划'
        })
      } else {
        Scroll() {
          Column() {
            // 今日待办
            this.buildTodayTasksPanel()

            // // 统计栏
            // this.buildStatsBar()

            // 老人列表
            SectionHeader({ title: '老人干预' })
            ForEach(this.elders, (item: UserElderRelationItem) => {
              this.buildElderCard(item)
            }, (item: UserElderRelationItem) => item.relation_id.toString())
          }
          .constraintSize({
            minHeight:"100%"
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#f8fafc')
  }
}
