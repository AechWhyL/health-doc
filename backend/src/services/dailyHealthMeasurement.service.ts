import { DailyHealthMeasurementRepository } from '../repositories/dailyHealthMeasurement.repository';
import { DailyHealthMeasurement } from '../types/dailyHealthMeasurement';
import {
  CreateDailyHealthMeasurementRequest,
  UpdateDailyHealthMeasurementRequest,
  DailyHealthMeasurementResponse,
  QueryDailyHealthMeasurementRequest
} from '../dto/requests/dailyHealthMeasurement.dto';
import { NotFoundError } from '../utils/errors';
import { bpLevel, glucoseFpgLevel, glucosePpgLevel } from './ruleEngine.service';

export class DailyHealthMeasurementService {
  static async createDailyHealthMeasurement(
    data: CreateDailyHealthMeasurementRequest
  ): Promise<DailyHealthMeasurementResponse> {
    const recordData: Omit<DailyHealthMeasurement, 'id' | 'created_at' | 'updated_at'> = {
      elder_id: data.elder_id,
      measured_at: data.measured_at,
      sbp: data.sbp,
      dbp: data.dbp,
      fpg: data.fpg,
      ppg_2h: data.ppg_2h,
      weight: data.weight,
      steps: data.steps,
      source: data.source || 'MANUAL',
      remark: data.remark
    };

    const insertId = await DailyHealthMeasurementRepository.create(recordData);
    const record = await DailyHealthMeasurementRepository.findById(insertId);

    if (!record) {
      throw new Error('创建日常健康数据记录失败');
    }

    return this.toResponse(record);
  }

  static async getDailyHealthMeasurementById(id: number): Promise<DailyHealthMeasurementResponse> {
    const record = await DailyHealthMeasurementRepository.findById(id);
    if (!record) {
      throw new NotFoundError('日常健康数据记录不存在');
    }
    return this.toResponse(record);
  }

  static async getDailyHealthMeasurementList(
    query: QueryDailyHealthMeasurementRequest
  ): Promise<{ items: DailyHealthMeasurementResponse[]; total: number }> {
    const page = query.page || 1;
    const pageSize = query.pageSize || 10;
    const elderId = query.elder_id;
    const includeJudgment = query.include_judgment === true;

    const { items, total } = await DailyHealthMeasurementRepository.findAll(page, pageSize, elderId);
    return {
      items: items.map(item => this.toResponse(item, includeJudgment)),
      total
    };
  }

  static async updateDailyHealthMeasurement(
    id: number,
    data: UpdateDailyHealthMeasurementRequest
  ): Promise<DailyHealthMeasurementResponse> {
    const existingRecord = await DailyHealthMeasurementRepository.findById(id);
    if (!existingRecord) {
      throw new NotFoundError('日常健康数据记录不存在');
    }

    const updateData: Partial<
      Omit<DailyHealthMeasurement, 'id' | 'elder_id' | 'created_at' | 'updated_at'>
    > = {};

    if (data.measured_at !== undefined) updateData.measured_at = data.measured_at;
    if (data.sbp !== undefined) updateData.sbp = data.sbp;
    if (data.dbp !== undefined) updateData.dbp = data.dbp;
    if (data.fpg !== undefined) updateData.fpg = data.fpg;
    if (data.ppg_2h !== undefined) updateData.ppg_2h = data.ppg_2h;
    if (data.weight !== undefined) updateData.weight = data.weight;
    if (data.steps !== undefined) updateData.steps = data.steps;
    if (data.source !== undefined) updateData.source = data.source;
    if (data.remark !== undefined) updateData.remark = data.remark;

    const success = await DailyHealthMeasurementRepository.update(id, updateData);
    if (!success) {
      throw new Error('更新日常健康数据记录失败');
    }

    const record = await DailyHealthMeasurementRepository.findById(id);
    if (!record) {
      throw new Error('获取更新后的日常健康数据记录失败');
    }

    return this.toResponse(record);
  }

  static async deleteDailyHealthMeasurement(id: number): Promise<boolean> {
    const existingRecord = await DailyHealthMeasurementRepository.findById(id);
    if (!existingRecord) {
      throw new NotFoundError('日常健康数据记录不存在');
    }

    const success = await DailyHealthMeasurementRepository.delete(id);
    if (!success) {
      throw new Error('删除日常健康数据记录失败');
    }

    return true;
  }

  private static toResponse(record: DailyHealthMeasurement, includeJudgment: boolean = false): DailyHealthMeasurementResponse {
    const response: DailyHealthMeasurementResponse = {
      id: record.id!,
      elder_id: record.elder_id,
      measured_at: record.measured_at,
      sbp: record.sbp,
      dbp: record.dbp,
      fpg: record.fpg,
      ppg_2h: record.ppg_2h,
      weight: record.weight,
      steps: record.steps,
      source: record.source,
      remark: record.remark,
      created_at: record.created_at || '',
      updated_at: record.updated_at || ''
    };

    if (includeJudgment) {
      const bp = bpLevel(record.sbp, record.dbp);
      const fpg = glucoseFpgLevel(record.fpg);
      const ppg = glucosePpgLevel(record.ppg_2h);

      response.judgment = {
        bp_level: bp || undefined,
        fpg_level: fpg || undefined,
        ppg_level: ppg || undefined
      };
    }

    return response;
  }
}

