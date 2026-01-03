import { HealthRecordRepository } from '../repositories/healthRecord.repository';
import { HealthRecord, HealthRecordType } from '../types/healthRecord';
import { CreateHealthRecordRequest, UpdateHealthRecordRequest, HealthRecordResponse } from '../dto/requests/healthRecord.dto';
import { NotFoundError } from '../utils/errors';

export class HealthRecordService {
  static async createHealthRecord(data: CreateHealthRecordRequest): Promise<HealthRecordResponse> {
    const recordData: Omit<HealthRecord, 'id' | 'created_at' | 'updated_at'> = {
      elder_id: data.elder_id,
      record_type: data.record_type,
      record_title: data.record_title,
      record_date: data.record_date,
      content_structured: data.content_structured
    };

    const insertId = await HealthRecordRepository.create(recordData);
    const record = await HealthRecordRepository.findById(insertId);

    if (!record) {
      throw new Error('创建健康记录失败');
    }

    return this.toResponse(record);
  }

  static async getHealthRecordById(id: number): Promise<HealthRecordResponse> {
    const record = await HealthRecordRepository.findById(id);
    if (!record) {
      throw new NotFoundError('健康记录不存在');
    }
    return this.toResponse(record);
  }

  static async getHealthRecordList(
    page: number,
    pageSize: number,
    elderId?: number,
    recordType?: HealthRecordType,
    startDate?: string,
    endDate?: string
  ): Promise<{ items: HealthRecordResponse[]; total: number }> {
    let where = '1=1';
    const params: any[] = [];

    if (elderId) {
      where += ' AND elder_id = ?';
      params.push(elderId);
    }
    if (recordType) {
      where += ' AND record_type = ?';
      params.push(recordType);
    }
    if (startDate) {
      where += ' AND record_date >= ?';
      params.push(startDate);
    }
    if (endDate) {
      where += ' AND record_date <= ?';
      params.push(endDate);
    }

    const { items, total } = await HealthRecordRepository.findAll(page, pageSize, where, params);
    return {
      items: items.map(item => this.toResponse(item)),
      total
    };
  }

  static async getHealthRecordsByElderId(elderId: number): Promise<HealthRecordResponse[]> {
    const records = await HealthRecordRepository.findByElderId(elderId);
    return records.map(item => this.toResponse(item));
  }

  static async updateHealthRecord(id: number, data: UpdateHealthRecordRequest): Promise<HealthRecordResponse> {
    const existingRecord = await HealthRecordRepository.findById(id);
    if (!existingRecord) {
      throw new NotFoundError('健康记录不存在');
    }

    const updateData: Partial<Omit<HealthRecord, 'id' | 'elder_id' | 'created_at' | 'updated_at'>> = {};
    if (data.record_type !== undefined) updateData.record_type = data.record_type;
    if (data.record_title !== undefined) updateData.record_title = data.record_title;
    if (data.record_date !== undefined) updateData.record_date = data.record_date;
    if (data.content_structured !== undefined) updateData.content_structured = data.content_structured;

    const success = await HealthRecordRepository.update(id, updateData);
    if (!success) {
      throw new Error('更新健康记录失败');
    }

    const record = await HealthRecordRepository.findById(id);
    if (!record) {
      throw new Error('获取更新后的健康记录失败');
    }

    return this.toResponse(record);
  }

  static async deleteHealthRecord(id: number): Promise<boolean> {
    const record = await HealthRecordRepository.findById(id);
    if (!record) {
      throw new NotFoundError('健康记录不存在');
    }

    const success = await HealthRecordRepository.delete(id);
    if (!success) {
      throw new Error('删除健康记录失败');
    }

    return true;
  }

  private static toResponse(record: HealthRecord): HealthRecordResponse {
    return {
      id: record.id!,
      elder_id: record.elder_id,
      record_type: record.record_type,
      record_title: record.record_title,
      record_date: record.record_date,
      content_structured: record.content_structured,
      created_at: record.created_at || '',
      updated_at: record.updated_at || ''
    };
  }
}
