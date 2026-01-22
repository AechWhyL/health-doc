import { httpRequest } from './HttpUtil';
import { RequestEnum } from './httpEnum';
import { ApiResponse } from '../../models/DTO/types';
import {
  CreateInterventionPlanRequest,
  InterventionPlanResponse,
  QueryInterventionPlanRequest,
  PlanItemResponse,
  CreatePlanItemRequest,
  QueryPlanItemRequest,
  PlanTaskInstanceResponse,
  QueryPlanTaskInstanceRequest,
  UpdateTaskInstanceStatusRequest,
  CreatePlanItemScheduleRequest,
  MyEldersListData,
  PlanListResponse,
  PlanTaskStatus,
  PlanItemStatus,
  TodayTaskStatsResponse
} from '../../models/DTO/intervention';

export class InterventionService {
  /**
   * 获取关联老人列表 (复用 Users 模块接口)
   */
  static async getMyElders(page: number = 1, pageSize: number = 20, elderName?: string): Promise<ApiResponse<MyEldersListData>> {
    const params: Record<string, Object> = {};
    params['page'] = page;
    params['pageSize'] = pageSize;
    if (elderName) {
      params['elder_name'] = elderName;
    }
    return httpRequest<ApiResponse<MyEldersListData>, Record<string, Object>>({
      url: '/api/v1/users/me/elders',
      method: RequestEnum.GET,
      token: 'auth',
      params: params
    });
  }

  /**
   * 获取老人的干预计划列表
   */
  static async getPlansByElderUserId(elderUserId: number, query?: QueryInterventionPlanRequest): Promise<ApiResponse<PlanListResponse>> {
    return httpRequest<ApiResponse<PlanListResponse>, QueryInterventionPlanRequest>({
      url: `/api/v1/intervention/elders/${elderUserId}/plans`,
      method: RequestEnum.GET,
      token: 'auth',
      params: query
    });
  }

  /**
   * 创建干预计划
   */
  static async createPlan(data: CreateInterventionPlanRequest): Promise<ApiResponse<InterventionPlanResponse>> {
    return httpRequest<ApiResponse<InterventionPlanResponse>, CreateInterventionPlanRequest>({
      url: '/api/v1/intervention/plans',
      method: RequestEnum.POST,
      token: 'auth',
      params: data
    });
  }
  /**
   * 中止干预计划
   */
  static async stopPlan(planId: number): Promise<ApiResponse<InterventionPlanResponse>> {
    return httpRequest<ApiResponse<InterventionPlanResponse>, Record<string, Object>>({
      url: `/api/v1/intervention/plans/${planId}/stop`,
      method: RequestEnum.POST,
      token: 'auth'
    });
  }

  /**
   * 获取计划下的计划项列表
   */
  static async getPlanItemsByPlanId(planId: number, query?: QueryPlanItemRequest): Promise<ApiResponse<PlanItemResponse[]>> {
    return httpRequest<ApiResponse<PlanItemResponse[]>, QueryPlanItemRequest>({
      url: `/api/v1/intervention/plans/${planId}/items`,
      method: RequestEnum.GET,
      token: 'auth',
      params: query
    });
  }

  /**
   * 创建计划项
   */
  static async createPlanItem(planId: number, data: CreatePlanItemRequest): Promise<ApiResponse<PlanItemResponse>> {
    return httpRequest<ApiResponse<PlanItemResponse>, CreatePlanItemRequest>({
      url: `/api/v1/intervention/plans/${planId}/items`,
      method: RequestEnum.POST,
      token: 'auth',
      params: data
    });
  }

  /**
   * 为计划项创建日程
   */
  static async createPlanItemSchedule(itemId: number, data: CreatePlanItemScheduleRequest): Promise<ApiResponse<Object>> {
    return httpRequest<ApiResponse<Object>, CreatePlanItemScheduleRequest>({
      url: `/api/v1/intervention/items/${itemId}/schedules`,
      method: RequestEnum.POST,
      token: 'auth',
      params: data
    });
  }

  /**
   * 获取计划项的任务实例
   */
  static async getTaskInstancesByItemId(itemId: number, query?: QueryPlanTaskInstanceRequest): Promise<ApiResponse<PlanTaskInstanceResponse[]>> {
    return httpRequest<ApiResponse<PlanTaskInstanceResponse[]>, QueryPlanTaskInstanceRequest>({
      url: `/api/v1/intervention/items/${itemId}/tasks`,
      method: RequestEnum.GET,
      token: 'auth',
      params: query
    });
  }

  /**
   * 更新任务实例状态
   */
  static async updateTaskInstanceStatus(taskId: number, status: PlanTaskStatus, remark?: string, proof_image_url?: string): Promise<ApiResponse<PlanTaskInstanceResponse>> {
    const data: UpdateTaskInstanceStatusRequest = { status, remark, proof_image_url };
    return httpRequest<ApiResponse<PlanTaskInstanceResponse>, UpdateTaskInstanceStatusRequest>({
      url: `/api/v1/intervention/tasks/${taskId}/status`,
      method: RequestEnum.PATCH,
      token: 'auth',
      params: data
    });
  }

  /**
   * 更新计划项状态 (停止计划项时会同时跳过未完成的任务)
   */
  static async updatePlanItemStatus(itemId: number, status: PlanItemStatus): Promise<ApiResponse<PlanItemResponse>> {
    interface UpdateStatusRequest {
      status: PlanItemStatus;
    }
    const data: UpdateStatusRequest = { status };
    return httpRequest<ApiResponse<PlanItemResponse>, UpdateStatusRequest>({
      url: `/api/v1/intervention/items/${itemId}/status`,
      method: RequestEnum.POST,
      token: 'auth',
      params: data
    });
  }

  /**
   * 获取今日任务统计
   */
  static async getTodayTaskStats(): Promise<ApiResponse<TodayTaskStatsResponse>> {
    return httpRequest<ApiResponse<TodayTaskStatsResponse>, Record<string, Object>>({
      url: '/api/v1/intervention/stats/today',
      method: RequestEnum.GET,
      token: 'auth'
    });
  }
}
