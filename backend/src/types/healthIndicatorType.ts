export interface HealthIndicatorType {
  id?: number;
  indicator_code: string;
  indicator_name: string;
  unit: string;
  min_value: number;
  max_value: number;
  form_config?: any;
  status: number;
  sort_order: number;
  created_at?: string;
  updated_at?: string;
}

export interface HealthIndicatorTypeResponse {
  id: number;
  indicator_code: string;
  indicator_name: string;
  unit: string;
  min_value: number;
  max_value: number;
  form_config?: any;
  status: number;
  sort_order: number;
  created_at: string;
  updated_at: string;
}
