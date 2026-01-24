import dayjs from 'dayjs';
import { InterventionPlanItemRepository } from '../repositories/interventionPlanItem.repository';
import {
  CreatePlanItemRequest,
  UpdatePlanItemRequest,
  QueryPlanItemRequest,
  PlanItemResponse,
  PlanItemStatus,
  CreatePlanItemScheduleRequest,
  UpdatePlanItemScheduleRequest,
  PlanItemScheduleResponse,
  PlanTaskInstanceResponse,
  QueryPlanTaskInstanceRequest,
  CreateTaskInstancesRequest,
  UpdateTaskInstanceStatusRequest,
  TodayTaskStatsResponse,
  ElderTaskStats
} from '../dto/requests/interventionPlanItem.dto';
import {
  ElderTodayTasksResponse,
  ElderTasksByPlan,
  ElderTasksByPlanItem,
  ElderPlanInfo,
  ElderPlanItemInfo,
  ElderTaskInstanceInfo,
  ElderTodayTaskRawRow
} from '../dto/requests/elderTasks.dto';
import {
  PlanItem,
  PlanItemSchedule,
  PlanTaskInstance
} from '../types/interventionPlanItem';
import { InterventionPlanRepository } from '../repositories/interventionPlan.repository';
import { NotFoundError } from '../utils/errors';

export class InterventionPlanItemService {
  private static buildTaskSeedsForSchedule(
    schedule: Pick<
      PlanItemSchedule,
      'schedule_type' | 'start_date' | 'end_date' | 'times_of_day' | 'weekdays'
    >,
    rangeStart: string,
    rangeEnd: string
  ): { task_date: string; task_time: string }[] {
    const start = dayjs(rangeStart);
    const end = dayjs(rangeEnd);

    if (!start.isValid() || !end.isValid() || end.isBefore(start, 'day')) {
      throw new NotFoundError('任务生成日期范围不合法');
    }

    const scheduleStart = dayjs(schedule.start_date);
    const scheduleEnd = schedule.end_date ? dayjs(schedule.end_date) : null;
    const weekdays = schedule.weekdays || [];

    const seeds: { task_date: string; task_time: string }[] = [];
    let current = start.clone();

    while (!current.isAfter(end, 'day')) {
      const withinScheduleStart = !current.isBefore(scheduleStart, 'day');
      const withinScheduleEnd =
        !scheduleEnd || !current.isAfter(scheduleEnd, 'day');

      if (withinScheduleStart && withinScheduleEnd) {
        let matched = false;

        if (schedule.schedule_type === 'ONCE') {
          matched = current.isSame(scheduleStart, 'day');
        } else if (schedule.schedule_type === 'DAILY') {
          matched = true;
        } else if (schedule.schedule_type === 'WEEKLY') {
          const dayOfWeek = current.day() === 0 ? 7 : current.day();
          matched = weekdays.includes(dayOfWeek);
        }

        if (matched) {
          const dateStr = current.format('YYYY-MM-DD');
          for (const time of schedule.times_of_day) {
            seeds.push({
              task_date: dateStr,
              task_time: time
            });
          }
        }
      }

      current = current.add(1, 'day');
    }

    return seeds;
  }
  static async createPlanItem(
    planId: number,
    data: CreatePlanItemRequest
  ): Promise<PlanItemResponse> {
    const plan = await InterventionPlanRepository.findById(planId);
    if (!plan) {
      throw new NotFoundError('干预计划不存在');
    }

    const planItemData: Omit<PlanItem, 'id' | 'created_at' | 'updated_at'> = {
      plan_id: planId,
      item_type: data.itemType,
      name: data.name,
      description: data.description ?? null,
      status: 'ACTIVE',
      start_date: data.startDate,
      end_date: data.endDate ?? null
    };

    const insertId = await InterventionPlanItemRepository.createPlanItem(
      planItemData,
      data.itemType === 'MEDICATION' && data.medicationDetail
        ? {
          drug_name: data.medicationDetail.drug_name,
          dosage: data.medicationDetail.dosage,
          frequency_type: data.medicationDetail.frequency_type,
          instructions: data.medicationDetail.instructions ?? null
        }
        : undefined,
      data.itemType === 'REHAB' && data.rehabDetail
        ? {
          exercise_name: data.rehabDetail.exercise_name,
          exercise_type: data.rehabDetail.exercise_type ?? null,
          guide_resource_url: data.rehabDetail.guide_resource_url ?? null
        }
        : undefined
    );

    const created = await this.getPlanItemById(insertId);
    return created;
  }

  static async getPlanItemById(id: number): Promise<PlanItemResponse> {
    const item = await InterventionPlanItemRepository.findById(id);
    if (!item) {
      throw new NotFoundError('计划项不存在');
    }

    if (item.item_type === 'MEDICATION') {
      const detail = await InterventionPlanItemRepository.findMedicationDetailByItemId(id);
      if (!detail) {
        throw new NotFoundError('用药计划项详情不存在');
      }
      return {
        id: item.id!,
        plan_id: item.plan_id,
        item_type: item.item_type,
        name: item.name,
        description: item.description ?? null,
        status: item.status,
        start_date: item.start_date,
        end_date: item.end_date ?? null,
        drug_name: detail.drug_name,
        dosage: detail.dosage,
        frequency_type: detail.frequency_type,
        instructions: detail.instructions ?? null
      };
    }

    if (item.item_type === 'REHAB') {
      const detail = await InterventionPlanItemRepository.findRehabDetailByItemId(id);
      if (!detail) {
        throw new NotFoundError('康复计划项详情不存在');
      }
      return {
        id: item.id!,
        plan_id: item.plan_id,
        item_type: item.item_type,
        name: item.name,
        description: item.description ?? null,
        status: item.status,
        start_date: item.start_date,
        end_date: item.end_date ?? null,
        exercise_name: detail.exercise_name,
        exercise_type: detail.exercise_type ?? null,
        guide_resource_url: detail.guide_resource_url ?? null
      };
    }

    throw new NotFoundError('计划项类型不支持');
  }

  static async getPlanItemsByPlanId(
    planId: number,
    query: QueryPlanItemRequest
  ): Promise<PlanItemResponse[]> {
    console.log(planId);
    const plan = await InterventionPlanRepository.findById(planId);
    if (!plan) {
      throw new NotFoundError('干预计划不存在');
    }

    const list = await InterventionPlanItemRepository.findByPlanId(
      planId,
      query.status
    );

    const results: PlanItemResponse[] = [];

    for (const item of list) {
      if (item.item_type === 'MEDICATION') {
        const detail = await InterventionPlanItemRepository.findMedicationDetailByItemId(item.id!);
        if (!detail) {
          continue;
        }
        results.push({
          id: item.id!,
          plan_id: item.plan_id,
          item_type: item.item_type,
          name: item.name,
          description: item.description ?? null,
          status: item.status,
          start_date: item.start_date,
          end_date: item.end_date ?? null,
          drug_name: detail.drug_name,
          dosage: detail.dosage,
          frequency_type: detail.frequency_type,
          instructions: detail.instructions ?? null
        });
      } else if (item.item_type === 'REHAB') {
        const detail = await InterventionPlanItemRepository.findRehabDetailByItemId(item.id!);
        if (!detail) {
          continue;
        }
        results.push({
          id: item.id!,
          plan_id: item.plan_id,
          item_type: item.item_type,
          name: item.name,
          description: item.description ?? null,
          status: item.status,
          start_date: item.start_date,
          end_date: item.end_date ?? null,
          exercise_name: detail.exercise_name,
          exercise_type: detail.exercise_type ?? null,
          guide_resource_url: detail.guide_resource_url ?? null
        });
      }
    }

    return results;
  }

  static async updatePlanItem(
    itemId: number,
    data: UpdatePlanItemRequest
  ): Promise<PlanItemResponse> {
    const item = await InterventionPlanItemRepository.findById(itemId);
    if (!item) {
      throw new NotFoundError('计划项不存在');
    }

    const updateData: Partial<Omit<PlanItem, 'id'>> = {};

    if (data.name !== undefined) {
      updateData.name = data.name;
    }
    if (data.description !== undefined) {
      updateData.description = data.description;
    }
    if (data.startDate !== undefined) {
      updateData.start_date = data.startDate;
    }
    if (data.endDate !== undefined) {
      updateData.end_date = data.endDate;
    }

    if (Object.keys(updateData).length > 0) {
      await InterventionPlanItemRepository.updatePlanItem(itemId, updateData);
    }

    if (item.item_type === 'MEDICATION' && data.medicationDetail) {
      await InterventionPlanItemRepository.updateMedicationDetail(itemId, {
        drug_name: data.medicationDetail.drug_name,
        dosage: data.medicationDetail.dosage,
        frequency_type: data.medicationDetail.frequency_type,
        instructions: data.medicationDetail.instructions
      });
    }

    if (item.item_type === 'REHAB' && data.rehabDetail) {
      await InterventionPlanItemRepository.updateRehabDetail(itemId, {
        exercise_name: data.rehabDetail.exercise_name,
        exercise_type: data.rehabDetail.exercise_type,
        guide_resource_url: data.rehabDetail.guide_resource_url
      });
    }

    const updated = await this.getPlanItemById(itemId);
    return updated;
  }

  static async updatePlanItemStatus(
    itemId: number,
    status: PlanItemStatus
  ): Promise<PlanItemResponse> {
    const item = await InterventionPlanItemRepository.findById(itemId);
    if (!item) {
      throw new NotFoundError('计划项不存在');
    }

    await InterventionPlanItemRepository.updatePlanItem(itemId, {
      status
    });

    // 如果状态变为 STOPPED，将所有未完成的任务实例标记为已跳过
    if (status === 'STOPPED') {
      const skippedCount = await InterventionPlanItemRepository.skipPendingTasksByItemId(itemId);
      console.log(`Skipped ${skippedCount} pending tasks for item ${itemId}`);
    }

    const updated = await this.getPlanItemById(itemId);
    return updated;
  }

  static async deletePlanItem(itemId: number): Promise<void> {
    const item = await InterventionPlanItemRepository.findById(itemId);
    if (!item) {
      throw new NotFoundError('计划项不存在');
    }

    await InterventionPlanItemRepository.deleteById(itemId);
  }

  static async createPlanItemSchedule(
    itemId: number,
    data: CreatePlanItemScheduleRequest
  ): Promise<PlanItemScheduleResponse> {
    const item = await InterventionPlanItemRepository.findById(itemId);
    if (!item) {
      throw new NotFoundError('计划项不存在');
    }

    const scheduleData: Omit<PlanItemSchedule, 'id' | 'created_at' | 'updated_at'> = {
      item_id: itemId,
      schedule_type: data.scheduleType,
      start_date: data.startDate,
      end_date: data.endDate ?? null,
      times_of_day: data.timesOfDay,
      weekdays: data.weekdays ?? null
    };

    const rangeStart = scheduleData.start_date;
    const rangeEnd = scheduleData.end_date ?? scheduleData.start_date;

    const seeds = this.buildTaskSeedsForSchedule(
      {
        schedule_type: scheduleData.schedule_type,
        start_date: scheduleData.start_date,
        end_date: scheduleData.end_date ?? null,
        times_of_day: scheduleData.times_of_day,
        weekdays: scheduleData.weekdays ?? null
      },
      rangeStart,
      rangeEnd
    );

    const { scheduleId } =
      await InterventionPlanItemRepository.createPlanItemScheduleWithTasks(
        scheduleData,
        seeds
      );

    const created = await InterventionPlanItemRepository.findScheduleById(scheduleId);
    if (!created) {
      throw new NotFoundError('创建日程失败');
    }

    return {
      id: created.id!,
      item_id: created.item_id,
      schedule_type: created.schedule_type,
      start_date: created.start_date,
      end_date: created.end_date ?? null,
      times_of_day: created.times_of_day,
      weekdays: created.weekdays ?? null,
      created_at: created.created_at!,
      updated_at: created.updated_at!
    };
  }

  static async getPlanItemSchedules(itemId: number): Promise<PlanItemScheduleResponse[]> {
    const item = await InterventionPlanItemRepository.findById(itemId);
    if (!item) {
      throw new NotFoundError('计划项不存在');
    }

    const list = await InterventionPlanItemRepository.findSchedulesByItemId(itemId);
    return list.map(schedule => ({
      id: schedule.id!,
      item_id: schedule.item_id,
      schedule_type: schedule.schedule_type,
      start_date: schedule.start_date,
      end_date: schedule.end_date ?? null,
      times_of_day: schedule.times_of_day,
      weekdays: schedule.weekdays ?? null,
      created_at: schedule.created_at!,
      updated_at: schedule.updated_at!
    }));
  }

  static async updatePlanItemSchedule(
    scheduleId: number,
    data: UpdatePlanItemScheduleRequest
  ): Promise<PlanItemScheduleResponse> {
    const schedule = await InterventionPlanItemRepository.findScheduleById(scheduleId);
    if (!schedule) {
      throw new NotFoundError('日程不存在');
    }

    const updateData: Partial<Omit<PlanItemSchedule, 'id'>> = {};

    if (data.scheduleType !== undefined) {
      updateData.schedule_type = data.scheduleType;
    }
    if (data.startDate !== undefined) {
      updateData.start_date = data.startDate;
    }
    if (data.endDate !== undefined) {
      updateData.end_date = data.endDate;
    }
    if (data.timesOfDay !== undefined) {
      updateData.times_of_day = data.timesOfDay;
    }
    if (data.weekdays !== undefined) {
      updateData.weekdays = data.weekdays ?? null;
    }

    if (Object.keys(updateData).length > 0) {
      await InterventionPlanItemRepository.updatePlanItemSchedule(scheduleId, updateData);
    }

    const updated = await InterventionPlanItemRepository.findScheduleById(scheduleId);
    if (!updated) {
      throw new NotFoundError('日程不存在');
    }

    return {
      id: updated.id!,
      item_id: updated.item_id,
      schedule_type: updated.schedule_type,
      start_date: updated.start_date,
      end_date: updated.end_date ?? null,
      times_of_day: updated.times_of_day,
      weekdays: updated.weekdays ?? null,
      created_at: updated.created_at!,
      updated_at: updated.updated_at!
    };
  }

  static async deletePlanItemSchedule(scheduleId: number): Promise<void> {
    const schedule = await InterventionPlanItemRepository.findScheduleById(scheduleId);
    if (!schedule) {
      throw new NotFoundError('日程不存在');
    }
    await InterventionPlanItemRepository.deletePlanItemSchedule(scheduleId);
  }

  static async generateTaskInstancesForSchedule(
    scheduleId: number,
    data: CreateTaskInstancesRequest
  ): Promise<{ createdCount: number }> {
    const schedule = await InterventionPlanItemRepository.findScheduleById(scheduleId);
    if (!schedule) {
      throw new NotFoundError('日程不存在');
    }

    const item = await InterventionPlanItemRepository.findById(schedule.item_id);
    if (!item) {
      throw new NotFoundError('计划项不存在');
    }

    if (data.overrideExisting) {
      await InterventionPlanItemRepository.deleteTaskInstancesByScheduleAndDateRange(
        scheduleId,
        data.startDate,
        data.endDate
      );
    }

    const seeds = this.buildTaskSeedsForSchedule(
      {
        schedule_type: schedule.schedule_type,
        start_date: schedule.start_date,
        end_date: schedule.end_date ?? null,
        times_of_day: schedule.times_of_day,
        weekdays: schedule.weekdays ?? null
      },
      data.startDate,
      data.endDate
    );

    let createdCount = 0;

    for (const seed of seeds) {
      const task: Omit<PlanTaskInstance, 'id' | 'created_at' | 'updated_at'> = {
        item_id: schedule.item_id,
        schedule_id: schedule.id!,
        task_date: seed.task_date,
        task_time: seed.task_time,
        status: 'PENDING',
        complete_time: null
      };
      await InterventionPlanItemRepository.createTaskInstance(task);
      createdCount += 1;
    }

    return { createdCount };
  }

  static async getTaskInstancesByItemId(
    itemId: number,
    query: QueryPlanTaskInstanceRequest
  ): Promise<PlanTaskInstanceResponse[]> {
    const item = await InterventionPlanItemRepository.findById(itemId);
    if (!item) {
      throw new NotFoundError('计划项不存在');
    }

    const list = await InterventionPlanItemRepository.findTaskInstancesByItemId(
      itemId,
      query.startDate,
      query.endDate,
      query.status
    );

    return list.map(task => ({
      id: task.id!,
      item_id: task.item_id,
      schedule_id: task.schedule_id ?? null,
      task_date: task.task_date,
      task_time: task.task_time ?? null,
      status: task.status,
      complete_time: task.complete_time ?? null,
      remark: task.remark ?? null,
      proof_image_url: task.proof_image_url ?? null,
      created_at: task.created_at!,
      updated_at: task.updated_at!
    }));
  }

  static async getTaskInstanceById(taskId: number): Promise<PlanTaskInstanceResponse> {
    const task = await InterventionPlanItemRepository.findTaskInstanceById(taskId);
    if (!task) {
      throw new NotFoundError('任务实例不存在');
    }

    return {
      id: task.id!,
      item_id: task.item_id,
      schedule_id: task.schedule_id ?? null,
      task_date: task.task_date,
      task_time: task.task_time ?? null,
      status: task.status,
      complete_time: task.complete_time ?? null,
      remark: task.remark ?? null,
      proof_image_url: task.proof_image_url ?? null,
      created_at: task.created_at!,
      updated_at: task.updated_at!,
    };
  }

  static async updateTaskInstanceStatus(
    taskId: number,
    data: UpdateTaskInstanceStatusRequest
  ): Promise<PlanTaskInstanceResponse> {
    const task = await InterventionPlanItemRepository.findTaskInstanceById(taskId);
    if (!task) {
      throw new NotFoundError('任务实例不存在');
    }

    await InterventionPlanItemRepository.updateTaskInstanceStatus(
      taskId,
      data.status,
      data.remark,
      data.proof_image_url
    );

    const updated = await InterventionPlanItemRepository.findTaskInstanceById(taskId);
    if (!updated) {
      throw new NotFoundError('任务实例不存在');
    }

    return {
      id: updated.id!,
      item_id: updated.item_id,
      schedule_id: updated.schedule_id ?? null,
      task_date: updated.task_date,
      task_time: updated.task_time ?? null,
      status: updated.status,
      complete_time: updated.complete_time ?? null,
      remark: updated.remark ?? null,
      proof_image_url: updated.proof_image_url ?? null,
      created_at: updated.created_at!,
      updated_at: updated.updated_at!
    };
  }

  static async getTodayTaskStats(userId: number): Promise<TodayTaskStatsResponse> {
    // 1. Get all elders associated with the user
    // We need to import UserElderRelationService or Repository. 
    // To avoid circular dependency issues if any, we use Repository directly or dynamic import.
    // However, UserElderRelationService is safe to import here usually.
    // Let's us the Repository directly to be safe and efficient as we only need IDs.

    // Actually, let's use the Service method we saw earlier or Repository.
    // I need to import ElderUserRelationRepository. 
    // But wait, I recall seeing `UserElderRelationService.getUserElders` in `userElderRelation.service.ts`.
    // Let's import the Repository to avoid circular dependency hell if UserElderRelationService imports Intervention stuff.
    // Checking `UserElderRelationService`... it imports `ruleEngine.service` but not InterventionService.
    // But `InterventionPlanItemService` is deep. 
    // Let's just use `ElderUserRelationRepository`.
    const { ElderUserRelationRepository } = require('../repositories/elderUserRelation.repository');

    // We need all elders, so page=1, pageSize=1000 (enough for one staff)
    const { items } = await ElderUserRelationRepository.findByUserIdWithElder(
      userId,
      1,
      1000
    );

    const elderIds = items.map((item: any) => item.elder_user_id).filter((id: number) => id != null);

    if (elderIds.length === 0) {
      return {
        total_elders: 0,
        total_tasks: 0,
        completed_tasks: 0,
        elder_stats: []
      };
    }

    const today = dayjs().format('YYYY-MM-DD');
    const stats = await InterventionPlanItemRepository.getTaskStatsByElderIds(elderIds, today);

    // Creates a map for easy lookup
    const statsMap = new Map(stats.map(s => [s.elder_id, s]));

    const elderStats: ElderTaskStats[] = elderIds.map((id: number) => {
      const stat = statsMap.get(id);
      return {
        elder_id: id,
        total_tasks: stat ? Number(stat.total_tasks) : 0,
        completed_tasks: stat ? Number(stat.completed_tasks) : 0
      };
    });

    const totalTasks = elderStats.reduce((sum, item) => sum + item.total_tasks, 0);
    const completedTasks = elderStats.reduce((sum, item) => sum + item.completed_tasks, 0);

    return {
      total_elders: elderIds.length,
      total_tasks: totalTasks,
      completed_tasks: completedTasks,
      elder_stats: elderStats
    };
  }

  /**
   * 获取老人今日任务列表，按计划和计划项分组聚合
   */
  static async getElderTodayTasks(elderUserId: number): Promise<ElderTodayTasksResponse> {
    const today = dayjs().format('YYYY-MM-DD');
    const rows: ElderTodayTaskRawRow[] = await InterventionPlanItemRepository.findTodayTasksByElderUserId(
      elderUserId,
      today
    );

    // 统计总数和已完成数
    const totalTasks = rows.length;
    const completedTasks = rows.filter(r => r.task_status === 'COMPLETED').length;

    // 按计划分组
    const planMap = new Map<number, ElderTasksByPlan>();
    const itemMap = new Map<number, ElderTasksByPlanItem>();

    for (const row of rows) {
      // 获取或创建计划分组
      if (!planMap.has(row.plan_id)) {
        const planInfo: ElderPlanInfo = {
          id: row.plan_id,
          elder_user_id: row.plan_elder_user_id,
          title: row.plan_title,
          description: row.plan_description,
          status: row.plan_status,
          start_date: row.plan_start_date,
          end_date: row.plan_end_date
        };
        planMap.set(row.plan_id, {
          plan: planInfo,
          items: []
        });
      }

      // 获取或创建计划项分组
      if (!itemMap.has(row.item_id)) {
        const itemInfo: ElderPlanItemInfo = {
          id: row.item_id,
          plan_id: row.item_plan_id,
          item_type: row.item_type,
          name: row.item_name,
          description: row.item_description,
          status: row.item_status,
          start_date: row.item_start_date,
          end_date: row.item_end_date
        };

        // 添加用药或康复详情
        if (row.item_type === 'MEDICATION' && row.med_drug_name) {
          itemInfo.drug_name = row.med_drug_name;
          itemInfo.dosage = row.med_dosage ?? undefined;
          itemInfo.frequency_type = row.med_frequency_type ?? undefined;
          itemInfo.instructions = row.med_instructions;
        } else if (row.item_type === 'REHAB' && row.rehab_exercise_name) {
          itemInfo.exercise_name = row.rehab_exercise_name;
          itemInfo.exercise_type = row.rehab_exercise_type;
          itemInfo.guide_resource_url = row.rehab_guide_resource_url;
        }

        const itemGroup: ElderTasksByPlanItem = {
          plan_item: itemInfo,
          tasks: []
        };
        itemMap.set(row.item_id, itemGroup);
        planMap.get(row.plan_id)!.items.push(itemGroup);
      }

      // 添加任务实例
      const taskInfo: ElderTaskInstanceInfo = {
        id: row.task_id,
        item_id: row.task_item_id,
        schedule_id: row.task_schedule_id,
        task_date: row.task_date,
        task_time: row.task_time,
        status: row.task_status,
        complete_time: row.task_complete_time,
        remark: row.task_remark,
        proof_image_url: row.task_proof_image_url
      };
      itemMap.get(row.item_id)!.tasks.push(taskInfo);
    }

    return {
      date: today,
      total_tasks: totalTasks,
      completed_tasks: completedTasks,
      plans: Array.from(planMap.values())
    };
  }
}
