import { InterventionPlanRepository } from '../repositories/interventionPlan.repository';
import {
  CreateInterventionPlanRequest,
  UpdateInterventionPlanRequest,
  QueryInterventionPlanRequest,
  InterventionPlanResponse
} from '../dto/requests/interventionPlan.dto';
import { InterventionPlan, InterventionPlanStatus } from '../types/interventionPlan';
import { NotFoundError } from '../utils/errors';

export class InterventionPlanService {
  static async createPlan(
    data: CreateInterventionPlanRequest
  ): Promise<InterventionPlanResponse> {
    const planData: Omit<InterventionPlan, 'id' | 'created_at' | 'updated_at'> = {
      elder_user_id: data.elderUserId,
      title: data.title,
      description: data.description ?? null,
      status: 'DRAFT',
      start_date: data.startDate,
      end_date: data.endDate ?? null,
      created_by_user_id: data.createdByUserId
    };

    const insertId = await InterventionPlanRepository.create(planData);
    const plan = await InterventionPlanRepository.findById(insertId);

    if (!plan) {
      throw new Error('创建干预计划失败');
    }

    return this.toResponse(plan);
  }

  static async getPlanById(id: number): Promise<InterventionPlanResponse> {
    const plan = await InterventionPlanRepository.findById(id);
    if (!plan) {
      throw new NotFoundError('干预计划不存在');
    }
    return this.toResponse(plan);
  }

  static async getPlansByElderUserId(
    elderUserId: number,
    query: QueryInterventionPlanRequest
  ): Promise<{
    total: number;
    pages: number;
    current: number;
    size: number;
    records: InterventionPlanResponse[];
  }> {
    const { page, pageSize, status, orderBy } = query;

    const { items, total } = await InterventionPlanRepository.findByElderUserId(
      elderUserId,
      page,
      pageSize,
      status,
      orderBy
    );

    const pages = Math.ceil(total / pageSize);
    const records = items.map((item) => this.toResponse(item));

    return {
      total,
      pages,
      current: page,
      size: pageSize,
      records
    };
  }

  static async updatePlan(
    id: number,
    data: UpdateInterventionPlanRequest
  ): Promise<InterventionPlanResponse> {
    const plan = await InterventionPlanRepository.findById(id);
    if (!plan) {
      throw new NotFoundError('干预计划不存在');
    }

    const updateData: Partial<Omit<InterventionPlan, 'id'>> = {};

    if (data.title !== undefined) {
      updateData.title = data.title;
    }
    if (data.description !== undefined) {
      updateData.description = data.description;
    }
    if (data.startDate !== undefined) {
      updateData.start_date = data.startDate;
    }
    if (data.endDate !== undefined) {
      updateData.end_date = data.endDate;
    }

    if (Object.keys(updateData).length > 0) {
      await InterventionPlanRepository.update(id, updateData);
    }

    const updated = await InterventionPlanRepository.findById(id);
    if (!updated) {
      throw new NotFoundError('干预计划不存在');
    }

    return this.toResponse(updated);
  }

  static async updatePlanStatus(id: number, status: InterventionPlanStatus): Promise<InterventionPlanResponse> {
    const plan = await InterventionPlanRepository.findById(id);
    if (!plan) {
      throw new NotFoundError('干预计划不存在');
    }

    await InterventionPlanRepository.update(id, { status });

    const updated = await InterventionPlanRepository.findById(id);
    if (!updated) {
      throw new NotFoundError('干预计划不存在');
    }

    return this.toResponse(updated);
  }

  private static toResponse(plan: InterventionPlan): InterventionPlanResponse {
    return {
      id: plan.id!,
      elder_user_id: plan.elder_user_id,
      title: plan.title,
      description: plan.description ?? null,
      status: plan.status,
      start_date: plan.start_date,
      end_date: plan.end_date ?? null,
      created_by_user_id: plan.created_by_user_id,
      created_at: plan.created_at || '',
      updated_at: plan.updated_at || ''
    };
  }
}

