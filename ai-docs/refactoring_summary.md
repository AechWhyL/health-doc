# 用户-老人 ID 逻辑重构总结文档

## 1. 重构背景
系统原有的“用户-老人关联”逻辑存在缺陷：在数据库关联表 (`elder_user_relations`) 和干预计划表 (`intervention_plan`) 中，错误地存储了老人的 `elder_basic_info.id` (EHR系统内部档案ID)，而非老人的 `users.id` (用户账号ID)。这导致在多表关联、数据查询及跨端同步时出现 ID 不匹配、外键约束错误以及数据无法查询的问题。

## 2. 变更范围

### 2.1 数据库层 (Database Schema Changes)
-   **`elder_user_relations` 表**:
    -   `elder_id` 列语义变更：从存储 `elder_basic_info.id` 改为存储 `users.id`。
    -   外键约束更新：改为引用 `users(id)`。
-   **`intervention_plan` 表**:
    -   数据迁移：`elder_user_id` 列的旧数据已迁移，从 Basic Info ID 修正为 User ID。

### 2.2 后端逻辑 (Backend Logic)
-   **`ElderUserRelationRepository`**:
    -   修正 JOIN 逻辑：查询关联老人时，通过 `elder_id = e.user_id` 连接 `elder_basic_info`。
-   **`InterventionPlanItemService`**:
    -   修正统计逻辑：查询今日任务统计时，使用老人的 User ID 进行聚合查询。
-   **`UserService` & `ElderDTO`**:
    -   接口增强：`ElderResponse` 增加 `user_id` 字段，确保前端能明确获取老人的账号 ID。

### 2.3 前端逻辑 (Frontend Logic)
-   **组件更新**: 
    -   `ElderOverviewTab.ets` (家属端首页)
    -   `DocTab.ets` (医护端老人管理)
    -   `HealthDataTab.ets` & `DataTab.ets` (健康数据)
    -   `InterventionIndex.ets` & `ElderInterventionPlanList.ets` (干预计划)
-   **核心变更**:
    -   交互逻辑统一改为优先使用 `elder_user_id` (或 `user_id`) 进行 API 调用（添加关联、查询计划、添加健康数据）。
    -   修复了导航跳转参数，确保跨页面传递正确的 User ID。

## 3. 验证通过项
-   [x] **关联建立**: 医护端/家属端添加关联，数据库正确存储 User ID。
-   [x] **健康数据**: 能正确添加和加载健康数据，无外键错误。
-   [x] **干预计划**: 医护端能正确加载老人的干预计划列表，无“暂无数据”误报。
-   [x] **统计看板**: 首页“今日待办”统计数据准确。

## 4. 后续建议
-   建议在后续开发中，对于涉及用户身份的操作，始终以 `users.id` 为主键锚点，`elder_basic_info.id` 仅用于档案详情查询。
