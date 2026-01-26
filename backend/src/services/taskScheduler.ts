import cron from 'node-cron';
import dayjs from 'dayjs';
import { Database } from '../config/database';
import { emitTaskReminderNotification } from '../realtime/socket';

/**
 * 定时任务调度器
 * 负责每日任务提醒等定时任务
 */
export class TaskScheduler {
    private static isInitialized = false;

    /**
     * 初始化定时任务
     */
    static init(): void {
        if (this.isInitialized) {
            console.log('[TaskScheduler] Already initialized');
            return;
        }

        // 每日晚上8点执行任务提醒
        cron.schedule('0 20 * * *', async () => {
            console.log('[TaskScheduler] Running daily task reminder at 20:00');
            await this.sendDailyTaskReminders();
        });

        this.isInitialized = true;
        console.log('[TaskScheduler] Initialized successfully');
    }

    /**
     * 发送每日任务提醒
     * 查询所有有未完成任务的用户，并推送提醒通知
     */
    private static async sendDailyTaskReminders(): Promise<void> {
        try {
            const today = dayjs().format('YYYY-MM-DD');

            // 查询今天所有未完成的任务，按用户分组
            const sql = `
        SELECT 
          ip.elder_user_id as user_id,
          pti.id as task_id,
          pi.name as item_name,
          pti.task_time
        FROM plan_task_instance pti
        JOIN plan_item pi ON pti.item_id = pi.id
        JOIN intervention_plan ip ON pi.plan_id = ip.id
        WHERE pti.task_date = ?
          AND pti.status = 'PENDING'
          AND ip.status = 'ACTIVE'
        ORDER BY ip.elder_user_id, pti.task_time
      `;

            const tasks = await Database.query<{
                user_id: number;
                task_id: number;
                item_name: string;
                task_time: string | null;
            }>(sql, [today]);

            if (tasks.length === 0) {
                console.log('[TaskScheduler] No pending tasks found for today');
                return;
            }

            // 按用户分组
            const tasksByUser = new Map<
                number,
                Array<{ task_id: number; item_name: string; task_time: string }>
            >();

            for (const task of tasks) {
                if (!tasksByUser.has(task.user_id)) {
                    tasksByUser.set(task.user_id, []);
                }
                tasksByUser.get(task.user_id)!.push({
                    task_id: task.task_id,
                    item_name: task.item_name,
                    task_time: task.task_time || '未设置时间'
                });
            }

            // 为每个用户推送通知
            let notificationCount = 0;
            for (const [userId, pendingTasks] of tasksByUser.entries()) {
                try {
                    emitTaskReminderNotification(userId, today, pendingTasks);
                    notificationCount++;
                } catch (error) {
                    console.error(
                        `[TaskScheduler] Failed to send reminder to user ${userId}:`,
                        error
                    );
                }
            }

            console.log(
                `[TaskScheduler] Sent ${notificationCount} task reminders for ${tasks.length} pending tasks`
            );
        } catch (error) {
            console.error('[TaskScheduler] Error in sendDailyTaskReminders:', error);
        }
    }

    /**
     * 手动触发任务提醒（用于测试）
     */
    static async triggerTaskReminders(): Promise<void> {
        console.log('[TaskScheduler] Manually triggering task reminders');
        await this.sendDailyTaskReminders();
    }
}
