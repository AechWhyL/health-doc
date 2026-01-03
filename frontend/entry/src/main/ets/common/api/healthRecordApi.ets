import HttpUtil from './HttpUtil';
import { ApiResponse, HealthRecord, CreateHealthRecordPayload, UpdateHealthRecordPayload } from './types';

export async function getHealthRecordsByElderId(elderId: number): Promise<ApiResponse<HealthRecord[]>> {
  const response = await HttpUtil.get<ApiResponse<HealthRecord[]>>(`/api/v1/elder-health/elder/${elderId}/health-records`);
  return response.data;
}

export async function createHealthRecord(payload: CreateHealthRecordPayload): Promise<ApiResponse<HealthRecord>> {
  const response = await HttpUtil.post<ApiResponse<HealthRecord>>('/api/v1/elder-health/health-record', payload);
  return response.data;
}

export async function updateHealthRecord(id: number, payload: UpdateHealthRecordPayload): Promise<ApiResponse<HealthRecord>> {
  const response = await HttpUtil.put<ApiResponse<HealthRecord>>(`/api/v1/elder-health/health-record/${id}`, payload);
  return response.data;
}

export async function deleteHealthRecord(id: number): Promise<ApiResponse<Object>> {
  const response = await HttpUtil.delete<ApiResponse<Object>>(`/api/v1/elder-health/health-record/${id}`);
  return response.data;
}

