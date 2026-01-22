export type InterventionPlanStatus = 'ACTIVE' | 'STOPPED';
export type PlanItemType = 'MEDICATION' | 'REHAB';
export type PlanItemStatus = 'ACTIVE' | 'STOPPED';
export type PlanScheduleType = 'ONCE' | 'DAILY' | 'WEEKLY';
export type PlanTaskStatus = 'PENDING' | 'COMPLETED' | 'SKIPPED' | 'MISSED';

// --- Response Interfaces (matching Backend Entity/DB structure, usually snake_case) ---

export interface InterventionPlanResponse {
  id: number;
  elder_user_id: number;
  title: string;
  description: string | null;
  status: InterventionPlanStatus;
  start_date: string;
  end_date: string | null;
  created_by_user_id: number;
  created_at: string;
  updated_at: string;
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
  created_at: string;
  updated_at: string;
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
  times_of_day: string[]; // JSON array in DB
  weekdays: number[] | null; // JSON array in DB
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
  remark: string | null;
  proof_image_url: string | null;
  created_at: string;
  updated_at: string;
}

export interface PlanListResponse {
  total: number;
  records: InterventionPlanResponse[];
}

// --- Request Interfaces (matching Backend DTOs, usually camelCase) ---

export interface CreateInterventionPlanRequest {
  elderUserId: number;
  title: string;
  description?: string | null;
  startDate: string;
  endDate?: string | null;
  createdByUserId: number;
}

export interface UpdateInterventionPlanRequest {
  title?: string;
  description?: string | null;
  startDate?: string;
  endDate?: string | null;
}

export interface QueryInterventionPlanRequest {
  page?: number;
  pageSize?: number;
  status?: InterventionPlanStatus;
  orderBy?: string;
}

export interface MedicationDetail {
  drug_name: string;
  dosage: string;
  frequency_type: string;
  instructions?: string | null;
}

export interface RehabDetail {
  exercise_name: string;
  exercise_type?: string | null;
  guide_resource_url?: string | null;
}

export interface CreatePlanItemRequest {
  itemType: PlanItemType;
  name: string;
  description?: string | null;
  startDate: string;
  endDate?: string | null;
  medicationDetail?: MedicationDetail;
  rehabDetail?: RehabDetail;
}

export interface UpdatePlanItemRequest {
  name?: string;
  description?: string | null;
  startDate?: string;
  endDate?: string | null;
  medicationDetail?: Partial<MedicationDetail>;
  rehabDetail?: Partial<RehabDetail>;
}

export interface QueryPlanItemRequest {
  status?: PlanItemStatus;
}

export interface CreatePlanItemScheduleRequest {
  scheduleType: PlanScheduleType;
  startDate: string;
  endDate?: string | null;
  timesOfDay: string[];
  weekdays?: number[];
}

export interface UpdatePlanItemScheduleRequest {
  scheduleType?: PlanScheduleType;
  startDate?: string;
  endDate?: string | null;
  timesOfDay?: string[];
  weekdays?: number[];
}

export interface QueryPlanTaskInstanceRequest {
  startDate?: string;
  endDate?: string;
  status?: PlanTaskStatus;
}

export interface CreateTaskInstancesRequest {
  startDate: string;
  endDate: string;
  overrideExisting?: boolean;
}

export interface UpdateTaskInstanceStatusRequest {
  status: PlanTaskStatus;
  remark?: string;
  proof_image_url?: string;
}

// --- Helper Interfaces & Route Params ---

export interface ElderResponse {
  id: number;
  name: string;
  gender: number;
  birth_date: string;
  phone: string;
  address: string | null;
  emergency_contact: string;
  height: number | null;
  weight: number | null;
  blood_type: string | null;
  age: number;
  created_at: string;
  updated_at: string;
}

export interface UserElderRelationItem {
  relation_id: number;
  elder_id: number; // elder_basic_info.id (for backward compatibility)
  elder_user_id: number | null; // the elder's user account ID  - USE THIS for creating plans!
  relation_name: string | null;
  remark: string | null;
  elder: ElderResponse;
}

export interface MyEldersListData {
  total: number;
  page: number;
  pageSize: number;
  items: UserElderRelationItem[];
}

export interface TodayTaskItem {
  task: PlanTaskInstanceResponse;
  item: PlanItemResponse;
  plan: InterventionPlanResponse;
}

export interface ElderTaskStats {
  elder_id: number;
  total_tasks: number;
  completed_tasks: number;
}

export interface TodayTaskStatsResponse {
  total_elders: number;
  total_tasks: number;
  completed_tasks: number;
  elder_stats: ElderTaskStats[];
}
