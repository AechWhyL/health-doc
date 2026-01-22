// 干预计划状态: ACTIVE=进行中, STOPPED=已停止
export type InterventionPlanStatus = 'ACTIVE' | 'STOPPED';

export interface InterventionPlan {
  id?: number;
  elder_user_id: number;
  title: string;
  description?: string | null;
  status: InterventionPlanStatus;
  start_date: string;
  end_date?: string | null;
  created_by_user_id: number;
  created_at?: string;
  updated_at?: string;
}

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

