export interface CreateHealthRecordRequest {
  elder_id: number;
  category_id: number;
  record_title: string;
  record_content: string;
  record_date: string;
}

export interface UpdateHealthRecordRequest {
  category_id?: number;
  record_title?: string;
  record_content?: string;
  record_date?: string;
}

export interface QueryHealthRecordRequest {
  page: number;
  pageSize: number;
  elder_id?: number;
  category_id?: number;
  start_date?: string;
  end_date?: string;
  orderBy?: string;
}

export interface HealthRecordResponse {
  id: number;
  elder_id: number;
  category_id: number;
  record_title: string;
  record_content: string;
  record_date: string;
  created_at: string;
  updated_at: string;
}
