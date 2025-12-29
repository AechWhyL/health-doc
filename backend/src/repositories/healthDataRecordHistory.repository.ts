import { Database } from '../config/database';
import { HealthDataRecordHistory } from '../types/healthDataRecord';

export class HealthDataRecordHistoryRepository {
  static async create(data: Omit<HealthDataRecordHistory, 'id' | 'created_at'>): Promise<number> {
    const sql = `
      INSERT INTO health_record_history (health_record_id, operation_type, before_value, after_value, operation_reason, operator_id, operator_type)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.health_record_id,
      data.operation_type,
      data.before_value ? JSON.stringify(data.before_value) : null,
      data.after_value ? JSON.stringify(data.after_value) : null,
      data.operation_reason || null,
      data.operator_id,
      data.operator_type
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<HealthDataRecordHistory | null> {
    const sql = 'SELECT * FROM health_record_history WHERE id = ?';
    const result = await Database.queryOne<HealthDataRecordHistory>(sql, [id]);
    if (result) {
      if (result.before_value && typeof result.before_value === 'string') {
        result.before_value = JSON.parse(result.before_value as any);
      }
      if (result.after_value && typeof result.after_value === 'string') {
        result.after_value = JSON.parse(result.after_value as any);
      }
    }
    return result;
  }

  static async findByHealthRecordId(healthRecordId: number): Promise<HealthDataRecordHistory[]> {
    const sql = 'SELECT * FROM health_record_history WHERE health_record_id = ? ORDER BY created_at DESC';
    const results = await Database.query<HealthDataRecordHistory>(sql, [healthRecordId]);
    return results.map(item => {
      if (item.before_value && typeof item.before_value === 'string') {
        item.before_value = JSON.parse(item.before_value as any);
      }
      if (item.after_value && typeof item.after_value === 'string') {
        item.after_value = JSON.parse(item.after_value as any);
      }
      return item;
    });
  }

  static async findByOperationType(operationType: string, page: number = 1, pageSize: number = 10): Promise<{ items: HealthDataRecordHistory[]; total: number }> {
    return await Database.paginate<HealthDataRecordHistory>('health_record_history', page, pageSize, 'operation_type = ?', [operationType], 'created_at DESC');
  }

  static async findByOperator(operatorId: number, operatorType?: string, page: number = 1, pageSize: number = 10): Promise<{ items: HealthDataRecordHistory[]; total: number }> {
    let where = 'operator_id = ?';
    const params: any[] = [operatorId];

    if (operatorType) {
      where += ' AND operator_type = ?';
      params.push(operatorType);
    }

    return await Database.paginate<HealthDataRecordHistory>('health_record_history', page, pageSize, where, params, 'created_at DESC');
  }

  static async findByDateRange(startTime: string, endTime: string, page: number = 1, pageSize: number = 10): Promise<{ items: HealthDataRecordHistory[]; total: number }> {
    return await Database.paginate<HealthDataRecordHistory>('health_record_history', page, pageSize, 'created_at >= ? AND created_at <= ?', [startTime, endTime], 'created_at DESC');
  }
}
