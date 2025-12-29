import { HealthDataRecordRepository } from '../repositories/healthDataRecord.repository';
import { HealthIndicatorTypeRepository } from '../repositories/healthIndicatorType.repository';
import { HealthDataRecord, HealthDataRecordResponse } from '../types/healthDataRecord';
import { CreateHealthDataRecordRequest, UpdateHealthDataRecordRequest } from '../dto/requests/healthDataRecord.dto';
import { HealthDataRecordHistoryRepository } from '../repositories/healthDataRecordHistory.repository';
import { NotFoundError } from '../utils/errors';

export class HealthDataRecordService {
  static async createHealthDataRecord(data: CreateHealthDataRecordRequest): Promise<HealthDataRecordResponse> {
    const indicatorType = await HealthIndicatorTypeRepository.findById(data.indicator_type_id);
    if (!indicatorType) {
      throw new NotFoundError('健康指标类型不存在');
    }

    await this.validateMeasureValue(data.indicator_type_id, data.measure_value);

    const measureTime = new Date(data.measure_time);
    const now = new Date();
    if (measureTime > now) {
      throw new Error('测量时间不能晚于当前时间');
    }

    const duplicate = await HealthDataRecordRepository.findDuplicate(
      data.elder_id,
      data.indicator_type_id,
      data.measure_time
    );
    if (duplicate) {
      throw new Error('同一老人同一指标同一时间点的数据已存在');
    }

    const recordData: Omit<HealthDataRecord, 'id' | 'created_at' | 'updated_at'> = {
      elder_id: data.elder_id,
      indicator_type_id: data.indicator_type_id,
      measure_time: data.measure_time,
      measure_value: data.measure_value,
      measure_context: data.measure_context,
      remark: data.remark,
      data_source: data.data_source || 'MANUAL',
      input_user_id: data.input_user_id,
      input_user_type: data.input_user_type,
      is_deleted: 0
    };

    const insertId = await HealthDataRecordRepository.create(recordData);
    const record = await HealthDataRecordRepository.findById(insertId);

    if (!record) {
      throw new Error('创建健康数据记录失败');
    }

    await HealthDataRecordHistoryRepository.create({
      health_record_id: insertId,
      operation_type: 'INSERT',
      before_value: null,
      after_value: record.measure_value,
      operation_reason: '创建记录',
      operator_id: data.input_user_id,
      operator_type: data.input_user_type
    });

    return await this.toResponse(record);
  }

  static async getHealthDataRecordById(id: number): Promise<HealthDataRecordResponse> {
    const record = await HealthDataRecordRepository.findById(id);
    if (!record || record.is_deleted === 1) {
      throw new NotFoundError('健康数据记录不存在');
    }
    return await this.toResponse(record);
  }

  static async getHealthDataRecords(
    page: number,
    pageSize: number,
    elderId?: number,
    indicatorTypeId?: number,
    startDate?: string,
    endDate?: string,
    dataSource?: string
  ): Promise<{ items: HealthDataRecordResponse[]; total: number }> {
    const { items, total } = await HealthDataRecordRepository.findByElderId(
      elderId,
      indicatorTypeId,
      startDate,
      endDate,
      page,
      pageSize
    );

    const filteredItems = dataSource
      ? items.filter(item => item.data_source === dataSource)
      : items;

    const responses = await Promise.all(
      filteredItems.map(item => this.toResponse(item))
    );

    return {
      items: responses,
      total: dataSource ? filteredItems.length : total
    };
  }

  static async updateHealthDataRecord(id: number, data: UpdateHealthDataRecordRequest): Promise<HealthDataRecordResponse> {
    const existingRecord = await HealthDataRecordRepository.findById(id);
    if (!existingRecord || existingRecord.is_deleted === 1) {
      throw new NotFoundError('健康数据记录不存在');
    }

    const recordDate = new Date(existingRecord.created_at!);
    const now = new Date();
    const daysDiff = Math.floor((now.getTime() - recordDate.getTime()) / (1000 * 60 * 60 * 24));
    if (daysDiff > 7) {
      throw new Error('只能修改最近7天内录入的数据');
    }

    if (data.indicator_type_id) {
      const indicatorType = await HealthIndicatorTypeRepository.findById(data.indicator_type_id);
      if (!indicatorType) {
        throw new NotFoundError('健康指标类型不存在');
      }
    }

    if (data.measure_value) {
      const indicatorTypeId = data.indicator_type_id || existingRecord.indicator_type_id;
      await this.validateMeasureValue(indicatorTypeId, data.measure_value);
    }

    const updateData: Partial<Omit<HealthDataRecord, 'id' | 'elder_id' | 'input_user_id' | 'input_user_type' | 'created_at' | 'updated_at'>> = {};
    if (data.indicator_type_id !== undefined) updateData.indicator_type_id = data.indicator_type_id;
    if (data.measure_time !== undefined) updateData.measure_time = data.measure_time;
    if (data.measure_value !== undefined) updateData.measure_value = data.measure_value;
    if (data.measure_context !== undefined) updateData.measure_context = data.measure_context;
    if (data.remark !== undefined) updateData.remark = data.remark;
    if (data.data_source !== undefined) updateData.data_source = data.data_source;

    const success = await HealthDataRecordRepository.update(id, updateData);
    if (!success) {
      throw new Error('更新健康数据记录失败');
    }

    const record = await HealthDataRecordRepository.findById(id);
    if (!record) {
      throw new Error('获取更新后的健康数据记录失败');
    }

    await HealthDataRecordHistoryRepository.create({
      health_record_id: id,
      operation_type: 'UPDATE',
      before_value: existingRecord.measure_value,
      after_value: record.measure_value,
      operation_reason: data.operation_reason || '修改记录',
      operator_id: existingRecord.input_user_id,
      operator_type: existingRecord.input_user_type
    });

    return await this.toResponse(record);
  }

  static async deleteHealthDataRecord(id: number, reason?: string): Promise<boolean> {
    const record = await HealthDataRecordRepository.findById(id);
    if (!record || record.is_deleted === 1) {
      throw new NotFoundError('健康数据记录不存在');
    }

    const recordDate = new Date(record.created_at!);
    const now = new Date();
    const daysDiff = Math.floor((now.getTime() - recordDate.getTime()) / (1000 * 60 * 60 * 24));
    if (daysDiff > 7) {
      throw new Error('只能删除最近7天内录入的数据');
    }

    const success = await HealthDataRecordRepository.softDelete(id);
    if (!success) {
      throw new Error('删除健康数据记录失败');
    }

    await HealthDataRecordHistoryRepository.create({
      health_record_id: id,
      operation_type: 'DELETE',
      before_value: record.measure_value,
      after_value: null,
      operation_reason: reason || '删除记录',
      operator_id: record.input_user_id,
      operator_type: record.input_user_type
    });

    return true;
  }

  static async getHealthDataRecordHistory(id: number): Promise<any[]> {
    const record = await HealthDataRecordRepository.findById(id);
    if (!record || record.is_deleted === 1) {
      throw new Error('健康数据记录不存在');
    }

    const history = await HealthDataRecordHistoryRepository.findByHealthRecordId(id);
    return history.map(h => ({
      id: h.id,
      health_record_id: h.health_record_id,
      operation_type: h.operation_type,
      before_value: h.before_value,
      after_value: h.after_value,
      operation_reason: h.operation_reason,
      operator_id: h.operator_id,
      operator_type: h.operator_type,
      created_at: h.created_at
    }));
  }

  private static async validateMeasureValue(indicatorTypeId: number, measureValue: any): Promise<void> {
    const indicatorType = await HealthIndicatorTypeRepository.findById(indicatorTypeId);
    if (!indicatorType) {
      throw new NotFoundError('健康指标类型不存在');
    }

    const indicatorCode = indicatorType.indicator_code;

    switch (indicatorCode) {
      case 'BP':
        if (!measureValue.systolic || !measureValue.diastolic) {
          throw new Error('血压数据必须包含收缩压和舒张压');
        }
        const systolic = parseFloat(measureValue.systolic);
        const diastolic = parseFloat(measureValue.diastolic);
        if (isNaN(systolic) || isNaN(diastolic)) {
          throw new Error('收缩压和舒张压必须是数字');
        }
        if (systolic < 60 || systolic > 250) {
          throw new Error('收缩压范围：60-250 mmHg');
        }
        if (diastolic < 40 || diastolic > 150) {
          throw new Error('舒张压范围：40-150 mmHg');
        }
        if (systolic <= diastolic) {
          throw new Error('收缩压必须大于舒张压');
        }
        break;

      case 'BG':
        if (!measureValue.value) {
          throw new Error('血糖数据必须包含血糖值');
        }
        const bgValue = parseFloat(measureValue.value);
        if (isNaN(bgValue)) {
          throw new Error('血糖值必须是数字');
        }
        if (bgValue < 1.0 || bgValue > 30.0) {
          throw new Error('血糖范围：1.0-30.0 mmol/L');
        }
        break;

      case 'WT':
        if (!measureValue.value) {
          throw new Error('体重数据必须包含体重值');
        }
        const wtValue = parseFloat(measureValue.value);
        if (isNaN(wtValue)) {
          throw new Error('体重值必须是数字');
        }
        if (wtValue < 20 || wtValue > 200) {
          throw new Error('体重范围：20-200 kg');
        }
        break;

      case 'HR':
        if (!measureValue.value) {
          throw new Error('心率数据必须包含心率值');
        }
        const hrValue = parseFloat(measureValue.value);
        if (isNaN(hrValue)) {
          throw new Error('心率值必须是数字');
        }
        if (hrValue < 30 || hrValue > 250) {
          throw new Error('心率范围：30-250 次/分钟');
        }
        break;

      default:
        break;
    }
  }

  private static async toResponse(record: HealthDataRecord): Promise<HealthDataRecordResponse> {
    const indicatorType = await HealthIndicatorTypeRepository.findById(record.indicator_type_id);

    return {
      id: record.id!,
      elder_id: record.elder_id,
      indicator_type_id: record.indicator_type_id,
      indicator_type: indicatorType ? {
        id: indicatorType.id!,
        indicator_code: indicatorType.indicator_code,
        indicator_name: indicatorType.indicator_name,
        unit: indicatorType.unit
      } : undefined,
      measure_time: record.measure_time,
      measure_value: record.measure_value,
      measure_context: record.measure_context,
      remark: record.remark,
      data_source: record.data_source,
      input_user_id: record.input_user_id,
      input_user_type: record.input_user_type,
      created_at: record.created_at || '',
      updated_at: record.updated_at || ''
    };
  }
}
