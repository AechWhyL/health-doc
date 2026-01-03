import HttpUtil from './HttpUtil';
import {
  ApiResponse,
  UserSummary,
  UserUpdateInfo,
  UserRoleInfo,
  UserWithRolesSummary,
  HealthData,
  HealthDataCreate,
  HealthDataUpdate,
  HealthDataListResponse,
  PaginatedResult,
  ElderProfile,
  HealthRecord,
  CreateElderPayload,
  UpdateElderPayload,
  CreateHealthRecordPayload,
  UpdateHealthRecordPayload,
  LoginResponseData
} from './types';
import { login, logout, getCurrentUser, register } from './authApi';
import { getElderList, getElderById, createElder, updateElder, deleteElder } from './elderApi';
import { updateUserInfo } from './userApi';
import { getHealthRecordsByElderId, createHealthRecord, updateHealthRecord, deleteHealthRecord } from './healthRecordApi';
import { getHealthDataList, addHealthData, updateHealthData, deleteHealthData, getHealthStats } from './healthDataApi';

export {
  ApiResponse,
  UserSummary,
  UserUpdateInfo,
  UserRoleInfo,
  UserWithRolesSummary,
  HealthData,
  HealthDataCreate,
  HealthDataUpdate,
  HealthDataListResponse,
  PaginatedResult,
  ElderProfile,
  HealthRecord,
  CreateElderPayload,
  UpdateElderPayload,
  CreateHealthRecordPayload,
  UpdateHealthRecordPayload,
  LoginResponseData
};

export class ApiService {
  constructor() {
    HttpUtil.setBaseUrl('http://localhost:3000');
  }

  /**
   * 用户登录
   * @param username 用户名
   * @param password 密码
   */
  async login(username: string, password: string): Promise<ApiResponse<LoginResponseData>> {
    return login(username, password);
  }

  /**
   * 用户登出
   */
  async logout(): Promise<ApiResponse<Object>> {
    return logout();
  }

  async getElderList(page: number = 1, pageSize: number = 10, name?: string, idCard?: string): Promise<ApiResponse<PaginatedResult<ElderProfile>>> {
    return getElderList(page, pageSize, name, idCard);
  }

  async getElderById(id: number): Promise<ApiResponse<ElderProfile>> {
    return getElderById(id);
  }

  async createElder(payload: CreateElderPayload): Promise<ApiResponse<ElderProfile>> {
    return createElder(payload);
  }

  async updateElder(id: number, payload: UpdateElderPayload): Promise<ApiResponse<ElderProfile>> {
    return updateElder(id, payload);
  }

  async deleteElder(id: number): Promise<ApiResponse<Object>> {
    return deleteElder(id);
  }

  /**
   * 获取当前用户信息
   */
  async getCurrentUser(): Promise<ApiResponse<UserSummary>> {
    return getCurrentUser();
  }

  async register(username: string, password: string, email?: string, phone?: string, realName?: string): Promise<ApiResponse<UserSummary>> {
    return register(username, password, email, phone, realName);
  }

  /**
   * 更新用户信息
   * @param userInfo 用户信息
   */
  async updateUserInfo(userInfo: UserUpdateInfo): Promise<ApiResponse<UserSummary>> {
    return updateUserInfo(userInfo);
  }

  /**
   * 获取健康数据列表
   * @param type 数据类型（可选）
   * @param page 页码
   * @param pageSize 每页数量
   */
  async getHealthDataList(type?: string, page: number = 1, pageSize: number = 10): Promise<ApiResponse<HealthDataListResponse>> {
    return getHealthDataList(type, page, pageSize);
  }

  async getHealthRecordsByElderId(elderId: number): Promise<ApiResponse<HealthRecord[]>> {
    return getHealthRecordsByElderId(elderId);
  }

  async createHealthRecord(payload: CreateHealthRecordPayload): Promise<ApiResponse<HealthRecord>> {
    return createHealthRecord(payload);
  }

  async updateHealthRecord(id: number, payload: UpdateHealthRecordPayload): Promise<ApiResponse<HealthRecord>> {
    return updateHealthRecord(id, payload);
  }

  async deleteHealthRecord(id: number): Promise<ApiResponse<Object>> {
    return deleteHealthRecord(id);
  }

  /**
   * 添加健康数据
   * @param healthData 健康数据
   */
  async addHealthData(healthData: HealthDataCreate): Promise<ApiResponse<HealthData>> {
    return addHealthData(healthData);
  }

  /**
   * 更新健康数据
   * @param id 数据ID
   * @param healthData 健康数据
   */
  async updateHealthData(id: number, healthData: HealthDataUpdate): Promise<ApiResponse<HealthData>> {
    return updateHealthData(id, healthData);
  }

  /**
   * 删除健康数据
   * @param id 数据ID
   */
  async deleteHealthData(id: number): Promise<ApiResponse<void>> {
    return deleteHealthData(id);
  }

  /**
   * 获取健康数据统计
   * @param startDate 开始日期
   * @param endDate 结束日期
   */
  async getHealthStats(startDate: number, endDate: number): Promise<ApiResponse<Object>> {
    return getHealthStats(startDate, endDate);
  }
}

// 导出ApiService单例
export default new ApiService();
