import { Database } from '../config/database';
import { NotificationStatus, UserNotificationRecord } from '../types/notification';

export class NotificationRepository {
  static async create(
    data: Omit<UserNotificationRecord, 'id' | 'created_at' | 'read_at'>
  ): Promise<number> {
    const sql = `
      INSERT INTO user_notification (
        user_id,
        biz_type,
        biz_id,
        title,
        content,
        status
      )
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.user_id,
      data.biz_type,
      data.biz_id,
      data.title,
      data.content,
      data.status
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<UserNotificationRecord | null> {
    const sql = 'SELECT * FROM user_notification WHERE id = ?';
    return await Database.queryOne<UserNotificationRecord>(sql, [id]);
  }

  static async findByUserId(
    userId: number,
    page: number,
    pageSize: number,
    status?: NotificationStatus
  ): Promise<{ items: UserNotificationRecord[]; total: number }> {
    let where = 'user_id = ?';
    const params: any[] = [userId];

    if (status) {
      where += ' AND status = ?';
      params.push(status);
    }

    return await Database.paginate<UserNotificationRecord>(
      'user_notification',
      page,
      pageSize,
      where,
      params,
      'created_at DESC, id DESC'
    );
  }

  static async markAsRead(id: number): Promise<boolean> {
    const sql = `
      UPDATE user_notification
      SET status = 'READ', read_at = NOW()
      WHERE id = ?
    `;
    const result = await Database.update(sql, [id]);
    return result > 0;
  }
}
