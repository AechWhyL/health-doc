export interface HealthDataRecord {
  id?: number;
  elder_id: number;
  indicator_type_id: number;
  measure_time: string;
  measure_value: any;
  measure_context?: any;
  remark?: string;
  data_source: string;
  input_user_id: number;
  input_user_type: string;
  is_deleted: number;
  created_at?: string;
  updated_at?: string;
}

export interface HealthDataRecordResponse {
  id: number;
  elder_id: number;
  indicator_type_id: number;
  indicator_type?: {
    id: number;
    indicator_code: string;
    indicator_name: string;
    unit: string;
  };
  measure_time: string;
  measure_value: any;
  measure_context?: any;
  remark?: string;
  data_source: string;
  input_user_id: number;
  input_user_type: string;
  created_at: string;
  updated_at: string;
}

export interface HealthDataRecordHistory {
  id: number;
  health_record_id: number;
  operation_type: string;
  before_value?: any;
  after_value?: any;
  operation_reason?: string;
  operator_id: number;
  operator_type: string;
  created_at: string;
}
