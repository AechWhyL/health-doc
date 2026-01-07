# 咨询协作模块实时事件协议（初版）

本协议定义了咨询协作模块在 WebSocket（Socket.io）上的最小事件集合，用于支持基础的实时问答与消息收发能力。当前版本不包含任何“已读/阅读状态”相关能力。

## 1. 连接与会话

### 1.1 连接建立

- 方向：客户端 → 服务器（Socket.io 默认 `connect`）
- 说明：客户端建立 Socket.io 连接后，由服务器进行身份校验（后续版本可扩展为基于 JWT 的认证）。

### 1.2 断开连接

- 方向：服务器 → 客户端（Socket.io 默认 `disconnect`）
- 说明：客户端断开时，服务器释放相关资源，不做业务广播。

## 2. 会话房间管理

所有与某个咨询问题（question）相关的实时消息，都通过“房间”维度进行隔离。房间命名约定：

- 房间名：`consultation:question:{questionId}`
- 示例：`consultation:question:123`

### 2.1 客户端加入咨询问题房间

- 事件名：`join_question`
- 方向：客户端 → 服务器
- 触发时机：客户端进入咨询详情页或希望订阅某个咨询问题的实时消息时。

请求报文：

```json
{
  "question_id": 123,
  "user_id": 456,
  "user_type": "ELDER",
  "role_display_name": "张三"
}
```

- `question_id`：咨询问题 ID，必填
- `user_id`：当前用户 ID，必填（后续可从鉴权信息中推导）
- `user_type`：用户类型，枚举 `ELDER | FAMILY | STAFF`，必填
- `role_display_name`：角色展示名称，选填，用于前端展示（例如“护士李四”）

成功响应事件：

- 事件名：`joined_question`
- 方向：服务器 → 当前客户端

报文示例：

```json
{
  "question_id": 123
}
```

失败时，服务器通过 `error` 事件返回。

### 2.2 客户端离开咨询问题房间

- 事件名：`leave_question`
- 方向：客户端 → 服务器
- 触发时机：客户端离开咨询详情页或不再需要该会话的实时消息时。

请求报文：

```json
{
  "question_id": 123
}
```

成功响应事件：

- 事件名：`left_question`
- 方向：服务器 → 当前客户端

报文示例：

```json
{
  "question_id": 123
}
```

失败时，服务器通过 `error` 事件返回。

## 3. 消息发送与广播

### 3.1 发送消息（持久化）

- 事件名：`send_message`
- 方向：客户端 → 服务器
- 说明：客户端向指定咨询问题发送一条消息，服务器负责持久化并向房间内所有连接广播。

请求报文：

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

字段约定：

- `question_id`：咨询问题 ID，必填
- `sender_type`：发送方类型，枚举 `ELDER | FAMILY | STAFF | SYSTEM`，必填
- `sender_id`：发送方用户 ID，可选（系统消息可以为空）
- `role_display_name`：角色展示名称，可选
- `content_type`：消息内容类型，枚举 `TEXT | IMAGE | AUDIO | SYSTEM`，必填
- `content_text`：文本内容，`content_type = TEXT` 时必填
- `attachments`：附件列表，可选，结构与 REST 接口的 `ConsultationAttachmentInput` 一致

成功流程：

1. 服务器调用已有的 `ConsultationService.createMessage(questionId, data)` 完成持久化；
2. 将创建成功的消息记录，封装成统一结构，通过 `new_message` 事件广播到对应房间；
3. 同时通过 `send_message:ack` 事件返回给发送方确认结果。

成功确认事件（发送方专用）：

- 事件名：`send_message:ack`
- 方向：服务器 → 当前客户端

示例：

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

失败确认事件：

```json
{
  "success": false,
  "message": "发送失败：咨询问题不存在"
}
```

### 3.2 新消息广播

- 事件名：`new_message`
- 方向：服务器 → 房间内所有客户端（包括发送方自身）
- 触发时机：任意客户端通过 `send_message` 事件发送消息并持久化成功之后。

报文结构与 `send_message:ack.data` 一致，例如：

```json
{
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
```

## 4. 错误处理

### 4.1 统一错误事件

- 事件名：`error`
- 方向：服务器 → 当前客户端
- 说明：用于返回非鉴权类的业务错误（参数错误、业务校验失败等）。

示例：

```json
{
  "code": "INVALID_PAYLOAD",
  "message": "参数不合法",
  "details": {
    "field": "question_id",
    "reason": "question_id 必须为正整数"
  }
}
```

可能的错误码示例：

- `INVALID_PAYLOAD`：参数缺失或格式不正确
- `QUESTION_NOT_FOUND`：咨询问题不存在
- `INTERNAL_ERROR`：服务器内部错误

## 5. 当前版本范围说明

- 本协议仅覆盖：`join_question`、`leave_question`、`send_message`、`joined_question`、`left_question`、`new_message`、`send_message:ack`、`error` 等事件；
- 当前版本显式排除“已读/阅读状态”等相关事件与字段，后续如需扩展，将以新版本协议补充。

