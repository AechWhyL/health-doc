import { Database } from '../config/database';
import { HealthRecord } from '../types/healthRecord';

export class HealthRecordRepository {
  static async create(data: Omit<HealthRecord, 'id' | 'created_at' | 'updated_at'>): Promise<number> {
    const sql = `
      INSERT INTO health_record (elder_id, category_id, record_title, record_content, record_date)
      VALUES (?, ?, ?, ?, ?)
    `;
    const params = [
      data.elder_id,
      data.category_id,
      data.record_title,
      data.record_content,
      data.record_date
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<HealthRecord | null> {
    const sql = 'SELECT * FROM health_record WHERE id = ?';
    return await Database.queryOne<HealthRecord>(sql, [id]);
  }

  static async findAll(page: number, pageSize: number, where: string = '1=1', params: any[] = [], orderBy: string = 'created_at DESC'): Promise<{ items: HealthRecord[]; total: number }> {
    return await Database.paginate<HealthRecord>('health_record', page, pageSize, where, params, orderBy);
  }

  static async findByElderId(elderId: number): Promise<HealthRecord[]> {
    const sql = 'SELECT * FROM health_record WHERE elder_id = ? ORDER BY record_date DESC, created_at DESC';
    return await Database.query<HealthRecord>(sql, [elderId]);
  }

  static async update(id: number, data: Partial<Omit<HealthRecord, 'id' | 'elder_id' | 'created_at' | 'updated_at'>>): Promise<boolean> {
    const fields: string[] = [];
    const params: any[] = [];

    if (data.category_id !== undefined) {
      fields.push('category_id = ?');
      params.push(data.category_id);
    }
    if (data.record_title !== undefined) {
      fields.push('record_title = ?');
      params.push(data.record_title);
    }
    if (data.record_content !== undefined) {
      fields.push('record_content = ?');
      params.push(data.record_content);
    }
    if (data.record_date !== undefined) {
      fields.push('record_date = ?');
      params.push(data.record_date);
    }

    if (fields.length === 0) {
      return false;
    }

    params.push(id);
    const sql = `UPDATE health_record SET ${fields.join(', ')} WHERE id = ?`;
    const result = await Database.update(sql, params);
    return result > 0;
  }

  static async delete(id: number): Promise<boolean> {
    const sql = 'DELETE FROM health_record WHERE id = ?';
    const result = await Database.delete(sql, [id]);
    return result > 0;
  }

  static async deleteByElderId(elderId: number): Promise<boolean> {
    const sql = 'DELETE FROM health_record WHERE elder_id = ?';
    const result = await Database.delete(sql, [elderId]);
    return result > 0;
  }
}
