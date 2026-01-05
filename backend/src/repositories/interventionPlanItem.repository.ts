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
      row.times_of_day = JSON.parse(row.times_of_day);
    } else {
      row.times_of_day = [];
    }
    if (row.weekdays) {
      row.weekdays = JSON.parse(row.weekdays);
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
        row.times_of_day = JSON.parse(row.times_of_day);
      } else {
        row.times_of_day = [];
      }
      if (row.weekdays) {
        row.weekdays = JSON.parse(row.weekdays);
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
    startDate?: string,
    endDate?: string,
    status?: string
  ): Promise<PlanTaskInstance[]> {
    const whereParts: string[] = ['item_id = ?'];
    const params: (number | string)[] = [itemId];

    if (startDate) {
      whereParts.push('task_date >= ?');
      params.push(startDate);
    }
    if (endDate) {
      whereParts.push('task_date <= ?');
      params.push(endDate);
    }
    if (status) {
      whereParts.push('status = ?');
      params.push(status);
    }

    const where = whereParts.join(' AND ');
    const sql = `SELECT * FROM plan_task_instance WHERE ${where} ORDER BY task_date ASC, task_time ASC, id ASC`;
    return await Database.query<PlanTaskInstance>(sql, params);
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
    status: string
  ): Promise<number> {
    const fields: string[] = ['status = ?'];
    const params: (string | number)[] = [status];

    if (status === 'COMPLETED') {
      fields.push('complete_time = NOW()');
    } else {
      fields.push('complete_time = NULL');
    }

    const sql = `
      UPDATE plan_task_instance
      SET ${fields.join(', ')}
      WHERE id = ?
    `;
    params.push(id);

    return await Database.update(sql, params);
  }
}
