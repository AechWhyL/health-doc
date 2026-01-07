import { Database } from '../config/database';
import { ReminderStatus, ReminderTaskRecord } from '../types/reminder';

export class ReminderTaskRepository {
  static async create(
    data: Omit<ReminderTaskRecord, 'id' | 'created_at' | 'updated_at'>
  ): Promise<number> {
    const sql = `
      INSERT INTO reminder_task (
        biz_type,
        biz_id,
        target_user_id,
        channel,
        title,
        content,
        remind_at,
        status
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.biz_type,
      data.biz_id,
      data.target_user_id,
      data.channel,
      data.title,
      data.content,
      data.remind_at,
      data.status
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<ReminderTaskRecord | null> {
    const sql = 'SELECT * FROM reminder_task WHERE id = ?';
    return await Database.queryOne<ReminderTaskRecord>(sql, [id]);
  }

  static async findDueTasks(now: string, limit: number): Promise<ReminderTaskRecord[]> {
    const sql = `
      SELECT *
      FROM reminder_task
      WHERE status = ? AND remind_at <= ?
      ORDER BY remind_at ASC, id ASC
      LIMIT ?
    `;
    const params = ['PENDING', now, limit];
    return await Database.query<ReminderTaskRecord>(sql, params);
  }

  static async updateStatus(id: number, status: ReminderStatus): Promise<void> {
    const sql = `
      UPDATE reminder_task
      SET status = ?, updated_at = NOW()
      WHERE id = ?
    `;
    const params = [status, id];
    await Database.update(sql, params);
  }
}

