# 健康干预与计划管理模块 - API 列表（简化版）

本模块围绕“健康干预计划”的全流程，先落地 **干预计划管理相关 API**，后续在此基础上扩展计划项、日程、任务实例和执行记录等能力。

当前计划落地的后端 API 主要包括以下几类：

## 一、干预计划管理（HealthInterventionPlan）

- `POST /api/v1/intervention/plans`
  - 功能：创建健康干预计划
  - 典型用例：医护人员为某位老人创建一个新的干预计划
  - 关键字段：
    - `elderUserId`：老人对应的用户ID
    - `title`：计划标题（如“2025年1月血压管理干预计划”）
    - `description`：计划整体说明
    - `startDate` / `endDate`：计划起止日期
    - `createdByUserId`：制定人用户ID（医护人员）

- `GET /api/v1/intervention/plans/{planId}`
  - 功能：获取单个干预计划详情
  - 典型用例：医护端或老人端查看某个计划的详细信息

- `GET /api/v1/intervention/elders/{elderUserId}/plans`
  - 功能：按老人查询干预计划列表
  - 典型用例：查看某个老人的全部干预计划（支持按状态、时间等筛选）
  - 常见查询参数：
    - `status`：计划状态（如 ACTIVE、FINISHED 等）
    - `page` / `pageSize`：分页参数

- `PUT /api/v1/intervention/plans/{planId}`
  - 功能：更新干预计划基础信息
  - 典型用例：修改计划标题、描述、起止日期等（不含计划项）

- `PATCH /api/v1/intervention/plans/{planId}/status`
  - 功能：变更干预计划状态
  - 典型用例：医生将计划从“草稿”置为“生效中”，或将“生效中”的计划暂停、结束等
  - 状态示例：
    - `DRAFT`：草稿
    - `PENDING`：待生效
    - `ACTIVE`：生效中
    - `PAUSED`：暂停
    - `FINISHED`：已结束
    - `CANCELLED`：已废弃

> 说明：上述 API 遵循后端统一响应格式（`code`、`message`、`data`），并在 Swagger 文档中补充详细字段定义与示例。

## 二、计划项管理（PlanItem：Medication + Rehab）

计划项用于在某个干预计划下，定义具体的用药计划和康复训练计划。当前实现的接口包括：

- `POST /api/v1/intervention/plans/{planId}/items`
  - 功能：在指定干预计划下创建一个计划项
  - 典型用例：
    - 创建一条用药计划项（如“晨起服用降压药”）
    - 创建一条康复训练计划项（如“每周三次下肢力量训练”）
  - 关键字段：
    - `itemType`：计划项类型，`MEDICATION`（用药）或 `REHAB`（康复）
    - `name`：计划项名称
    - `description`：计划项说明
    - `startDate` / `endDate`：计划项起止日期
    - `medicationDetail`（当 `itemType = MEDICATION` 时必填）：
      - `drug_name`：药品名称
      - `dosage`：每次剂量（如“5mg”）
      - `frequency_type`：用药频次描述（如“每天一次”）
      - `instructions`：用药指示与备注
    - `rehabDetail`（当 `itemType = REHAB` 时必填）：
      - `exercise_name`：训练名称
      - `exercise_type`：训练类型（有氧 / 力量 / 平衡 / 认知等）
      - `guide_resource_url`：训练指导资源链接（视频或图文）

- `GET /api/v1/intervention/plans/{planId}/items`
  - 功能：查询某个干预计划下的所有计划项
  - 典型用例：在计划详情页展示该计划下的所有用药和康复项目
  - 查询参数：
    - `status`：计划项状态，可选值：
      - `ACTIVE`：生效中
      - `PAUSED`：暂停
      - `STOPPED`：已停止

- `GET /api/v1/intervention/items/{itemId}`
  - 功能：获取单个计划项详情
  - 典型用例：点击某计划项进入详情页面，查看其用药/康复细节

- `PUT /api/v1/intervention/items/{itemId}`
  - 功能：更新计划项基础信息和对应的用药/康复细节
  - 典型用例：
    - 调整用药剂量或频次
    - 修改康复训练的名称、类型或教学资源

- `PATCH /api/v1/intervention/items/{itemId}/status`
  - 功能：单独变更计划项的状态
  - 典型用例：
    - 暂停某一条康复训练计划项
    - 停止某一条用药计划项
  - 状态示例：
    - `ACTIVE`：生效中
    - `PAUSED`：暂停
    - `STOPPED`：已停止

- `DELETE /api/v1/intervention/items/{itemId}`
  - 功能：删除计划项
  - 典型用例：某条计划项不再需要时，将其从计划中移除（同时删除对应的用药/康复详情）

> 说明：计划项管理接口同样遵循统一响应格式，返回的数据结构与 `InterventionPlanItemResponse` Swagger schema 保持一致。

## 三、后续扩展方向（当前仅作为规划，不在本次落地范围）

- **计划日程管理**：为计划项创建日程规则，并在事务中生成任务实例
- **任务实例查询**：老人端查看“今日任务”“近期任务”等
- **执行记录管理**：提交服药/训练的执行记录，用于依从性分析和后续评估

后续实现上述扩展时，将在本目录补充对应的 API 列表与接口设计说明。
