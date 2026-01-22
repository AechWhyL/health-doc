import { Database } from '../config/database';
import {
  PlanItem,
  MedicationPlanItemDetail,
  RehabPlanItemDetail,
  PlanItemSchedule,
  PlanTaskInstance
} from '../types/interventionPlanItem';

export class InterventionPlanItemRepository {
  static async createPlanItem(
    planItem: Omit<PlanItem, 'id' | 'created_at' | 'updated_at'>,
    medicationDetail?: Omit<MedicationPlanItemDetail, 'item_id'>,
    rehabDetail?: Omit<RehabPlanItemDetail, 'item_id'>
  ): Promise<number> {
    const connection = await Database.beginTransaction();

    try {
      const insertPlanItemSql = `
        INSERT INTO plan_item (plan_id, item_type, name, description, status, start_date, end_date)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      `;
      const planItemParams = [
        planItem.plan_id,
        planItem.item_type,
        planItem.name,
        planItem.description ?? null,
        planItem.status,
        planItem.start_date,
        planItem.end_date ?? null
      ];

      const [planItemResult] = await connection.execute(insertPlanItemSql, planItemParams);
      const insertId = (planItemResult as any).insertId as number;

      if (planItem.item_type === 'MEDICATION' && medicationDetail) {
        const insertMedicationSql = `
          INSERT INTO medication_plan_item (item_id, drug_name, dosage, frequency_type, instructions)
          VALUES (?, ?, ?, ?, ?)
        `;
        const medicationParams = [
          insertId,
          medicationDetail.drug_name,
          medicationDetail.dosage,
          medicationDetail.frequency_type,
          medicationDetail.instructions ?? null
        ];
        await connection.execute(insertMedicationSql, medicationParams);
      }

      if (planItem.item_type === 'REHAB' && rehabDetail) {
        const insertRehabSql = `
          INSERT INTO rehab_plan_item (item_id, exercise_name, exercise_type, guide_resource_url)
          VALUES (?, ?, ?, ?)
        `;
        const rehabParams = [
          insertId,
          rehabDetail.exercise_name,
          rehabDetail.exercise_type ?? null,
          rehabDetail.guide_resource_url ?? null
        ];
        await connection.execute(insertRehabSql, rehabParams);
      }

      await Database.commitTransaction(connection);
      return insertId;
    } catch (error) {
      await Database.rollbackTransaction(connection);
      throw error;
    }
  }

  static async findById(id: number): Promise<PlanItem | null> {
    const sql = 'SELECT * FROM plan_item WHERE id = ?';
    return await Database.queryOne<PlanItem>(sql, [id]);
  }

  static async findMedicationDetailByItemId(itemId: number): Promise<MedicationPlanItemDetail | null> {
    const sql = 'SELECT * FROM medication_plan_item WHERE item_id = ?';
    return await Database.queryOne<MedicationPlanItemDetail>(sql, [itemId]);
  }

  static async findRehabDetailByItemId(itemId: number): Promise<RehabPlanItemDetail | null> {
    const sql = 'SELECT * FROM rehab_plan_item WHERE item_id = ?';
    return await Database.queryOne<RehabPlanItemDetail>(sql, [itemId]);
  }

  static async findByPlanId(
    planId: number,
    status?: string
  ): Promise<PlanItem[]> {
    const whereParts: string[] = ['plan_id = ?'];
    const params: (number | string)[] = [planId];

    if (status) {
      whereParts.push('status = ?');
      params.push(status);
    }

    const where = whereParts.join(' AND ');
    const sql = `SELECT * FROM plan_item WHERE ${where} ORDER BY start_date ASC, id ASC`;

    return await Database.query<PlanItem>(sql, params);
  }

  static async updatePlanItem(
    id: number,
    data: Partial<Omit<PlanItem, 'id'>>
  ): Promise<number> {
    const fields: string[] = [];
    const params: (number | string | null)[] = [];

    if (data.name !== undefined) {
      fields.push('name = ?');
      params.push(data.name);
    }
    if (data.description !== undefined) {
      fields.push('description = ?');
      params.push(data.description);
    }
    if (data.status !== undefined) {
      fields.push('status = ?');
      params.push(data.status);
    }
    if (data.start_date !== undefined) {
      fields.push('start_date = ?');
      params.push(data.start_date);
    }
    if (data.end_date !== undefined) {
      fields.push('end_date = ?');
      params.push(data.end_date);
    }

    if (fields.length === 0) {
      return 0;
    }

    const sql = `
      UPDATE plan_item
      SET ${fields.join(', ')}
      WHERE id = ?
    `;
    params.push(id);

    return await Database.update(sql, params);
  }

  static async updateMedicationDetail(
    itemId: number,
    detail: Partial<Omit<MedicationPlanItemDetail, 'item_id'>>
  ): Promise<void> {
    const fields: string[] = [];
    const params: (string | null)[] = [];

    if (detail.drug_name !== undefined) {
      fields.push('drug_name = ?');
      params.push(detail.drug_name);
    }
    if (detail.dosage !== undefined) {
      fields.push('dosage = ?');
      params.push(detail.dosage);
    }
    if (detail.frequency_type !== undefined) {
      fields.push('frequency_type = ?');
      params.push(detail.frequency_type);
    }
    if (detail.instructions !== undefined) {
      fields.push('instructions = ?');
      params.push(detail.instructions ?? null);
    }

    if (fields.length === 0) {
      return;
    }

    const sql = `
      UPDATE medication_plan_item
      SET ${fields.join(', ')}
      WHERE item_id = ?
    `;
    params.push(String(itemId));

    await Database.update(sql, params);
  }

  static async updateRehabDetail(
    itemId: number,
    detail: Partial<Omit<RehabPlanItemDetail, 'item_id'>>
  ): Promise<void> {
    const fields: string[] = [];
    const params: (string | null)[] = [];

    if (detail.exercise_name !== undefined) {
      fields.push('exercise_name = ?');
      params.push(detail.exercise_name);
    }
    if (detail.exercise_type !== undefined) {
      fields.push('exercise_type = ?');
      params.push(detail.exercise_type ?? null);
    }
    if (detail.guide_resource_url !== undefined) {
      fields.push('guide_resource_url = ?');
      params.push(detail.guide_resource_url ?? null);
    }

    if (fields.length === 0) {
      return;
    }

    const sql = `
      UPDATE rehab_plan_item
      SET ${fields.join(', ')}
      WHERE item_id = ?
    `;
    params.push(String(itemId));

    await Database.update(sql, params);
  }

  static async deleteById(id: number): Promise<void> {
    const connection = await Database.beginTransaction();

    try {
      const deleteMedicationSql = 'DELETE FROM medication_plan_item WHERE item_id = ?';
      await connection.execute(deleteMedicationSql, [id]);

      const deleteRehabSql = 'DELETE FROM rehab_plan_item WHERE item_id = ?';
      await connection.execute(deleteRehabSql, [id]);

      const deletePlanItemSql = 'DELETE FROM plan_item WHERE id = ?';
      await connection.execute(deletePlanItemSql, [id]);

      await Database.commitTransaction(connection);
    } catch (error) {
      await Database.rollbackTransaction(connection);
      throw error;
    }
  }

  static async createPlanItemSchedule(
    schedule: Omit<PlanItemSchedule, 'id' | 'created_at' | 'updated_at'>
  ): Promise<number> {
    const sql = `
      INSERT INTO plan_item_schedule (item_id, schedule_type, start_date, end_date, times_of_day, weekdays)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    const params = [
      schedule.item_id,
      schedule.schedule_type,
      schedule.start_date,
      schedule.end_date ?? null,
      JSON.stringify(schedule.times_of_day),
      schedule.weekdays && schedule.weekdays.length > 0 ? JSON.stringify(schedule.weekdays) : null
    ];

    return await Database.insert(sql, params);
  }

  static async createPlanItemScheduleWithTasks(
    schedule: Omit<PlanItemSchedule, 'id' | 'created_at' | 'updated_at'>,
    taskSeeds: { task_date: string; task_time: string }[]
  ): Promise<{ scheduleId: number; createdCount: number }> {
    const connection = await Database.beginTransaction();

    try {
      const insertScheduleSql = `
        INSERT INTO plan_item_schedule (item_id, schedule_type, start_date, end_date, times_of_day, weekdays)
        VALUES (?, ?, ?, ?, ?, ?)
      `;
      const scheduleParams = [
        schedule.item_id,
        schedule.schedule_type,
        schedule.start_date,
        schedule.end_date ?? null,
        JSON.stringify(schedule.times_of_day),
        schedule.weekdays && schedule.weekdays.length > 0 ? JSON.stringify(schedule.weekdays) : null
      ];

      const [scheduleResult] = await connection.execute(insertScheduleSql, scheduleParams);
      const scheduleId = (scheduleResult as any).insertId as number;

      if (taskSeeds.length > 0) {
        const insertTaskSql = `
          INSERT INTO plan_task_instance (item_id, schedule_id, task_date, task_time, status, complete_time)
          VALUES (?, ?, ?, ?, ?, ?)
        `;

        for (const seed of taskSeeds) {
          const taskParams = [
            schedule.item_id,
            scheduleId,
            seed.task_date,
            seed.task_time,
            'PENDING',
            null
          ];
          await connection.execute(insertTaskSql, taskParams);
        }
      }

      await Database.commitTransaction(connection);
      return {
        scheduleId,
        createdCount: taskSeeds.length
      };
    } catch (error) {
      await Database.rollbackTransaction(connection);
      throw error;
    }
  }

  static async findScheduleById(id: number): Promise<PlanItemSchedule | null> {
    const sql = 'SELECT * FROM plan_item_schedule WHERE id = ?';
    const row = await Database.queryOne<any>(sql, [id]);
    if (!row) {
      return null;
    }
    if (row.times_of_day) {
      row.times_of_day = row.times_of_day;
    } else {
      row.times_of_day = [];
    }
    if (row.weekdays) {
      row.weekdays = row.weekdays;
    } else {
      row.weekdays = null;
    }
    return row as PlanItemSchedule;
  }

  static async findSchedulesByItemId(itemId: number): Promise<PlanItemSchedule[]> {
    const sql = 'SELECT * FROM plan_item_schedule WHERE item_id = ? ORDER BY start_date ASC, id ASC';
    const rows = await Database.query<any>(sql, [itemId]);
    return rows.map(row => {
      if (row.times_of_day) {
        row.times_of_day = row.times_of_day;
      } else {
        row.times_of_day = [];
      }
      if (row.weekdays) {
        row.weekdays = row.weekdays;
      } else {
        row.weekdays = null;
      }
      return row as PlanItemSchedule;
    });
  }

  static async updatePlanItemSchedule(
    id: number,
    data: Partial<Omit<PlanItemSchedule, 'id'>>
  ): Promise<number> {
    const fields: string[] = [];
    const params: (number | string | null)[] = [];

    if (data.schedule_type !== undefined) {
      fields.push('schedule_type = ?');
      params.push(data.schedule_type);
    }
    if (data.start_date !== undefined) {
      fields.push('start_date = ?');
      params.push(data.start_date);
    }
    if (data.end_date !== undefined) {
      fields.push('end_date = ?');
      params.push(data.end_date ?? null);
    }
    if (data.times_of_day !== undefined) {
      fields.push('times_of_day = ?');
      params.push(JSON.stringify(data.times_of_day));
    }
    if (data.weekdays !== undefined) {
      fields.push('weekdays = ?');
      params.push(data.weekdays && data.weekdays.length > 0 ? JSON.stringify(data.weekdays) : null);
    }

    if (fields.length === 0) {
      return 0;
    }

    const sql = `
      UPDATE plan_item_schedule
      SET ${fields.join(', ')}
      WHERE id = ?
    `;
    params.push(id);

    return await Database.update(sql, params);
  }

  static async deletePlanItemSchedule(id: number): Promise<number> {
    const sql = 'DELETE FROM plan_item_schedule WHERE id = ?';
    return await Database.delete(sql, [id]);
  }

  static async createTaskInstance(
    task: Omit<PlanTaskInstance, 'id' | 'created_at' | 'updated_at'>
  ): Promise<number> {
    const sql = `
      INSERT INTO plan_task_instance (item_id, schedule_id, task_date, task_time, status, complete_time)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    const params = [
      task.item_id,
      task.schedule_id ?? null,
      task.task_date,
      task.task_time ?? null,
      task.status,
      task.complete_time ?? null
    ];

    return await Database.insert(sql, params);
  }

  static async findTaskInstanceById(id: number): Promise<PlanTaskInstance | null> {
    const sql = 'SELECT * FROM plan_task_instance WHERE id = ?';
    return await Database.queryOne<PlanTaskInstance>(sql, [id]);
  }

  static async findTaskInstancesByItemId(
    itemId: number,
    startDate?: string | Date,
    endDate?: string | Date,
    status?: string
  ): Promise<PlanTaskInstance[]> {
    const whereParts: string[] = ['item_id = ?'];
    const params: (number | string)[] = [itemId];

    // 将 Date 对象转换为 YYYY-MM-DD 字符串
    const formatDate = (date: string | Date): string => {
      if (date instanceof Date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
      }
      return date;
    };

    if (startDate) {
      whereParts.push('task_date >= ?');
      params.push(formatDate(startDate));
    }
    if (endDate) {
      whereParts.push('task_date <= ?');
      params.push(formatDate(endDate));
    }
    if (status) {
      whereParts.push('status = ?');
      params.push(status);
    }

    const where = whereParts.join(' AND ');
    const sql = `SELECT * FROM plan_task_instance WHERE ${where} ORDER BY task_date ASC, task_time ASC, id ASC`;
    console.log('findTaskInstancesByItemId SQL:', sql, 'params:', params);
    const result = await Database.query<PlanTaskInstance>(sql, params);
    console.log('findTaskInstancesByItemId result count:', result.length);
    return result;
  }

  static async deleteTaskInstancesByScheduleAndDateRange(
    scheduleId: number,
    startDate: string,
    endDate: string
  ): Promise<number> {
    const sql = `
      DELETE FROM plan_task_instance
      WHERE schedule_id = ?
        AND task_date >= ?
        AND task_date <= ?
    `;
    const params = [scheduleId, startDate, endDate];
    return await Database.delete(sql, params);
  }

  static async updateTaskInstanceStatus(
    id: number,
    status: string,
    remark?: string,
    proof_image_url?: string
  ): Promise<number> {
    const fields: string[] = ['status = ?'];
    const params: (string | number | null)[] = [status];

    if (status === 'COMPLETED') {
      fields.push('complete_time = NOW()');
    } else {
      fields.push('complete_time = NULL');
    }

    if (remark !== undefined) {
      fields.push('remark = ?');
      params.push(remark);
    }

    if (proof_image_url !== undefined) {
      fields.push('proof_image_url = ?');
      params.push(proof_image_url);
    }

    const sql = `
      UPDATE plan_task_instance
      SET ${fields.join(', ')}
      WHERE id = ?
    `;
    params.push(id);

    return await Database.update(sql, params);
  }

  /**
   * 将计划项下所有未完成(PENDING)的任务实例状态更新为已跳过(SKIPPED)
   */
  static async skipPendingTasksByItemId(itemId: number): Promise<number> {
    const sql = `
      UPDATE plan_task_instance
      SET status = 'SKIPPED'
      WHERE item_id = ? AND status = 'PENDING'
    `;
    return await Database.update(sql, [itemId]);
  }

  /**
   * 批量更新指定计划下的所有计划项状态
   */
  static async updateStatusByPlanId(planId: number, status: string): Promise<number> {
    const sql = `
      UPDATE plan_item
      SET status = ?
      WHERE plan_id = ?
    `;
    return await Database.update(sql, [status, planId]);
  }

  /**
   * 批量更新指定任务实例的状态
   */
  static async updateTaskInstanceStatusByIds(taskIds: number[], status: string): Promise<number> {
    if (taskIds.length === 0) {
      return 0;
    }
    const placeholders = taskIds.map(() => '?').join(', ');
    const sql = `
      UPDATE plan_task_instance
      SET status = ?
      WHERE id IN (${placeholders})
    `;
    return await Database.update(sql, [status, ...taskIds]);
  }

  /**
   * 查询指定计划下所有PENDING状态的任务实例
   */
  static async findPendingTaskInstancesByPlanId(planId: number): Promise<{ id: number }[]> {
    const sql = `
      SELECT pti.id
      FROM plan_task_instance pti
      JOIN plan_item pi ON pti.item_id = pi.id
      WHERE pi.plan_id = ? AND pti.status = 'PENDING'
    `;
    return await Database.query<{ id: number }>(sql, [planId]);
  }

  static async getTaskStatsByElderIds(
    elderIds: number[],
    date: string
  ): Promise<{ elder_id: number; total_tasks: number; completed_tasks: number }[]> {
    if (elderIds.length === 0) {
      return [];
    }

    const placeholders = elderIds.map(() => '?').join(', ');
    const sql = `
      SELECT 
        ip.elder_user_id as elder_id,
        COUNT(pti.id) as total_tasks,
        SUM(CASE WHEN pti.status = 'COMPLETED' THEN 1 ELSE 0 END) as completed_tasks
      FROM plan_task_instance pti
      JOIN plan_item pi ON pti.item_id = pi.id
      JOIN intervention_plan ip ON pi.plan_id = ip.id
      WHERE ip.elder_user_id IN (${placeholders})
        AND pti.task_date = ?
      GROUP BY ip.elder_user_id
    `;

    const params = [...elderIds, date];
    // Note: The return type of query generic T implies we get array of T.
    // The raw result from driver for COUNT/SUM might be string or number depending on driver config.
    // We cast it to expected type.
    return await Database.query<any>(sql, params);
  }

  /**
   * 获取指定老人在指定日期的所有任务实例，并关联计划项和计划信息
   */
  static async findTodayTasksByElderUserId(
    elderUserId: number,
    date: string
  ): Promise<any[]> {
    const sql = `
      SELECT 
        pti.id as task_id,
        pti.item_id as task_item_id,
        pti.schedule_id as task_schedule_id,
        pti.task_date,
        pti.task_time,
        pti.status as task_status,
        pti.complete_time as task_complete_time,
        pti.remark as task_remark,
        pti.proof_image_url as task_proof_image_url,
        
        pi.id as item_id,
        pi.plan_id as item_plan_id,
        pi.item_type,
        pi.name as item_name,
        pi.description as item_description,
        pi.status as item_status,
        pi.start_date as item_start_date,
        pi.end_date as item_end_date,
        
        mpi.drug_name as med_drug_name,
        mpi.dosage as med_dosage,
        mpi.frequency_type as med_frequency_type,
        mpi.instructions as med_instructions,
        
        rpi.exercise_name as rehab_exercise_name,
        rpi.exercise_type as rehab_exercise_type,
        rpi.guide_resource_url as rehab_guide_resource_url,
        
        ip.id as plan_id,
        ip.elder_user_id as plan_elder_user_id,
        ip.title as plan_title,
        ip.description as plan_description,
        ip.status as plan_status,
        ip.start_date as plan_start_date,
        ip.end_date as plan_end_date
      FROM plan_task_instance pti
      JOIN plan_item pi ON pti.item_id = pi.id
      JOIN intervention_plan ip ON pi.plan_id = ip.id
      LEFT JOIN medication_plan_item mpi ON pi.id = mpi.item_id AND pi.item_type = 'MEDICATION'
      LEFT JOIN rehab_plan_item rpi ON pi.id = rpi.item_id AND pi.item_type = 'REHAB'
      WHERE ip.elder_user_id = ?
        AND pti.task_date = ?
      ORDER BY ip.id ASC, pi.id ASC, pti.task_time ASC, pti.id ASC
    `;

    return await Database.query<any>(sql, [elderUserId, date]);
  }
}
