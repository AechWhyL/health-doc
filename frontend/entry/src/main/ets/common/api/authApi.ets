import HttpUtil from './HttpUtil';
import { ApiResponse, UserSummary, LoginResponseData, LoginRequest, RegisterRequest } from './types';

export async function login(username: string, password: string): Promise<ApiResponse<LoginResponseData>> {
  const requestBody: LoginRequest = { username: username, password: password };
  const response = await HttpUtil.post<ApiResponse<LoginResponseData>>('/api/v1/users/login', requestBody);
  const data: ApiResponse<LoginResponseData> = response.data;
  if (data.data.token && data.data.token.length > 0) {
    HttpUtil.setAuthToken(data.data.token);
  }
  return data;
}

export async function logout(): Promise<ApiResponse<Object>> {
  HttpUtil.clearAuthToken();
  const result: ApiResponse<Object> = { code: 200, message: 'ok', data: new Object() };
  return result;
}

export async function getCurrentUser(): Promise<ApiResponse<UserSummary>> {
  const response = await HttpUtil.get<ApiResponse<UserSummary>>('/api/v1/users/current');
  return response.data;
}

export async function register(username: string, password: string, email?: string, phone?: string, realName?: string): Promise<ApiResponse<UserSummary>> {
  const body: RegisterRequest = { username: username, password: password };
  if (email !== undefined) {
    body.email = email;
  }
  if (phone !== undefined) {
    body.phone = phone;
  }
  if (realName !== undefined) {
    body.real_name = realName;
  }
  const response = await HttpUtil.post<ApiResponse<UserSummary>>('/api/v1/users', body);
  return response.data;
}
