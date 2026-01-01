import HttpUtil, { HttpHeaders } from './HttpUtil';

// 定义API响应数据结构
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

// 定义用户数据接口
export interface UserSummary {
  id: number;
  username: string;
  email: string | null;
  phone: string | null;
  real_name: string | null;
  avatar: string | null;
  status: 'active' | 'inactive' | 'locked';
}

// 定义用户信息更新接口
export interface UserUpdateInfo {
  name?: string;
  email?: string;
  avatar?: string;
}

// 定义健康数据接口
export interface HealthData {
  id: number;
  type: string;
  value: number;
  unit: string;
  timestamp: number;
}

// 定义健康数据创建接口
export interface HealthDataCreate {
  type: string;
  value: number;
  unit: string;
}

// 定义健康数据更新接口
export interface HealthDataUpdate {
  type?: string;
  value?: number;
  unit?: string;
  timestamp?: number;
}

// 定义健康数据列表响应接口
export interface HealthDataListResponse {
  list: HealthData[];
  total: number;
  page: number;
  pageSize: number;
}

// 定义登录响应数据接口
export interface LoginResponseData {
  token: string;
  user: UserSummary;
}

// 定义登录请求接口
export interface LoginRequest {
  username: string;
  password: string;
}

// 定义注册请求接口
export interface RegisterRequest {
  username: string;
  password: string;
  email?: string;
  phone?: string;
  real_name?: string;
}

// 定义健康数据创建负载接口
export interface HealthDataPayload {
  type: string;
  value: number;
  unit: string;
  timestamp: number;
}

/**
 * API服务类
 * 封装所有业务相关的API请求
 */
export class ApiService {
  constructor() {
    HttpUtil.setBaseUrl('http://localhost:3000');
    const headers = new HttpHeaders();
    headers.set('App-Version', '1.0.0');
    headers.set('Platform', 'HarmonyOS');
    HttpUtil.setDefaultHeaders(headers);
  }

  /**
   * 用户登录
   * @param username 用户名
   * @param password 密码
   */
  async login(username: string, password: string): Promise<ApiResponse<LoginResponseData>> {
    const requestBody: LoginRequest = { username: username, password: password };
    const response = await HttpUtil.post<ApiResponse<LoginResponseData>>('/api/v1/users/login', requestBody);
    if (response.data.data.token) {
      HttpUtil.addDefaultHeader('Authorization', `Bearer ${response.data.data.token}`);
    }
    
    return response.data;
  }

  /**
   * 用户登出
   */
  async logout(): Promise<ApiResponse<Object>> {
    HttpUtil.removeDefaultHeader('Authorization');
    const emptyResponse: ApiResponse<Object> = { code: 200, message: 'ok', data: new Object() };
    return emptyResponse;
  }

  /**
   * 获取当前用户信息
   */
  async getCurrentUser(): Promise<ApiResponse<UserSummary>> {
    const response = await HttpUtil.get<ApiResponse<UserSummary>>('/api/v1/users/current');
    return response.data;
  }

  async register(username: string, password: string, email?: string, phone?: string, realName?: string): Promise<ApiResponse<UserSummary>> {
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

  /**
   * 更新用户信息
   * @param userInfo 用户信息
   */
  async updateUserInfo(userInfo: UserUpdateInfo): Promise<ApiResponse<UserSummary>> {
    const response = await HttpUtil.put<ApiResponse<UserSummary>>('/user/profile', userInfo);
    return response.data;
  }

  /**
   * 获取健康数据列表
   * @param type 数据类型（可选）
   * @param page 页码
   * @param pageSize 每页数量
   */
  async getHealthDataList(type?: string, page: number = 1, pageSize: number = 10): Promise<ApiResponse<HealthDataListResponse>> {
    let queryString = `page=${page}&pageSize=${pageSize}`;
    if (type) {
      queryString += `&type=${type}`;
    }
    
    const response = await HttpUtil.get<ApiResponse<HealthDataListResponse>>(`/health-data?${queryString}`);
    
    return response.data;
  }

  /**
   * 添加健康数据
   * @param healthData 健康数据
   */
  async addHealthData(healthData: HealthDataCreate): Promise<ApiResponse<HealthData>> {
    const payload: HealthDataPayload = {
      type: healthData.type,
      value: healthData.value,
      unit: healthData.unit,
      timestamp: Date.now()
    };
    const response = await HttpUtil.post<ApiResponse<HealthData>>('/health-data', payload);
    return response.data;
  }

  /**
   * 更新健康数据
   * @param id 数据ID
   * @param healthData 健康数据
   */
  async updateHealthData(id: number, healthData: HealthDataUpdate): Promise<ApiResponse<HealthData>> {
    const response = await HttpUtil.put<ApiResponse<HealthData>>(`/health-data/${id}`, healthData);
    return response.data;
  }

  /**
   * 删除健康数据
   * @param id 数据ID
   */
  async deleteHealthData(id: number): Promise<ApiResponse<void>> {
    const response = await HttpUtil.delete<ApiResponse<void>>(`/health-data/${id}`);
    return response.data;
  }

  /**
   * 获取健康数据统计
   * @param startDate 开始日期
   * @param endDate 结束日期
   */
  async getHealthStats(startDate: number, endDate: number): Promise<ApiResponse<Object>> {
    const queryString = `startDate=${startDate}&endDate=${endDate}`;
    
    const response = await HttpUtil.get<ApiResponse<Object>>(`/health-data/stats?${queryString}`);
    return response.data;
  }
}

// 导出ApiService单例
export default new ApiService();
