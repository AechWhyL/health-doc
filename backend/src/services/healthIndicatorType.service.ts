import { HealthIndicatorTypeRepository } from '../repositories/healthIndicatorType.repository';
import { HealthIndicatorType, HealthIndicatorTypeResponse } from '../types/healthIndicatorType';
import { CreateHealthIndicatorTypeRequest, UpdateHealthIndicatorTypeRequest } from '../dto/requests/healthIndicatorType.dto';

export class HealthIndicatorTypeService {
  static async createIndicatorType(data: CreateHealthIndicatorTypeRequest): Promise<HealthIndicatorTypeResponse> {
    const existingByCode = await HealthIndicatorTypeRepository.findByCode(data.indicator_code);
    if (existingByCode) {
      throw new Error('指标编码已存在');
    }

    const indicatorTypeData: Omit<HealthIndicatorType, 'id' | 'created_at' | 'updated_at'> = {
      indicator_code: data.indicator_code,
      indicator_name: data.indicator_name,
      unit: data.unit,
      min_value: data.min_value,
      max_value: data.max_value,
      form_config: data.form_config,
      status: data.status ?? 1,
      sort_order: data.sort_order ?? 0
    };

    const insertId = await HealthIndicatorTypeRepository.create(indicatorTypeData);
    const indicatorType = await HealthIndicatorTypeRepository.findById(insertId);

    if (!indicatorType) {
      throw new Error('创建健康指标类型失败');
    }

    return this.toResponse(indicatorType);
  }

  static async getIndicatorTypeById(id: number): Promise<HealthIndicatorTypeResponse> {
    const indicatorType = await HealthIndicatorTypeRepository.findById(id);
    if (!indicatorType) {
      throw new Error('健康指标类型不存在');
    }
    return this.toResponse(indicatorType);
  }

  static async getIndicatorTypeByCode(code: string): Promise<HealthIndicatorTypeResponse> {
    const indicatorType = await HealthIndicatorTypeRepository.findByCode(code);
    if (!indicatorType) {
      throw new Error('健康指标类型不存在');
    }
    return this.toResponse(indicatorType);
  }

  static async getIndicatorTypes(status?: number): Promise<HealthIndicatorTypeResponse[]> {
    const indicatorTypes = await HealthIndicatorTypeRepository.findAll(status);
    return indicatorTypes.map(item => this.toResponse(item));
  }

  static async updateIndicatorType(id: number, data: UpdateHealthIndicatorTypeRequest): Promise<HealthIndicatorTypeResponse> {
    const existingIndicatorType = await HealthIndicatorTypeRepository.findById(id);
    if (!existingIndicatorType) {
      throw new Error('健康指标类型不存在');
    }

    if (data.indicator_code && data.indicator_code !== existingIndicatorType.indicator_code) {
      const existingByCode = await HealthIndicatorTypeRepository.findByCode(data.indicator_code);
      if (existingByCode) {
        throw new Error('指标编码已存在');
      }
    }

    const updateData: Partial<Omit<HealthIndicatorType, 'id' | 'created_at' | 'updated_at'>> = {};
    if (data.indicator_code !== undefined) updateData.indicator_code = data.indicator_code;
    if (data.indicator_name !== undefined) updateData.indicator_name = data.indicator_name;
    if (data.unit !== undefined) updateData.unit = data.unit;
    if (data.min_value !== undefined) updateData.min_value = data.min_value;
    if (data.max_value !== undefined) updateData.max_value = data.max_value;
    if (data.form_config !== undefined) updateData.form_config = data.form_config;
    if (data.status !== undefined) updateData.status = data.status;
    if (data.sort_order !== undefined) updateData.sort_order = data.sort_order;

    const success = await HealthIndicatorTypeRepository.update(id, updateData);
    if (!success) {
      throw new Error('更新健康指标类型失败');
    }

    const indicatorType = await HealthIndicatorTypeRepository.findById(id);
    if (!indicatorType) {
      throw new Error('获取更新后的健康指标类型失败');
    }

    return this.toResponse(indicatorType);
  }

  static async deleteIndicatorType(id: number): Promise<boolean> {
    const indicatorType = await HealthIndicatorTypeRepository.findById(id);
    if (!indicatorType) {
      throw new Error('健康指标类型不存在');
    }

    const success = await HealthIndicatorTypeRepository.delete(id);
    if (!success) {
      throw new Error('删除健康指标类型失败');
    }

    return true;
  }

  private static toResponse(indicatorType: HealthIndicatorType): HealthIndicatorTypeResponse {
    return {
      id: indicatorType.id!,
      indicator_code: indicatorType.indicator_code,
      indicator_name: indicatorType.indicator_name,
      unit: indicatorType.unit,
      min_value: indicatorType.min_value,
      max_value: indicatorType.max_value,
      form_config: indicatorType.form_config,
      status: indicatorType.status,
      sort_order: indicatorType.sort_order,
      created_at: indicatorType.created_at || '',
      updated_at: indicatorType.updated_at || ''
    };
  }
}
