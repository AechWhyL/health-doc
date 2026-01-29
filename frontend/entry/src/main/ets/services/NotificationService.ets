import notificationManager from '@ohos.notificationManager';
import { router } from '@kit.ArkUI';

// 任务项接口定义
interface PendingTaskItem {
  task_id: number;
  item_name: string;
  task_time: string;
}

// 通知数据接口定义
interface IConsultationReplyNotification {
  type: 'CONSULTATION_REPLY';
  question_id: number;
  sender_id: number;
  sender_name: string;
  message_preview: string;
  created_at: string;
}

export class ConsultationReplyNotification implements IConsultationReplyNotification{
  type: 'CONSULTATION_REPLY';
  question_id: number;
  sender_id: number;
  sender_name: string;
  message_preview: string;
  created_at: string;

  constructor(param:string|IConsultationReplyNotification) {
    if(typeof param == "string"){
      const parsed:ConsultationReplyNotification = JSON.parse(param)
      this.type = parsed.type
      this.question_id = parsed.question_id
      this.sender_id = parsed.sender_id
      this.sender_name = parsed.sender_name
      this.message_preview = parsed.message_preview
      this.created_at = parsed.created_at
    }else{
      this.type = param.type
      this.question_id = param.question_id
      this.sender_id = param.sender_id
      this.sender_name = param.sender_name
      this.message_preview = param.message_preview
      this.created_at = param.created_at
    }
  }
}

interface ITaskReminderNotification {
  type: 'TASK_REMINDER';
  task_date: string;
  pending_tasks: PendingTaskItem[];
  message?: string;
  elder_name?: string;
}

export class TaskReminderNotification implements ITaskReminderNotification{
  type: 'TASK_REMINDER';
  task_date: string;
  pending_tasks: PendingTaskItem[];
  message?: string;
  elder_name?: string;

  constructor(param:string | TaskReminderNotification) {
    if(typeof param == "string"){
      const parsed:TaskReminderNotification = JSON.parse(param)
      this.type = parsed.type
      this.task_date = parsed.task_date
      this.pending_tasks = parsed.pending_tasks
      this.message = parsed.message
      this.elder_name = parsed.elder_name
    }else{
      this.type = param.type
      this.task_date = param.task_date
      this.pending_tasks = param.pending_tasks
      this.message = param.message
      this.elder_name = param.elder_name
    }
  }

}

interface ITaskCheckinNotification {
  type: 'TASK_CHECKIN';
  task_id: number;
  elder_name: string;
  item_name: string;
  complete_time: string;
}

export class TaskCheckinNotification implements ITaskCheckinNotification{
  type: 'TASK_CHECKIN';
  task_id: number;
  elder_name: string;
  item_name: string;
  complete_time: string;

  constructor(param:string | ITaskCheckinNotification) {
    if(typeof param == "string"){
      const parsed:ITaskCheckinNotification = JSON.parse(param)
      this.type = parsed.type
      this.task_id = parsed.task_id
      this.elder_name = parsed.elder_name
      this.item_name = parsed.item_name
      this.complete_time = parsed.complete_time
    }else{
      this.type = param.type
      this.task_id = param.task_id
      this.elder_name = param.elder_name
      this.item_name = param.item_name
      this.complete_time = param.complete_time
    }
  }
}

/**
 * 通知服务
 * 封装鸿蒙Notification API，处理系统通知的显示和点击跳转
 */
export class NotificationService {
  private static notificationId = 1000;
  private static hasPermission = false;

  /**
   * 请求通知权限
   */
  static async requestPermission(): Promise<boolean> {
    try {
      // 检查是否已有权限
      const isEnabled = await notificationManager.isNotificationEnabled();
      if (isEnabled) {
        NotificationService.hasPermission = true;
        return true;
      }

      // 请求权限（注意：鸿蒙系统会自动弹出权限请求对话框）
      // 实际权限需要在module.json5中配置
      console.log('[NotificationService] Notification permission not enabled');
      NotificationService.hasPermission = false;
      return false;
    } catch (error) {
      console.error('[NotificationService] Failed to check notification permission:', error);
      NotificationService.hasPermission = false;
      return false;
    }
  }

  /**
   * 显示咨询回复通知
   */
  static async showConsultationReplyNotification(data: ConsultationReplyNotification): Promise<void> {
    if (!NotificationService.hasPermission) {
      await NotificationService.requestPermission();
    }

    try {
      const notificationId = NotificationService.notificationId++;
      
      const notificationRequest: notificationManager.NotificationRequest = {
        id: notificationId,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: `${data.sender_name}回复了您的咨询`,
            text: data.message_preview,
          }
        },
        notificationSlotType:notificationManager.SlotType.SERVICE_INFORMATION
      };

      await notificationManager.publish(notificationRequest);
      console.log('[NotificationService] Consultation reply notification published');
    } catch (error) {
      console.error('[NotificationService] Failed to publish consultation reply notification:', error);
    }
  }

  /**
   * 显示任务提醒通知
   */
  static async showTaskReminderNotification(data: TaskReminderNotification): Promise<void> {
    if (!NotificationService.hasPermission) {
      await NotificationService.requestPermission();
    }

    try {
      const notificationId = NotificationService.notificationId++;
      let normalText = '';

      if (data.message) {
        normalText = data.message;
      } else {
        const taskCount = data.pending_tasks.length;
        const taskNames = data.pending_tasks.slice(0, 3).map((t: PendingTaskItem) => t.item_name).join('、');
        normalText = `您还有${taskCount}个任务未完成：${taskNames}${taskCount > 3 ? '等' : ''}`;
      }
      
      const notificationRequest: notificationManager.NotificationRequest = {
        id: notificationId,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '今日任务提醒',
            text: normalText,
          }
        },
        notificationSlotType:notificationManager.SlotType.SERVICE_INFORMATION
      };

      await notificationManager.publish(notificationRequest);
      console.log('[NotificationService] Task reminder notification published');
    } catch (error) {
      console.error('[NotificationService] Failed to publish task reminder notification:', error);
    }
  }

  /**
   * 显示任务签到通知
   */
  static async showTaskCheckinNotification(data: TaskCheckinNotification): Promise<void> {
    if (!NotificationService.hasPermission) {
      await NotificationService.requestPermission();
    }

    try {
      const notificationId = NotificationService.notificationId++;
      
      const notificationRequest: notificationManager.NotificationRequest = {
        id: notificationId,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '任务签到通知',
            text: `${data.elder_name}完成了任务：${data.item_name}`,
          }
        },
        notificationSlotType:notificationManager.SlotType.SERVICE_INFORMATION
      };

      await notificationManager.publish(notificationRequest);
      console.log('[NotificationService] Task checkin notification published');
    } catch (error) {
      console.error('[NotificationService] Failed to publish task checkin notification:', error);
    }
  }

  /**
   * 处理通知点击事件
   * 注意：此方法需要在应用启动时注册
   */
  static handleNotificationClick(type: string, data: Record<string, string>): void {
    console.log('[NotificationService] Notification clicked:', type, data);

    switch (type) {
      case 'CONSULTATION_REPLY':
        // 跳转到咨询聊天页面
        if (data.question_id) {
          router.pushUrl({
            url: 'pages/common/ChatPage',
            params: {
              questionId: parseInt(data.question_id)
            }
          }).catch((error: Error) => {
            console.error('[NotificationService] Failed to navigate to chat page:', error);
          });
        }
        break;

      case 'TASK_REMINDER':
        // 跳转到任务列表页面（根据用户角色跳转到对应的首页）
        const userType = AppStorage.get<string>('userType');
        if (userType === 'ELDER') {
          router.pushUrl({
            url: 'pages/elder/ElderMainPage'
          }).catch((error: Error) => {
            console.error('[NotificationService] Failed to navigate to elder main page:', error);
          });
        } else if (userType === 'FAMILY') {
          router.pushUrl({
            url: 'pages/family/FamilyMainPage'
          }).catch((error: Error) => {
            console.error('[NotificationService] Failed to navigate to family main page:', error);
          });
        }
        break;

      case 'TASK_CHECKIN':
        // 跳转到干预计划页面
        router.pushUrl({
          url: 'pages/medical/intervention/InterventionIndex'
        }).catch((error: Error) => {
          console.error('[NotificationService] Failed to navigate to intervention page:', error);
        });
        break;

      default:
        console.warn('[NotificationService] Unknown notification type:', type);
    }
  }
}

// 导出接口供外部使用
export type { IConsultationReplyNotification, ITaskReminderNotification, ITaskCheckinNotification, PendingTaskItem };