import HttpUtil from './HttpUtil';
import { ApiResponse, HealthData, HealthDataCreate, HealthDataUpdate, HealthDataListResponse, HealthDataPayload } from './types';

export async function getHealthDataList(type?: string, page: number = 1, pageSize: number = 10): Promise<ApiResponse<HealthDataListResponse>> {
  let queryString = `page=${page}&pageSize=${pageSize}`;
  if (type) {
    queryString += `&type=${type}`;
  }
  const response = await HttpUtil.get<ApiResponse<HealthDataListResponse>>(`/health-data?${queryString}`);
  return response.data;
}

export async function addHealthData(healthData: HealthDataCreate): Promise<ApiResponse<HealthData>> {
  const payload: HealthDataPayload = {
    type: healthData.type,
    value: healthData.value,
    unit: healthData.unit,
    timestamp: Date.now()
  };
  const response = await HttpUtil.post<ApiResponse<HealthData>>('/health-data', payload);
  return response.data;
}

export async function updateHealthData(id: number, healthData: HealthDataUpdate): Promise<ApiResponse<HealthData>> {
  const response = await HttpUtil.put<ApiResponse<HealthData>>(`/health-data/${id}`, healthData);
  return response.data;
}

export async function deleteHealthData(id: number): Promise<ApiResponse<void>> {
  const response = await HttpUtil.delete<ApiResponse<void>>(`/health-data/${id}`);
  return response.data;
}

export async function getHealthStats(startDate: number, endDate: number): Promise<ApiResponse<Object>> {
  const queryString = `startDate=${startDate}&endDate=${endDate}`;
  const response = await HttpUtil.get<ApiResponse<Object>>(`/health-data/stats?${queryString}`);
  return response.data;
}

