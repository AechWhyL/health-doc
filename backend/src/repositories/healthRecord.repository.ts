import { Database } from '../config/database';
import { HealthRecord } from '../types/healthRecord';

export class HealthRecordRepository {
  static async create(data: Omit<HealthRecord, 'id' | 'created_at' | 'updated_at'>): Promise<number> {
    const sql = `
      INSERT INTO health_record (elder_id, record_type, record_title, record_date, content_structured)
      VALUES (?, ?, ?, ?, ?)
    `;
    const params = [
      data.elder_id,
      data.record_type,
      data.record_title,
      data.record_date,
      JSON.stringify(data.content_structured)
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<HealthRecord | null> {
    const sql = 'SELECT * FROM health_record WHERE id = ?';
    const result = await Database.queryOne<HealthRecord>(sql, [id]);
    if (result && result.content_structured && typeof (result as any).content_structured === 'string') {
      (result as any).content_structured = JSON.parse((result as any).content_structured);
    }
    return result;
  }

  static async findAll(page: number, pageSize: number, where: string = '1=1', params: any[] = [], orderBy: string = 'created_at DESC'): Promise<{ items: HealthRecord[]; total: number }> {
    const result = await Database.paginate<HealthRecord>('health_record', page, pageSize, where, params, orderBy);
    return {
      items: result.items.map(item => {
        if (item.content_structured && typeof (item as any).content_structured === 'string') {
          (item as any).content_structured = JSON.parse((item as any).content_structured);
        }
        return item;
      }),
      total: result.total
    };
  }

  static async findByElderId(elderId: number): Promise<HealthRecord[]> {
    const sql = 'SELECT * FROM health_record WHERE elder_id = ? ORDER BY record_date DESC, created_at DESC';
    const results = await Database.query<HealthRecord>(sql, [elderId]);
    return results.map(item => {
      if (item.content_structured && typeof (item as any).content_structured === 'string') {
        (item as any).content_structured = JSON.parse((item as any).content_structured);
      }
      return item;
    });
  }

  static async update(id: number, data: Partial<Omit<HealthRecord, 'id' | 'elder_id' | 'created_at' | 'updated_at'>>): Promise<boolean> {
    const fields: string[] = [];
    const params: any[] = [];

    if (data.record_type !== undefined) {
      fields.push('record_type = ?');
      params.push(data.record_type);
    }
    if (data.record_title !== undefined) {
      fields.push('record_title = ?');
      params.push(data.record_title);
    }
    if (data.record_date !== undefined) {
      fields.push('record_date = ?');
      params.push(data.record_date);
    }
    if (data.content_structured !== undefined) {
      fields.push('content_structured = ?');
      params.push(JSON.stringify(data.content_structured));
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
