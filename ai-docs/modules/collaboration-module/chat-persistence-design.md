# 聊天持久层模块实体与表结构设计归档

本文档归档当前毕业设计项目中“咨询/类聊天”功能的持久层实体设计与数据库表结构，以支持后续 REST API 与 WebSocket 实时聊天的实现。

---

## 一、设计目标与范围

- 为“老人/家属向医护人员发起咨询”的业务场景提供持久化存储。
- 支撑一个“类聊天界面”的交互体验：
  - 一个“咨询问题”对应一条咨询会话；
  - 会话下挂一组按时间排序的聊天消息；
  - 消息可带图片/语音等附件。
- 当前范围聚焦：
  - 咨询问题（ConsultationQuestion）
  - 聊天消息（ConsultationMessage）
  - 消息附件（ConsultationAttachment）
- 暂不实现：
  - 咨询反馈/满意度评价表
  - 已读游标（ReadReceipt）表
  - 参与者表（ConsultationParticipant）

---

## 二、领域实体概览

### 1. 咨询问题 ConsultationQuestion

作为咨询功能的核心实体，对应一条“咨询单/会话”。

关键字段含义：
- id：主键
- code：对外展示的咨询编号（如 CQ{timestamp}）
- title：咨询标题
- description：创建时的初始问题描述
- creator_type：创建人类型（ELDER/FAMILY/STAFF）
- creator_id：创建人 ID
- target_org_id：目标机构/科室/养老机构 ID，可为空
- category：问题分类（如“用药”“康复”“护理”等）
- status：状态（PENDING/IN_PROGRESS/RESOLVED/CLOSED）
- priority：优先级（NORMAL/URGENT）
- is_anonymous：是否对医护端隐藏真实身份
- created_at / updated_at：创建/更新时间
- resolved_at / closed_at：被解决/关闭的时间

### 2. 咨询消息 ConsultationMessage

支撑“类聊天界面”的消息记录。

关键字段含义：
- id：主键
- question_id：所属咨询问题 ID（外键）
- sender_type：发送方类型（ELDER/FAMILY/STAFF/SYSTEM）
- sender_id：发送方用户 ID，可为空（系统消息时）
- role_display_name：发送方在本次会话中的展示名称（如“张三医生”）
- content_type：消息类型（TEXT/IMAGE/AUDIO/SYSTEM）
- content_text：消息文本内容
- sent_at：发送时间
- status：消息状态（SENT/DELIVERED/READ/FAILED，目前主要用 SENT）
- is_visible_to_patient：是否对老人/家属可见
- created_at：创建时间

与前端聊天 UI 的对应关系：
- 一条 ConsultationMessage → 聊天界面中的一个气泡；
- 可通过 content_type 判断渲染文本、图片、语音等不同表现形式。

### 3. 消息附件 ConsultationAttachment

存储与单条消息相关联的多媒体信息。

关键字段含义：
- id：主键
- message_id：所属消息 ID（外键）
- url：文件访问地址
- thumbnail_url：缩略图地址（图片/视频）
- duration：音视频时长（秒）
- size：文件大小（字节）
- created_at：创建时间

设计约定：
- 不单独存储 file_type，类型由前端或服务端通过 URL 后缀/MIME 推断。

---

## 三、数据库表结构设计

以下为已在当前数据库中创建的三张核心表结构摘要，完整 DDL 已通过 MCP 工具执行。

### 1. consultation_question 表

核心字段与索引：
- 主键：
  - id BIGINT UNSIGNED AUTO_INCREMENT
- 业务字段：
  - code VARCHAR(50) UNIQUE
  - title VARCHAR(200) NOT NULL
  - description TEXT NULL
  - creator_type ENUM('ELDER','FAMILY','STAFF') NOT NULL
  - creator_id BIGINT UNSIGNED NOT NULL
  - target_org_id BIGINT UNSIGNED NULL
  - category VARCHAR(100) NULL
  - status ENUM('PENDING','IN_PROGRESS','RESOLVED','CLOSED') NOT NULL DEFAULT 'PENDING'
  - priority ENUM('NORMAL','URGENT') NOT NULL DEFAULT 'NORMAL'
  - is_anonymous TINYINT(1) NOT NULL DEFAULT 0
  - created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
  - updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
  - resolved_at DATETIME NULL
  - closed_at DATETIME NULL
- 索引：
  - uk_consultation_question_code (code)
  - idx_consultation_question_creator (creator_type, creator_id, created_at)
  - idx_consultation_question_status (status, created_at)
  - idx_consultation_question_org (target_org_id, created_at)
  - idx_consultation_question_category (category, created_at)

用途和查询场景：
- 按创建人查询其所有咨询记录；
- 按状态（PENDING/IN_PROGRESS 等）查询医护待处理列表；
- 按机构/科室维度做统计或筛选。

### 2. consultation_message 表

核心字段与索引：
- 主键：
  - id BIGINT UNSIGNED AUTO_INCREMENT
- 业务字段：
  - question_id BIGINT UNSIGNED NOT NULL
  - sender_type ENUM('ELDER','FAMILY','STAFF','SYSTEM') NOT NULL
  - sender_id BIGINT UNSIGNED NULL
  - role_display_name VARCHAR(100) NULL
  - content_type ENUM('TEXT','IMAGE','AUDIO','SYSTEM') NOT NULL
  - content_text TEXT NULL
  - sent_at DATETIME NOT NULL
  - status ENUM('SENT','DELIVERED','READ','FAILED') NOT NULL DEFAULT 'SENT'
  - is_visible_to_patient TINYINT(1) NOT NULL DEFAULT 1
  - created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
- 外键：
  - question_id → consultation_question.id ON DELETE CASCADE
- 索引：
  - idx_consultation_message_question (question_id, sent_at, id)
  - idx_consultation_message_sender (sender_type, sender_id, sent_at)

用途和查询场景：
- 按 question_id + sent_at 升序分页拉取聊天记录；
- 按发送方统计其发送消息数量（例如医护工作量分析）。

### 3. consultation_attachment 表

核心字段与索引：
- 主键：
  - id BIGINT UNSIGNED AUTO_INCREMENT
- 业务字段：
  - message_id BIGINT UNSIGNED NOT NULL
  - url VARCHAR(500) NOT NULL
  - thumbnail_url VARCHAR(500) NULL
  - duration INT UNSIGNED NULL
  - size BIGINT UNSIGNED NULL
  - created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
- 外键：
  - message_id → consultation_message.id ON DELETE CASCADE
- 索引：
  - idx_consultation_attachment_message (message_id)

用途和查询场景：
- 打开聊天记录时按 message_id 查询所有附件；
- 根据 URL 后缀推断图片/音视频类型，在前端做对应展示。

---

## 四、与后端代码结构的对应关系

持久层设计已经在后端代码中落地，主要对应以下文件：

- 类型定义：
  - backend/src/types/consultation.ts
- 仓储层 Repository：
  - backend/src/repositories/consultationQuestion.repository.ts
  - backend/src/repositories/consultationMessage.repository.ts
  - backend/src/repositories/consultationAttachment.repository.ts
- DTO 与校验：
  - backend/src/dto/requests/consultation.dto.ts
- 服务层 Service：
  - backend/src/services/consultation.service.ts
- 控制器与路由：
  - backend/src/controllers/consultation.controller.ts
  - backend/src/routes/consultation.routes.ts

REST API 路由前缀为：
- /api/v1/consultation/questions
- /api/v1/consultation/questions/:id
- /api/v1/consultation/questions/:id/messages

这些接口在逻辑上就是对上述三张表的标准 CRUD/查询封装。

---

## 五、后续可扩展方向（未实现，仅作为设计预留）

1. 咨询参与者表 ConsultationParticipant
   - 记录每条咨询中参与的老人/家属/医护人员；
   - 支持多医护协同、一条咨询多次转接等复杂场景。

2. 已读游标表 ConsultationReadReceipt
   - 按“每个用户在每个咨询中读到哪条消息”为粒度记录已读状态；
   - 支撑未读数统计和“对方已读”提示。

3. 咨询反馈表 ConsultationFeedback
   - 关联 consultation_question，实现“服务反馈与沟通管理”的闭环评价。

这些扩展将与现有三张核心表形成补充关系，但不会破坏当前已实现的咨询/聊天基本能力。

