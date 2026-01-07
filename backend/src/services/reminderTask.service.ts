import { ReminderTaskRepository } from '../repositories/reminderTask.repository';
import { ReminderChannel, ReminderTaskRecord } from '../types/reminder';
import { NotificationRepository } from '../repositories/notification.repository';
import { UserNotificationRecord } from '../types/notification';
import { emitNotificationToUser } from '../realtime/socket';

export interface CreateReminderTaskInput {
  biz_type: string;
  biz_id: number;
  target_user_id: number;
  channel?: ReminderChannel;
  title: string;
  content: string;
  remind_at: string;
}

export class ReminderTaskService {
  static async createReminderTask(input: CreateReminderTaskInput): Promise<ReminderTaskRecord> {
    const data: Omit<ReminderTaskRecord, 'id' | 'created_at' | 'updated_at'> = {
      biz_type: input.biz_type,
      biz_id: input.biz_id,
      target_user_id: input.target_user_id,
      channel: input.channel || 'IN_APP',
      title: input.title,
      content: input.content,
      remind_at: input.remind_at,
      status: 'PENDING'
    };

    const id = await ReminderTaskRepository.create(data);
    const created = await ReminderTaskRepository.findById(id);
    if (!created) {
      throw new Error('创建提醒任务失败');
    }

    return created;
  }

  static async getReminderTaskById(id: number): Promise<ReminderTaskRecord | null> {
    return await ReminderTaskRepository.findById(id);
  }

  static async cancelReminderTask(id: number): Promise<void> {
    const task = await ReminderTaskRepository.findById(id);
    if (!task) {
      return;
    }
    if (task.status !== 'PENDING') {
      return;
    }
    await ReminderTaskRepository.updateStatus(id, 'CANCELLED');
  }

  static async processDueReminderTasks(limit: number = 100): Promise<void> {
    const now = new Date().toISOString().slice(0, 19).replace('T', ' ');
    const tasks = await ReminderTaskRepository.findDueTasks(now, limit);

    for (const task of tasks) {
      try {
        await this.dispatchReminder(task);
        await ReminderTaskRepository.updateStatus(task.id!, 'SENT');
      } catch {
        await ReminderTaskRepository.updateStatus(task.id!, 'FAILED');
      }
    }
  }

  private static async dispatchReminder(task: ReminderTaskRecord): Promise<void> {
    if (task.channel === 'IN_APP' || task.channel === 'SYSTEM_MESSAGE') {
      await this.dispatchInAppReminder(task);
      return;
    }
  }

  private static async dispatchInAppReminder(task: ReminderTaskRecord): Promise<void> {
    const notification: Omit<UserNotificationRecord, 'id' | 'created_at' | 'read_at'> = {
      user_id: task.target_user_id,
      biz_type: task.biz_type,
      biz_id: task.biz_id,
      title: task.title,
      content: task.content,
      status: 'UNREAD'
    };

    const id = await NotificationRepository.create(notification);
    const created = await NotificationRepository.findById(id);

    if (created && created.id) {
      emitNotificationToUser(created.user_id, {
        id: created.id,
        biz_type: created.biz_type,
        biz_id: created.biz_id,
        title: created.title,
        content: created.content,
        status: created.status,
        created_at: created.created_at || '',
        read_at: created.read_at ?? null
      });
    }
  }
}
