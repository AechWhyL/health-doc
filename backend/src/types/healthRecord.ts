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

export interface HealthRecord {
  id?: number;
  elder_id: number;
  category_id: number;
  record_title: string;
  record_content: string;
  record_date: string;
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
