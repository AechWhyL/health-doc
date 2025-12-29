import { HealthRecordRepository } from '../repositories/healthRecord.repository';
import { HealthRecord } from '../types/healthRecord';
import { CreateHealthRecordRequest, UpdateHealthRecordRequest, HealthRecordResponse } from '../dto/requests/healthRecord.dto';
import { NotFoundError } from '../utils/errors';

export class HealthRecordService {
  static async createHealthRecord(data: CreateHealthRecordRequest): Promise<HealthRecordResponse> {
    const recordData: Omit<HealthRecord, 'id' | 'created_at' | 'updated_at'> = {
      elder_id: data.elder_id,
      category_id: data.category_id,
      record_title: data.record_title,
      record_content: data.record_content,
      record_date: data.record_date
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
    categoryId?: number,
    startDate?: string,
    endDate?: string
  ): Promise<{ items: HealthRecordResponse[]; total: number }> {
    let where = '1=1';
    const params: any[] = [];

    if (elderId) {
      where += ' AND elder_id = ?';
      params.push(elderId);
    }
    if (categoryId) {
      where += ' AND category_id = ?';
      params.push(categoryId);
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
    if (data.category_id !== undefined) updateData.category_id = data.category_id;
    if (data.record_title !== undefined) updateData.record_title = data.record_title;
    if (data.record_content !== undefined) updateData.record_content = data.record_content;
    if (data.record_date !== undefined) updateData.record_date = data.record_date;

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
      category_id: record.category_id,
      record_title: record.record_title,
      record_content: record.record_content,
      record_date: record.record_date,
      created_at: record.created_at || '',
      updated_at: record.updated_at || ''
    };
  }
}
