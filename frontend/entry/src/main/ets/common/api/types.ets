export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

export interface UserSummary {
  id: number;
  username: string;
  email: string | null;
  phone: string | null;
  real_name: string | null;
  avatar: string | null;
  status: 'active' | 'inactive' | 'locked';
}

export type UserRoleCode = 'admin' | 'medical_staff' | 'family' | 'elder';

export interface UserRoleInfo {
  id: number;
  role_code: UserRoleCode;
  role_name: string;
  description: string | null;
}

export interface UserWithRolesSummary extends UserSummary {
  roles: UserRoleInfo[];
}

export interface UserUpdateInfo {
  name?: string;
  email?: string;
  avatar?: string;
}

export interface HealthData {
  id: number;
  type: string;
  value: number;
  unit: string;
  timestamp: number;
}

export interface HealthDataCreate {
  type: string;
  value: number;
  unit: string;
}

export interface HealthDataUpdate {
  type?: string;
  value?: number;
  unit?: string;
  timestamp?: number;
}

export interface HealthDataListResponse {
  list: HealthData[];
  total: number;
  page: number;
  pageSize: number;
}

export interface PaginatedResult<T> {
  total: number;
  pages: number;
  current: number;
  size: number;
  items: T[];
}

export interface ElderProfile {
  id: number;
  name: string;
  gender: number;
  birth_date: string;
  phone: string;
  address: string | null;
  emergency_contact: string;
  height: number | null;
  weight: number | null;
  blood_type: string | null;
  age: number;
  created_at: string;
  updated_at: string;
}

export interface HealthRecord {
  id: number;
  elder_id: number;
  category_id: number;
  record_title: string;
  record_content: string;
  record_date: string;
  created_at: string;
  updated_at: string;
}

export interface CreateElderPayload {
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

export interface UpdateElderPayload {
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

export interface CreateHealthRecordPayload {
  elder_id: number;
  category_id: number;
  record_title: string;
  record_content: string;
  record_date: string;
}

export interface UpdateHealthRecordPayload {
  category_id?: number;
  record_title?: string;
  record_content?: string;
  record_date?: string;
}

export interface LoginResponseData {
  token: string;
  user: UserWithRolesSummary;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface RegisterRequest {
  username: string;
  password: string;
  email?: string;
  phone?: string;
  real_name?: string;
}

export interface HealthDataPayload {
  type: string;
  value: number;
  unit: string;
  timestamp: number;
}
