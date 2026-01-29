
export type HealthRecordType = 'MEDICAL_HISTORY' | 'CHECK_REPORT' | 'MEDICATION' | 'ALLERGY'

export interface HealthRecordAttachment {
  type: 'IMAGE' | 'FILE';
  url: string;
  name?: string;
}

type HealthRecordContent = MedicalHistoryContent | CheckReportContent | MedicationContent | AllergyContent;

export interface MedicalHistoryContent {
  disease_name: string;
  diagnosed_at: string;
  status: 'ONGOING' | 'REMISSION' | 'CURED';
  notes?: string;
  attachments?: HealthRecordAttachment[];
}

export interface CheckReportContent {
  check_date: string;
  hospital_name: string;
  check_item: string;
  result_summary: 'NORMAL' | 'MILD_ABNORMAL' | 'SIGNIFICANT_ABNORMAL';
  notes?: string;
  attachments?: HealthRecordAttachment[];
}

export  interface MedicationContent {
  drug_name: string[];
  dosage: string;
  frequency: string;
  route: string;
  start_date: string;
  end_date?: string;
  notes?: string;
  prescribing_doctor?: string;
  hospital_name?: string;
  attachments?: HealthRecordAttachment[];
}

export interface AllergyContent {
  allergy_item: string;
  reaction_symptoms: string[];
  first_occurrence_date: string;
  last_occurrence_date?: string;
  notes?: string;
  attachments?: HealthRecordAttachment[];
}

export interface HealthRecordItem {
  id: number;
  elder_id: number;
  record_type: HealthRecordType;
  record_title: string;
  record_date: string;
  content_structured: HealthRecordContent;
  creator_name?: string;
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

export type OperationType = 'ADD' | 'MODIFY';

export interface HealthRecordHistory {
  id: number;
  health_record_id: number;
  operator_id: number;
  operator_name?: string;
  operation_type: OperationType;
  snapshot_before?: HealthRecordItem | null;
  snapshot_after: HealthRecordItem;
  created_at: string;
}

export interface HealthRecordHistoryDetailParams {
  history: HealthRecordHistory;
}
