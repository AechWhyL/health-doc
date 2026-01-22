-- =====================================================
-- 数据库迁移: 统一干预计划和计划项的状态枚举
-- 作者: System
-- 日期: 2026-01-21
-- 描述: 将干预计划和计划项的状态枚举统一为: ACTIVE(进行中), STOPPED(已停止)
-- =====================================================

-- 1. 更新 intervention_plan 表中现有记录的状态值
--    将旧状态映射到新状态:
--    DRAFT, PENDING -> ACTIVE
--    PAUSED, FINISHED, CANCELLED -> STOPPED
--    ACTIVE -> ACTIVE (保持不变)

UPDATE intervention_plan
SET
    status = 'ACTIVE'
WHERE
    status IN ('DRAFT', 'PENDING');

UPDATE intervention_plan
SET
    status = 'STOPPED'
WHERE
    status IN (
        'PAUSED',
        'FINISHED',
        'CANCELLED'
    );

-- 2. 更新 plan_item 表中现有记录的状态值
--    将 PAUSED 状态改为 STOPPED
UPDATE plan_item SET status = 'STOPPED' WHERE status = 'PAUSED';

-- 3. 为 intervention_plan 表的 status 字段添加注释
ALTER TABLE intervention_plan
MODIFY COLUMN status VARCHAR(20) NOT NULL COMMENT '计划状态: ACTIVE=进行中, STOPPED=已停止';

-- 4. 为 plan_item 表的 status 字段添加注释
ALTER TABLE plan_item
MODIFY COLUMN status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '计划项状态: ACTIVE=进行中, STOPPED=已停止';

-- 5. 为 plan_task_instance 表的 status 字段添加注释 (保持现有值,仅添加注释)
ALTER TABLE plan_task_instance
MODIFY COLUMN status VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '任务状态: PENDING=待执行, COMPLETED=已完成, SKIPPED=已跳过, MISSED=已错过, STOPPED=已停止';

-- 验证查询 (可选,用于检查迁移结果)
-- SELECT status, COUNT(*) as count FROM intervention_plan GROUP BY status;
-- SELECT status, COUNT(*) as count FROM plan_item GROUP BY status;
-- SELECT status, COUNT(*) as count FROM plan_task_instance GROUP BY status;