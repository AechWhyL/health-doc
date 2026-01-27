import { Context } from 'koa';
import {
  NotificationResponse,
  QueryNotificationRequest
} from '../dto/requests/notification.dto';
import { NotificationService } from '../services/notification.service';
import { TaskScheduler } from '../services/taskScheduler';

export class NotificationController {
  static async getNotificationList(ctx: Context) {
    const data: QueryNotificationRequest = ctx.state.validatedData || ctx.query;
    const { page, pageSize, status } = data;

    const user = ctx.state.user;
    if (!user) {
      ctx.unauthorized('用户未认证');
      return;
    }

    const { items, total } = await NotificationService.getUserNotifications(user.userId, {
      page,
      pageSize,
      status
    });

    ctx.paginate<NotificationResponse>(items, page, pageSize, total);
  }

  static async markAsRead(ctx: Context) {
    const { id } = ctx.state.validatedData || ctx.params;
    const notificationId = Number(id);

    if (!Number.isInteger(notificationId) || notificationId <= 0) {
      ctx.badRequest('无效的通知ID');
      return;
    }

    const user = ctx.state.user;
    if (!user) {
      ctx.unauthorized('用户未认证');
      return;
    }

    const result = await NotificationService.markAsRead(notificationId, user.userId);
    ctx.success<NotificationResponse>(result, '通知已标记为已读');
  }

  static async sendTestNotification(ctx: Context) {
    TaskScheduler.triggerTaskReminders();
    ctx.success(null, '测试通知已发送');
  }
}

