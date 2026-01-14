
export type HealthRecordType = 'MEDICAL_HISTORY' | 'CHECK_REPORT' | 'MEDICATION' | 'ALLERGY'

export interface HealthRecordItem {
  id: number;
  elder_id: number;
  record_type: HealthRecordType;
  record_title: string;
  record_date: string;
  content_structured: Record<string, Object>;
  created_at: string;
  updated_at: string;
}

export interface CreateHealthRecordPayload {
  elder_id: number;
  record_type: HealthRecordType;
  record_title: string;
  record_date: string;
  content_structured: Record<string, Object>;
}

export interface UpdateHealthRecordPayload {
  record_type: HealthRecordType;
  record_title: string;
  record_date: string;
  content_structured: Record<string, Object>;
}

export interface HealthRecordFormSubmitPayload {
  recordType: HealthRecordType;
  recordTitle: string;
  recordDate: string;
  contentStructured: Record<string, Object>;
}
