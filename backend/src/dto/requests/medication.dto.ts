export interface CreateMedicationRequest {
  elder_id: number;
  drug_name: string;
  dosage?: string;
  frequency?: string;
  start_date: string;
  end_date?: string;
  notes?: string;
}

export interface UpdateMedicationRequest {
  drug_name?: string;
  dosage?: string;
  frequency?: string;
  start_date?: string;
  end_date?: string;
  notes?: string;
}

export interface QueryMedicationRequest {
  page: number;
  pageSize: number;
  elder_id?: number;
  drug_name?: string;
  start_date?: string;
  end_date?: string;
  orderBy?: string;
}

export interface MedicationResponse {
  id: number;
  elder_id: number;
  drug_name: string;
  dosage: string | null;
  frequency: string | null;
  start_date: string;
  end_date: string | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
}
