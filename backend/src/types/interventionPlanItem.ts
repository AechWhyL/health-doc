export type PlanItemType = 'MEDICATION' | 'REHAB';

export type PlanItemStatus = 'ACTIVE' | 'PAUSED' | 'STOPPED';

export type PlanScheduleType = 'ONCE' | 'DAILY' | 'WEEKLY';

export type PlanTaskStatus = 'PENDING' | 'COMPLETED' | 'SKIPPED' | 'MISSED';

export interface PlanItem {
  id?: number;
  plan_id: number;
  item_type: PlanItemType;
  name: string;
  description?: string | null;
  status: PlanItemStatus;
  start_date: string;
  end_date?: string | null;
  created_at?: string;
  updated_at?: string;
}

export interface MedicationPlanItemDetail {
  item_id: number;
  drug_name: string;
  dosage: string;
  frequency_type: string;
  instructions?: string | null;
}

export interface RehabPlanItemDetail {
  item_id: number;
  exercise_name: string;
  exercise_type?: string | null;
  guide_resource_url?: string | null;
}

export interface PlanItemSchedule {
  id?: number;
  item_id: number;
  schedule_type: PlanScheduleType;
  start_date: string;
  end_date?: string | null;
  times_of_day: string[];
  weekdays?: number[] | null;
  created_at?: string;
  updated_at?: string;
}

export interface PlanTaskInstance {
  id?: number;
  item_id: number;
  schedule_id?: number | null;
  task_date: string;
  task_time?: string | null;
  status: PlanTaskStatus;
  complete_time?: string | null;
  remark?: string | null;
  proof_image_url?: string | null;
  created_at?: string;
  updated_at?: string;
}

export interface PlanItemResponseBase {
  id: number;
  plan_id: number;
  item_type: PlanItemType;
  name: string;
  description: string | null;
  status: PlanItemStatus;
  start_date: string;
  end_date: string | null;
}

export interface MedicationPlanItemResponse extends PlanItemResponseBase {
  item_type: 'MEDICATION';
  drug_name: string;
  dosage: string;
  frequency_type: string;
  instructions: string | null;
}

export interface RehabPlanItemResponse extends PlanItemResponseBase {
  item_type: 'REHAB';
  exercise_name: string;
  exercise_type: string | null;
  guide_resource_url: string | null;
}

export type PlanItemResponse = MedicationPlanItemResponse | RehabPlanItemResponse;

export interface PlanItemScheduleResponse {
  id: number;
  item_id: number;
  schedule_type: PlanScheduleType;
  start_date: string;
  end_date: string | null;
  times_of_day: string[];
  weekdays: number[] | null;
  created_at: string;
  updated_at: string;
}

export interface PlanTaskInstanceResponse {
  id: number;
  item_id: number;
  schedule_id: number | null;
  task_date: string;
  task_time: string | null;
  status: PlanTaskStatus;
  complete_time: string | null;
  remark?: string | null;
  proof_image_url?: string | null;
  created_at: string;
  updated_at: string;
}

