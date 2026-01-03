export interface ElderBasicInfo {
  id?: number;
  name: string;
  gender: number;
  birth_date: string;
  phone: string;
  address?: string;
  emergency_contact: string;
  height?: number;
  weight?: number;
  blood_type?: string;
  created_at?: string;
  updated_at?: string;
}

export interface AllergyRecord {
  id?: number;
  elder_id: number;
  allergy_item: string;
  allergy_desc?: string;
  created_at?: string;
  updated_at?: string;
}

export type HealthRecordType = 'MEDICAL_HISTORY' | 'CHECK_REPORT' | 'MEDICATION' | 'ALLERGY';

export interface HealthRecordAttachment {
  type: 'IMAGE' | 'FILE';
  url: string;
  name?: string;
}

export interface BaseHealthRecordContent {
  attachments?: HealthRecordAttachment[];
}

export interface MedicalHistoryContent extends BaseHealthRecordContent {
  disease_name: string;
  diagnosed_at: string;
  status: 'ONGOING' | 'REMISSION' | 'CURED';
  notes?: string;
}

export interface CheckReportContent extends BaseHealthRecordContent {
  check_date: string;
  hospital_name: string;
  check_item: string;
  result_summary: 'NORMAL' | 'MILD_ABNORMAL' | 'SIGNIFICANT_ABNORMAL';
  notes?: string;
}

export interface MedicationContent extends BaseHealthRecordContent {
  drug_name: string[];
  dosage: string;
  frequency: string;
  route: string;
  start_date: string;
  end_date?: string;
  notes?: string;
  prescribing_doctor?: string;
  hospital_name?: string;
}

export interface AllergyContent extends BaseHealthRecordContent {
  allergy_item: string;
  reaction_symptoms: string[];
  first_occurrence_date: string;
  last_occurrence_date?: string;
  notes?: string;
}

export type HealthRecordContent = MedicalHistoryContent | CheckReportContent | MedicationContent | AllergyContent;

export const defaultMedicalHistoryContent: MedicalHistoryContent = {
  disease_name: '',
  diagnosed_at: '',
  status: 'ONGOING'
};

export const defaultCheckReportContent: CheckReportContent = {
  check_date: '',
  hospital_name: '',
  check_item: '',
  result_summary: 'NORMAL'
};

export const defaultMedicationContent: MedicationContent = {
  drug_name: [],
  dosage: '',
  frequency: '',
  route: '',
  start_date: ''
};

export const defaultAllergyContent: AllergyContent = {
  allergy_item: '',
  reaction_symptoms: [],
  first_occurrence_date: ''
};

export interface HealthRecord {
  id?: number;
  elder_id: number;
  record_type: HealthRecordType;
  record_title: string;
  record_date: string;
  content_structured: HealthRecordContent;
  created_at?: string;
  updated_at?: string;
}

export interface MedicationRecord {
  id?: number;
  elder_id: number;
  drug_name: string;
  dosage?: string;
  frequency?: string;
  start_date: string;
  end_date?: string;
  notes?: string;
  created_at?: string;
  updated_at?: string;
}
