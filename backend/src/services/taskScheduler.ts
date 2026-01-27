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
            // 联表查询老人姓名
            const sql = `
        SELECT 
          ip.elder_user_id as user_id,
          ebi.name as elder_name,
          pti.id as task_id,
          pi.name as item_name,
          pti.task_time
        FROM plan_task_instance pti
        JOIN plan_item pi ON pti.item_id = pi.id
        JOIN intervention_plan ip ON pi.plan_id = ip.id
        LEFT JOIN elder_basic_info ebi ON ip.elder_user_id = ebi.user_id
        WHERE pti.task_date = ?
          AND pti.status = 'PENDING'
          AND ip.status = 'ACTIVE'
        ORDER BY ip.elder_user_id, pti.task_time
      `;

            const tasks = await Database.query<{
                user_id: number;
                elder_name: string | null;
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
                {
                    elderName: string;
                    tasks: Array<{ task_id: number; item_name: string; task_time: string }>
                }
            >();

            for (const task of tasks) {
                if (!tasksByUser.has(task.user_id)) {
                    tasksByUser.set(task.user_id, {
                        elderName: task.elder_name || '未命名老人',
                        tasks: []
                    });
                }
                tasksByUser.get(task.user_id)!.tasks.push({
                    task_id: task.task_id,
                    item_name: task.item_name,
                    task_time: task.task_time || '未设置时间'
                });
            }

            // 为每个用户推送通知
            let notificationCount = 0;
            const { ElderUserRelationRepository } = require('../repositories/elderUserRelation.repository');

            for (const [userId, { elderName, tasks: pendingTasks }] of tasksByUser.entries()) {
                try {
                    // 1. 给老人发送详情提醒
                    const taskNames = pendingTasks.map(t => t.item_name).join('、');
                    const elderMsg = `温馨提醒：您今天还有 ${pendingTasks.length} 项计划任务未完成：${taskNames}，请记得按时打卡哦。`;

                    emitTaskReminderNotification(userId, today, pendingTasks, elderMsg, elderName);
                    notificationCount++;

                    // 2. 给关联用户发送概览提醒
                    try {
                        const associateIds = await ElderUserRelationRepository.findAllByElderUserId(userId);
                        if (associateIds && associateIds.length > 0) {
                            const associateMsg = `提醒：您关联的老人 ${elderName} 今天还有 ${pendingTasks.length} 项任务未完成，请关注。`;

                            for (const associateId of associateIds) {
                                emitTaskReminderNotification(associateId, today, pendingTasks, associateMsg, elderName);
                                notificationCount++;
                            }
                        }
                    } catch (assocError) {
                        console.error(
                            `[TaskScheduler] Failed to send reminder to associates of elder ${userId}:`,
                            assocError
                        );
                    }

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
