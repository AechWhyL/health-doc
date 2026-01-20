import {
    InterventionPlanResponse,
    InterventionPlanStatus
} from '../../types/interventionPlan';
import {
    PlanItemType,
    PlanItemStatus,
    PlanTaskStatus
} from '../../types/interventionPlanItem';

/**
 * 老人今日任务列表返回的单个任务实例
 */
export interface ElderTaskInstanceInfo {
    id: number;
    item_id: number;
    schedule_id: number | null;
    task_date: string;
    task_time: string | null;
    status: PlanTaskStatus;
    complete_time: string | null;
    remark: string | null;
    proof_image_url: string | null;
}

/**
 * 计划项简要信息
 */
export interface ElderPlanItemInfo {
    id: number;
    plan_id: number;
    item_type: PlanItemType;
    name: string;
    description: string | null;
    status: PlanItemStatus;
    start_date: string;
    end_date: string | null;
    // 用药详情（item_type === 'MEDICATION' 时存在）
    drug_name?: string;
    dosage?: string;
    frequency_type?: string;
    instructions?: string | null;
    // 康复详情（item_type === 'REHAB' 时存在）
    exercise_name?: string;
    exercise_type?: string | null;
    guide_resource_url?: string | null;
}

/**
 * 计划简要信息
 */
export interface ElderPlanInfo {
    id: number;
    elder_user_id: number;
    title: string;
    description: string | null;
    status: InterventionPlanStatus;
    start_date: string;
    end_date: string | null;
}

/**
 * 按计划项分组的任务列表
 */
export interface ElderTasksByPlanItem {
    plan_item: ElderPlanItemInfo;
    tasks: ElderTaskInstanceInfo[];
}

/**
 * 按计划分组的任务列表
 */
export interface ElderTasksByPlan {
    plan: ElderPlanInfo;
    items: ElderTasksByPlanItem[];
}

/**
 * 老人今日任务列表响应
 */
export interface ElderTodayTasksResponse {
    date: string;
    total_tasks: number;
    completed_tasks: number;
    plans: ElderTasksByPlan[];
}

/**
 * 原始查询行（JOIN查询结果）
 */
export interface ElderTodayTaskRawRow {
    // task fields
    task_id: number;
    task_item_id: number;
    task_schedule_id: number | null;
    task_date: string;
    task_time: string | null;
    task_status: PlanTaskStatus;
    task_complete_time: string | null;
    task_remark: string | null;
    task_proof_image_url: string | null;
    // plan_item fields
    item_id: number;
    item_plan_id: number;
    item_type: PlanItemType;
    item_name: string;
    item_description: string | null;
    item_status: PlanItemStatus;
    item_start_date: string;
    item_end_date: string | null;
    // medication fields (nullable)
    med_drug_name: string | null;
    med_dosage: string | null;
    med_frequency_type: string | null;
    med_instructions: string | null;
    // rehab fields (nullable)
    rehab_exercise_name: string | null;
    rehab_exercise_type: string | null;
    rehab_guide_resource_url: string | null;
    // plan fields
    plan_id: number;
    plan_elder_user_id: number;
    plan_title: string;
    plan_description: string | null;
    plan_status: InterventionPlanStatus;
    plan_start_date: string;
    plan_end_date: string | null;
}
