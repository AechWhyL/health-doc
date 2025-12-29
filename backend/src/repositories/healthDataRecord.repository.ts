import { Database } from '../config/database';
import { HealthDataRecord } from '../types/healthDataRecord';

export class HealthDataRecordRepository {
  static async create(data: Omit<HealthDataRecord, 'id' | 'created_at' | 'updated_at'>): Promise<number> {
    const sql = `
      INSERT INTO health_data_record (elder_id, indicator_type_id, measure_time, measure_value, measure_context, remark, data_source, input_user_id, input_user_type, is_deleted)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.elder_id,
      data.indicator_type_id,
      data.measure_time,
      JSON.stringify(data.measure_value),
      data.measure_context ? JSON.stringify(data.measure_context) : null,
      data.remark || null,
      data.data_source,
      data.input_user_id,
      data.input_user_type,
      data.is_deleted
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<HealthDataRecord | null> {
    const sql = 'SELECT * FROM health_data_record WHERE id = ?';
    const result = await Database.queryOne<HealthDataRecord>(sql, [id]);
    if (result) {
      if (result.measure_value && typeof result.measure_value === 'string') {
        result.measure_value = JSON.parse(result.measure_value as any);
      }
      if (result.measure_context && typeof result.measure_context === 'string') {
        result.measure_context = JSON.parse(result.measure_context as any);
      }
    }
    return result;
  }

  static async findByElderId(
    elderId?: number,
    indicatorTypeId?: number,
    startTime?: string,
    endTime?: string,
    page: number = 1,
    pageSize: number = 10
  ): Promise<{ items: HealthDataRecord[]; total: number }> {
    let where = 'is_deleted = 0';
    const params: any[] = [];

    if (elderId !== undefined && elderId !== null) {
      where += ' AND elder_id = ?';
      params.push(elderId);
    }
    if (indicatorTypeId !== undefined && indicatorTypeId !== null) {
      where += ' AND indicator_type_id = ?';
      params.push(indicatorTypeId);
    }
    if (startTime !== undefined && startTime !== null) {
      where += ' AND measure_time >= ?';
      params.push(startTime);
    }
    if (endTime !== undefined && endTime !== null) {
      where += ' AND measure_time <= ?';
      params.push(endTime);
    }

    return await Database.paginate<HealthDataRecord>('health_data_record', page, pageSize, where, params, 'measure_time DESC').then(result => ({
      items: result.items.map(item => {
        if (item.measure_value && typeof item.measure_value === 'string') {
          item.measure_value = JSON.parse(item.measure_value as any);
        }
        if (item.measure_context && typeof item.measure_context === 'string') {
          item.measure_context = JSON.parse(item.measure_context as any);
        }
        return item;
      }),
      total: result.total
    }));
  }

  static async findDuplicate(
    elderId: number,
    indicatorTypeId: number,
    measureTime: string
  ): Promise<HealthDataRecord | null> {
    const sql = `
      SELECT * FROM health_data_record 
      WHERE elder_id = ? AND indicator_type_id = ? AND measure_time = ? AND is_deleted = 0
      LIMIT 1
    `;
    const result = await Database.queryOne<HealthDataRecord>(sql, [elderId, indicatorTypeId, measureTime]);
    if (result) {
      if (result.measure_value && typeof result.measure_value === 'string') {
        result.measure_value = JSON.parse(result.measure_value as any);
      }
      if (result.measure_context && typeof result.measure_context === 'string') {
        result.measure_context = JSON.parse(result.measure_context as any);
      }
    }
    return result;
  }

  static async update(id: number, data: Partial<Omit<HealthDataRecord, 'id' | 'elder_id' | 'input_user_id' | 'input_user_type' | 'created_at' | 'updated_at'>>): Promise<boolean> {
    const fields: string[] = [];
    const params: any[] = [];

    if (data.indicator_type_id !== undefined) {
      fields.push('indicator_type_id = ?');
      params.push(data.indicator_type_id);
    }
    if (data.measure_time !== undefined) {
      fields.push('measure_time = ?');
      params.push(data.measure_time);
    }
    if (data.measure_value !== undefined) {
      fields.push('measure_value = ?');
      params.push(JSON.stringify(data.measure_value));
    }
    if (data.measure_context !== undefined) {
      fields.push('measure_context = ?');
      params.push(data.measure_context ? JSON.stringify(data.measure_context) : null);
    }
    if (data.remark !== undefined) {
      fields.push('remark = ?');
      params.push(data.remark);
    }
    if (data.data_source !== undefined) {
      fields.push('data_source = ?');
      params.push(data.data_source);
    }
    if (data.is_deleted !== undefined) {
      fields.push('is_deleted = ?');
      params.push(data.is_deleted);
    }

    if (fields.length === 0) {
      return false;
    }

    params.push(id);
    const sql = `UPDATE health_data_record SET ${fields.join(', ')} WHERE id = ?`;
    const result = await Database.update(sql, params);
    return result > 0;
  }

  static async softDelete(id: number): Promise<boolean> {
    const sql = 'UPDATE health_data_record SET is_deleted = 1 WHERE id = ?';
    const result = await Database.update(sql, [id]);
    return result > 0;
  }

  static async getRecentRecords(elderId: number, days: number = 7): Promise<HealthDataRecord[]> {
    const sql = `
      SELECT * FROM health_data_record 
      WHERE elder_id = ? AND is_deleted = 0 
      AND measure_time >= DATE_SUB(NOW(), INTERVAL ? DAY)
      ORDER BY measure_time DESC
    `;
    const results = await Database.query<HealthDataRecord>(sql, [elderId, days]);
    return results.map(item => {
      if (item.measure_value && typeof item.measure_value === 'string') {
        item.measure_value = JSON.parse(item.measure_value as any);
      }
      if (item.measure_context && typeof item.measure_context === 'string') {
        item.measure_context = JSON.parse(item.measure_context as any);
      }
      return item;
    });
  }
}
