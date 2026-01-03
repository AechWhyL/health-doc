import HttpUtil from './HttpUtil';
import { ApiResponse, ElderProfile, PaginatedResult, CreateElderPayload, UpdateElderPayload } from './types';

export async function getElderList(page: number = 1, pageSize: number = 10, name?: string, idCard?: string): Promise<ApiResponse<PaginatedResult<ElderProfile>>> {
  let queryString: string = `page=${page}&pageSize=${pageSize}`;
  if (name) {
    queryString += `&name=${encodeURIComponent(name)}`;
  }
  if (idCard) {
    queryString += `&id_card=${encodeURIComponent(idCard)}`;
  }
  const response = await HttpUtil.get<ApiResponse<PaginatedResult<ElderProfile>>>(`/api/v1/elder-health/elder/list?${queryString}`);
  return response.data;
}

export async function getElderById(id: number): Promise<ApiResponse<ElderProfile>> {
  const response = await HttpUtil.get<ApiResponse<ElderProfile>>(`/api/v1/elder-health/elder/${id}`);
  return response.data;
}

export async function createElder(payload: CreateElderPayload): Promise<ApiResponse<ElderProfile>> {
  const response = await HttpUtil.post<ApiResponse<ElderProfile>>('/api/v1/elder-health/elder', payload);
  return response.data;
}

export async function updateElder(id: number, payload: UpdateElderPayload): Promise<ApiResponse<ElderProfile>> {
  const response = await HttpUtil.put<ApiResponse<ElderProfile>>(`/api/v1/elder-health/elder/${id}`, payload);
  return response.data;
}

export async function deleteElder(id: number): Promise<ApiResponse<Object>> {
  const response = await HttpUtil.delete<ApiResponse<Object>>(`/api/v1/elder-health/elder/${id}`);
  return response.data;
}
