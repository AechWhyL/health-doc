# 通用提醒任务模块使用说明（后端骨架）

本说明文档用于指导后续模块（以及 AI）如何在项目后端复用“通用提醒任务”能力，生成跨业务的定时提醒任务。

---

## 1. 模块位置概览

- 类型定义：
  - [backend/src/types/reminder.ts](file:///c:/Users/29339/projects/health-doc/backend/src/types/reminder.ts)
- 仓储层：
  - [backend/src/repositories/reminderTask.repository.ts](file:///c:/Users/29339/projects/health-doc/backend/src/repositories/reminderTask.repository.ts)
- 服务层：
  - [backend/src/services/reminderTask.service.ts](file:///c:/Users/29339/projects/health-doc/backend/src/services/reminderTask.service.ts)

业务模块在生成提醒任务时，应统一调用 ReminderTaskService，不要直接依赖仓储层。

---

## 2. 核心实体与枚举

文件： [reminder.ts](file:///c:/Users/29339/projects/health-doc/backend/src/types/reminder.ts)

```ts
export type ReminderChannel = 'IN_APP' | 'SYSTEM_MESSAGE' | 'SMS' | 'PUSH';

export type ReminderStatus = 'PENDING' | 'SENT' | 'CANCELLED' | 'FAILED';

export interface ReminderTaskRecord {
  id?: number;
  biz_type: string;
  biz_id: number;
  target_user_id: number;
  channel: ReminderChannel;
  title: string;
  content: string;
  remind_at: string;
  status: ReminderStatus;
  created_at?: string;
  updated_at?: string;
}
```

字段说明（简要）：

- biz_type：业务类型标识，例如 HEALTH_DATA, INTERVENTION_PLAN, FOLLOW_UP 等，用于区分不同业务来源。
- biz_id：业务主键，例如某条健康数据记录、干预计划或任务的 ID。
- target_user_id：提醒的目标用户 ID（统一用用户维度，不再单独使用 target_elder_id）。
- channel：提醒渠道，当前主要使用 IN_APP，其他渠道后续可扩展。
- title / content：提醒标题与内容，用于展示给用户。
- remind_at：提醒任务预定触发时间（字符串，格式形如 YYYY-MM-DD HH:mm:ss）。
- status：任务当前状态：
  - PENDING：待触发
  - SENT：已触发（已生成对应通知）
  - CANCELLED：已取消
  - FAILED：执行失败（可用于后续重试策略）

---

## 3. 仓储层：ReminderTaskRepository

文件： [reminderTask.repository.ts](file:///c:/Users/29339/projects/health-doc/backend/src/repositories/reminderTask.repository.ts)

只列出关键方法签名，业务层一般不直接调用仓储，而是通过服务层间接使用：

```ts
export class ReminderTaskRepository {
  static async create(
    data: Omit<ReminderTaskRecord, 'id' | 'created_at' | 'updated_at'>
  ): Promise<number>;

  static async findById(id: number): Promise<ReminderTaskRecord | null>;

  static async findDueTasks(now: string, limit: number): Promise<ReminderTaskRecord[]>;

  static async updateStatus(id: number, status: ReminderStatus): Promise<void>;
}
```

使用要点：

- create：插入一条提醒任务记录，返回自增 ID。
- findById：根据 ID 查询单条任务。
- findDueTasks：查询到期且 status = 'PENDING' 的任务，供调度器或服务层批量处理。
- updateStatus：更新任务状态，并刷新 updated_at。

---

## 4. 服务层：ReminderTaskService 使用方法

文件： [reminderTask.service.ts](file:///c:/Users/29339/projects/health-doc/backend/src/services/reminderTask.service.ts)

这是业务模块应当直接使用的入口。

### 4.1 创建提醒任务

接口定义：

```ts
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
  static async createReminderTask(input: CreateReminderTaskInput): Promise<ReminderTaskRecord>;
}
```

典型调用场景：

- 健康数据模块在检测到“持续高血压风险”时，为老人对应的用户创建一条就医提醒任务。
- 干预计划模块在生成某个用药计划或康复任务时，为相关用户创建后续随访提醒任务。

示例伪代码（业务 Service 内部）：

```ts
await ReminderTaskService.createReminderTask({
  biz_type: 'HEALTH_DATA',
  biz_id: healthRecordId,
  target_user_id: targetUserId,
  title: '持续高血压提醒',
  content: '最近一周血压多次偏高，建议尽快就医复查',
  remind_at: '2025-01-15 09:00:00'
});
```

约定：

- 默认渠道为 IN_APP，如果不传 channel，会自动填充为 IN_APP。
- 创建成功后，方法会再查一次数据库返回完整的 ReminderTaskRecord。

### 4.2 取消提醒任务

接口：

```ts
static async cancelReminderTask(id: number): Promise<void>;
```

行为约定：

- 若任务不存在：静默返回，不抛异常。
- 若任务状态不是 PENDING（例如已发送、已取消等）：静默返回，不修改状态。
- 若任务处于 PENDING：更新为 CANCELLED。

典型使用场景：

- 对应业务被删除或状态变化（例如干预计划被终止），需要撤销后续尚未触发的提醒任务。

### 4.3 处理到期提醒任务（调度入口）

接口：

```ts
static async processDueReminderTasks(limit: number = 100): Promise<void>;
``>

内部逻辑概览：

1. 计算当前时间 now，格式与数据库 remind_at 匹配（YYYY-MM-DD HH:mm:ss）。
2. 调用 ReminderTaskRepository.findDueTasks(now, limit) 查出到期的 PENDING 任务。
3. 对每个任务调用内部方法 dispatchReminder(task) 执行实际提醒行为。
4. 若执行成功，更新任务状态为 SENT；若失败，更新为 FAILED。

调度方式（由外部控制）：

- 可以由独立调度脚本或进程（如 node-cron、操作系统定时任务）定期调用此方法。
- 也可以在应用启动后，用定时器周期性调用（生产环境要考虑多实例冲突问题）。
- 当前项目中未固定具体调用位置，保留为一个“调度骨架入口”，以便后续按部署方案选择最合适的调度方式。

### 4.4 渠道分发与 IN_APP 行为（当前骨架）

在 ReminderTaskService 内部，预留了渠道分发与 IN_APP 分发的骨架：

```ts
private static async dispatchReminder(task: ReminderTaskRecord): Promise<void> {
  if (task.channel === 'IN_APP' || task.channel === 'SYSTEM_MESSAGE') {
    await this.dispatchInAppReminder(task);
    return;
  }
}

private static async dispatchInAppReminder(task: ReminderTaskRecord): Promise<void> {
  return;
}
```

当前行为：

- dispatchInAppReminder 仍然是空实现，仅作为占位。
- 通用提醒模块负责“什么时候触发提醒任务”（即从 PENDING 到达执行时机），而真正的“IN_APP 消息落库与推送到客户端”的逻辑，将在后续的通知或消息模块中实现。

未来扩展方向（建议）：

- 在 dispatchInAppReminder 中：
  1. 将提醒任务转换为一条持久化的用户通知记录（例如写入 user_notification 表）。
  2. 通过现有的 Socket.io 通道向在线客户端推送（例如发送 notification:new 事件）。
  3. 无论客户端是否在线，只要成功写入通知表，就将任务状态更新为 SENT。

---

## 5. 业务模块使用约定总结

1. 生成提醒任务：
   - 所有业务模块如果需要将来某个时间对用户发出提醒，应统一调用：
     - ReminderTaskService.createReminderTask(...)。
   - 需要明确：
     - biz_type / biz_id：用于追踪来源业务（可选）。
     - target_user_id：目标用户。
     - title / content：给用户看的提醒内容。
     - remind_at：预定时间。

2. 取消提醒任务：
   - 当业务本身被取消或失效时，应调用：
     - ReminderTaskService.cancelReminderTask(taskId)。

3. 提醒任务执行调度：
   - 由系统统一调度逻辑周期性调用：
     - ReminderTaskService.processDueReminderTasks(limit)。
   - 调度机制可以是：内部定时器、独立进程、或外部定时调用 API，取决于部署方式。

4. IN_APP 渠道实现：
   - 当前仅预留骨架，不直接推送到客户端。
   - 后续在通知模块中完善：
     - 持久化通知记录。
     - 利用 Socket.io 或其他通道实现实时推送。

通过以上约定，提醒任务模块可以作为一个跨业务的基础能力被复用，而不会与单一业务耦合。

