import { Database } from '../config/database';
import { HealthRecord } from '../types/healthRecord';

export class HealthRecordRepository {
  static async create(data: Omit<HealthRecord, 'id' | 'created_at' | 'updated_at'>): Promise<number> {
    const sql = `
      INSERT INTO health_record (elder_id, record_type, record_title, record_date, content_structured, creator_id)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.elder_id,
      data.record_type,
      data.record_title,
      data.record_date,
      JSON.stringify(data.content_structured),
      data.creator_id
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<HealthRecord | null> {
    const sql = `
      SELECT hr.*, u.real_name as creator_name 
      FROM health_record hr 
      LEFT JOIN users u ON hr.creator_id = u.id 
      WHERE hr.id = ?
    `;
    const result = await Database.queryOne<HealthRecord>(sql, [id]);
    if (result && result.content_structured && typeof (result as any).content_structured === 'string') {
      (result as any).content_structured = JSON.parse((result as any).content_structured);
    }
    return result;
  }

  static async findAll(page: number, pageSize: number, where: string = '1=1', params: any[] = [], sortBy: string = 'created_at', sortOrder: string = 'desc'): Promise<{ items: HealthRecord[]; total: number }> {
    const orderBy = `${sortBy} ${sortOrder.toUpperCase()}`;
    const offset = (page - 1) * pageSize;

    // Custom query to support JOIN
    const countSql = `SELECT COUNT(*) as total FROM health_record WHERE ${where}`;
    const totalResult = await Database.queryOne<{ total: number }>(countSql, params);
    const total = totalResult ? totalResult.total : 0;

    const sql = `
      SELECT hr.*, u.real_name as creator_name 
      FROM health_record hr 
      LEFT JOIN users u ON hr.creator_id = u.id 
      WHERE ${where} 
      ORDER BY hr.${orderBy} 
      LIMIT ${Number(pageSize)} OFFSET ${Number(offset)}
    `;

    const items = await Database.query<HealthRecord>(sql, params);

    return {
      items: items.map(item => {
        if (item.content_structured && typeof (item as any).content_structured === 'string') {
          (item as any).content_structured = JSON.parse((item as any).content_structured);
        }
        return item;
      }),
      total
    };
  }

  static async findByElderId(elderId: number): Promise<HealthRecord[]> {
    const sql = `
      SELECT hr.*, u.real_name as creator_name 
      FROM health_record hr 
      LEFT JOIN users u ON hr.creator_id = u.id 
      WHERE hr.elder_id = ? 
      ORDER BY hr.record_date DESC, hr.created_at DESC
    `;
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
