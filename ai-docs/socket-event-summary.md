# Socket 实时事件总览

本文件汇总当前后端中使用的所有 Socket.io 事件，包括咨询协作模块与通用通知推送模块，方便前后端对齐协议。

## 1. 基础连接事件

- 事件名：`connect`
  - 方向：客户端 → 服务器（Socket.io 内置）
  - 说明：客户端建立 Socket.io 连接，当前版本未做额外鉴权扩展。

- 事件名：`disconnect`
  - 方向：服务器 → 客户端（Socket.io 内置）
  - 说明：连接断开时触发，后端仅做资源释放，不做业务广播。

## 2. 咨询会话相关事件

房间命名约定：`consultation:question:{questionId}`，例如：`consultation:question:123`。

### 2.1 加入咨询问题房间

- 事件名：`join_question`
  - 方向：客户端 → 服务器
  - 用途：订阅某个咨询问题的实时消息。
  - 请求数据：
    ```json
    {
      "question_id": 123,
      "user_id": 456,
      "user_type": "ELDER",
      "role_display_name": "张三"
    }
    ```

- 事件名：`joined_question`
  - 方向：服务器 → 当前客户端
  - 用途：确认已成功加入房间。
  - 响应数据：
    ```json
    {
      "question_id": 123
    }
    ```

### 2.2 离开咨询问题房间

- 事件名：`leave_question`
  - 方向：客户端 → 服务器
  - 用途：取消订阅某个咨询问题的实时消息。
  - 请求数据：
    ```json
    {
      "question_id": 123
    }
    ```

- 事件名：`left_question`
  - 方向：服务器 → 当前客户端
  - 用途：确认已成功离开房间。
  - 响应数据：
    ```json
    {
      "question_id": 123
    }
    ```

### 2.3 咨询消息发送与广播

- 事件名：`send_message`
  - 方向：客户端 → 服务器
  - 用途：向指定咨询问题发送消息并持久化。
  - 请求数据（核心字段）：
    ```json
    {
      "question_id": 123,
      "sender_type": "STAFF",
      "sender_id": 456,
      "role_display_name": "医生王五",
      "content_type": "TEXT",
      "content_text": "您好，请详细描述一下您的症状",
      "attachments": [
        {
          "url": "https://example.com/image1.png",
          "thumbnail_url": "https://example.com/thumb1.png",
          "duration": null,
          "size": 102400
        }
      ]
    }
    ```

- 事件名：`send_message:ack`
  - 方向：服务器 → 当前客户端
  - 用途：返回发送结果（成功或失败）。
  - 成功示例：
    ```json
    {
      "success": true,
      "message": "发送成功",
      "data": {
        "id": 789,
        "question_id": 123,
        "sender_type": "STAFF",
        "sender_id": 456,
        "role_display_name": "医生王五",
        "content_type": "TEXT",
        "content_text": "您好，请详细描述一下您的症状",
        "sent_at": "2025-01-01 10:00:00",
        "status": "SENT",
        "is_visible_to_patient": true,
        "attachments": [
          {
            "url": "https://example.com/image1.png",
            "thumbnail_url": "https://example.com/thumb1.png",
            "duration": null,
            "size": 102400
          }
        ]
      }
    }
    ```

  - 失败示例：
    ```json
    {
      "success": false,
      "message": "发送失败：question_id 必须为正整数"
    }
    ```

- 事件名：`new_message`
  - 方向：服务器 → 房间内所有客户端
  - 用途：向所在咨询房间广播新消息。
  - 数据结构与 `send_message:ack.data` 一致。

## 3. 通用错误事件

- 事件名：`error`
  - 方向：服务器 → 当前客户端
  - 用途：返回参数错误、业务异常等非鉴权错误。
  - 示例：
    ```json
    {
      "code": "INVALID_PAYLOAD",
      "message": "question_id 必须为正整数"
    }
    ```

常见错误码：

- `INVALID_PAYLOAD`：参数缺失或格式不正确
- `QUESTION_NOT_FOUND`：咨询问题不存在
- `INTERNAL_ERROR`：服务器内部错误

## 4. 用户绑定与通知推送事件

用户级通知通过“用户房间”进行广播，房间命名约定：`user:{userId}`，例如：`user:1001`。

### 4.1 绑定用户到 Socket 会话

- 事件名：`bind_user`
  - 方向：客户端 → 服务器
  - 用途：将当前 Socket 连接绑定到指定用户房间，用于接收该用户的通知推送。
  - 请求数据：
    ```json
    {
      "user_id": 1001
    }
    ```

  - 校验规则：
    - `user_id` 必须为正整数，否则通过 `error` 事件返回：
      ```json
      {
        "code": "INVALID_PAYLOAD",
        "message": "user_id 必须为正整数"
      }
      ```

- 事件名：`bind_user:ack`
  - 方向：服务器 → 当前客户端
  - 用途：确认绑定结果。
  - 响应数据：
    ```json
    {
      "success": true,
      "user_id": 1001
    }
    ```

### 4.2 实时通知推送

当提醒任务（IN_APP 或 SYSTEM_MESSAGE 渠道）到期后，后端会创建一条用户通知记录，并尝试通过 Socket 将该通知推送到对应用户房间。

- 事件名：`notification:new`
  - 方向：服务器 → 用户房间内所有客户端（通常是同一用户的多个终端）
  - 触发来源：`ReminderTaskService.dispatchInAppReminder` 中在写入 `user_notification` 后，通过 `emitNotificationToUser` 进行广播。
  - 广播房间：`user:{user_id}`
  - 数据结构（与 `user_notification` 表结构对齐的子集）：
    ```json
    {
      "id": 1,
      "biz_type": "INTERVENTION_TASK",
      "biz_id": 12345,
      "title": "服药提醒",
      "content": "请在 20:00 前完成今日降压药服用",
      "status": "UNREAD",
      "created_at": "2025-01-01 10:00:00",
      "read_at": null
    }
    ```

- 事件名：`notification:consultation_reply`
  - 方向：服务器 → 咨询房间内所有客户端
  - 用途：当有新咨询回复时，向房间内其他用户推送系统通知
  - 数据结构：
    ```json
    {
      "type": "CONSULTATION_REPLY",
      "question_id": 123,
      "sender_id": 456,
      "sender_name": "张三",
      "message_preview": "你好...",
      "created_at": "2026-01-26T16:00:00.000Z"
    }
    ```

- 事件名：`notification:task_reminder`
  - 方向：服务器 → 用户房间内所有客户端
  - 用途：每日定时（如晚上8点）推送未完成任务提醒
  - 数据结构：
    ```json
    {
      "type": "TASK_REMINDER",
      "task_date": "2026-01-26",
      "pending_tasks": [
        {
          "task_id": 1,
          "item_name": "喝水",
          "task_time": "10:00"
        }
      ]
    }
    ```

- 事件名：`notification:task_checkin`
  - 方向：服务器 → 医护人员用户房间
  - 用途：当老人/家属完成任务签到时，通知关联的医护人员
  - 数据结构：
    ```json
    {
      "type": "TASK_CHECKIN",
      "task_id": 1,
      "elder_name": "王五",
      "item_name": "散步",
      "complete_time": "2026-01-26T16:00:00.000Z"
    }
    ```

## 5. 测试专用事件（仅调试环境可用）

以下事件仅用于开发和测试阶段方便 Postman 触发通知推送，生产环境不建议依赖。

- 事件名：`test:push_consultation_reply`
  - 方向：客户端 → 服务器
  - 用途：模拟推送咨询回复通知（触发 `notification:consultation_reply`）
  - 请求数据：
    ```json
    {
      "question_id": 123,           // 必填，推送到哪个咨询房间
      "sender_id": 999,             // 可选
      "sender_name": "测试医生",    // 可选
      "message_preview": "测试回复" // 可选
    }
    ```

- 事件名：`test:push_task_reminder`
  - 方向：客户端 → 服务器
  - 用途：模拟推送任务提醒通知（触发 `notification:task_reminder`）
  - 请求数据：
    ```json
    {
      "user_id": 1001,              // 必填，推送到哪个用户
      "task_date": "2026-01-26",    // 可选
      "pending_tasks": [            // 可选
        { "task_id": 1, "item_name": "测试任务A", "task_time": "10:00" }
      ]
    }
    ```

- 事件名：`test:push_task_checkin`
  - 方向：客户端 → 服务器
  - 用途：模拟推送任务签到通知（触发 `notification:task_checkin`）
  - 请求数据：
    ```json
    {
      "medical_staff_id": 2001,     // 必填，推送到哪个医护人员
      "task_id": 501,               // 可选
      "elder_name": "张大爷",       // 可选
      "item_name": "晨练"           // 可选
    }
    ```

## 6. 当前事件清单一览

按事件名归类如下：

- 客户端 → 服务器：
  - `join_question`
  - `leave_question`
  - `send_message`
  - `bind_user`
  - `test:push_consultation_reply`
  - `test:push_task_reminder`
  - `test:push_task_checkin`

- 服务器 → 客户端：
  - `joined_question`
  - `left_question`
  - `send_message:ack`
  - `new_message`
  - `notification:new`
  - `notification:consultation_reply`
  - `notification:task_reminder`
  - `notification:task_checkin`
  - `bind_user:ack`
  - `error`

后续如有新增事件，应在本文件中补充信息，保持前后端协议的一致性。

