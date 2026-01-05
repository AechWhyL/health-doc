export type InterventionPlanStatus = 'DRAFT' | 'PENDING' | 'ACTIVE' | 'PAUSED' | 'FINISHED' | 'CANCELLED';

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

