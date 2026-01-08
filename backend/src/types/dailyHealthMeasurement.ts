export interface DailyHealthMeasurement {
  id?: number;
  elder_id: number;
  measured_at: string;
  sbp?: number;
  dbp?: number;
  fpg?: number;
  ppg_2h?: number;
  weight?: number;
  steps?: number;
  source: string;
  remark?: string;
  created_at?: string;
  updated_at?: string;
}

