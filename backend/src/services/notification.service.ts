import { NotificationRepository } from '../repositories/notification.repository';
import { NotificationStatus, UserNotificationRecord } from '../types/notification';
import { NotificationResponse, QueryNotificationRequest } from '../dto/requests/notification.dto';
import { NotFoundError } from '../utils/errors';

export class NotificationService {
  static async getUserNotifications(
    userId: number,
    query: QueryNotificationRequest
  ): Promise<{ items: NotificationResponse[]; total: number }> {
    const { page, pageSize, status } = query;

    const { items, total } = await NotificationRepository.findByUserId(
      userId,
      page,
      pageSize,
      status
    );

    return {
      items: items.map(item => this.toResponse(item)),
      total
    };
  }

  static async markAsRead(notificationId: number, userId: number): Promise<NotificationResponse> {
    const record = await NotificationRepository.findById(notificationId);
    if (!record || record.user_id !== userId) {
      throw new NotFoundError('通知不存在');
    }

    if (record.status === 'READ') {
      return this.toResponse(record);
    }

    const success = await NotificationRepository.markAsRead(notificationId);
    if (!success) {
      throw new Error('更新通知状态失败');
    }

    const updated = await NotificationRepository.findById(notificationId);
    if (!updated) {
      throw new Error('获取更新后的通知失败');
    }

    return this.toResponse(updated);
  }

  private static toResponse(record: UserNotificationRecord): NotificationResponse {
    return {
      id: record.id!,
      user_id: record.user_id,
      biz_type: record.biz_type,
      biz_id: record.biz_id,
      title: record.title,
      content: record.content,
      status: record.status as NotificationStatus,
      created_at: record.created_at || '',
      read_at: record.read_at ?? null
    };
  }
}

