export interface CreateElderRequest {
  name: string;
  gender: number;
  birth_date: string;
  phone: string;
  id_card: string;
  emergency_contact: string;
  address?: string;
  height?: number;
  weight?: number;
  blood_type?: string;
}

export interface UpdateElderRequest {
  name?: string;
  gender?: number;
  birth_date?: string;
  phone?: string;
  id_card?: string;
  address?: string;
  emergency_contact?: string;
  height?: number;
  weight?: number;
  blood_type?: string;
}

export interface QueryElderRequest {
  page: number;
  pageSize: number;
  name?: string;
  id_card?: string;
  orderBy?: string;
}

export interface ElderResponse {
  id: number;
  name: string;
  gender: number;
  birth_date: string;
  phone: string;
  address: string | null;
  id_card: string;
  emergency_contact: string;
  height: number | null;
  weight: number | null;
  blood_type: string | null;
  age: number;
  created_at: string;
  updated_at: string;
}
