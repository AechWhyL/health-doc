import { Database } from '../config/database';
import { AllergyRecord } from '../types/healthRecord';

export class AllergyRepository {
  static async create(data: Omit<AllergyRecord, 'id' | 'created_at' | 'updated_at'>): Promise<number> {
    const sql = `
      INSERT INTO allergy_record (elder_id, allergy_item, allergy_desc)
      VALUES (?, ?, ?)
    `;
    const params = [
      data.elder_id,
      data.allergy_item,
      data.allergy_desc || null
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<AllergyRecord | null> {
    const sql = 'SELECT * FROM allergy_record WHERE id = ?';
    return await Database.queryOne<AllergyRecord>(sql, [id]);
  }

  static async findAll(page: number, pageSize: number, where: string = '1=1', params: any[] = [], orderBy: string = 'created_at DESC'): Promise<{ items: AllergyRecord[]; total: number }> {
    return await Database.paginate<AllergyRecord>('allergy_record', page, pageSize, where, params, orderBy);
  }

  static async findByElderId(elderId: number): Promise<AllergyRecord[]> {
    const sql = 'SELECT * FROM allergy_record WHERE elder_id = ? ORDER BY created_at DESC';
    return await Database.query<AllergyRecord>(sql, [elderId]);
  }

  static async update(id: number, data: Partial<Omit<AllergyRecord, 'id' | 'elder_id' | 'created_at' | 'updated_at'>>): Promise<boolean> {
    const fields: string[] = [];
    const params: any[] = [];

    if (data.allergy_item !== undefined) {
      fields.push('allergy_item = ?');
      params.push(data.allergy_item);
    }
    if (data.allergy_desc !== undefined) {
      fields.push('allergy_desc = ?');
      params.push(data.allergy_desc);
    }

    if (fields.length === 0) {
      return false;
    }

    params.push(id);
    const sql = `UPDATE allergy_record SET ${fields.join(', ')} WHERE id = ?`;
    const result = await Database.update(sql, params);
    return result > 0;
  }

  static async delete(id: number): Promise<boolean> {
    const sql = 'DELETE FROM allergy_record WHERE id = ?';
    const result = await Database.delete(sql, [id]);
    return result > 0;
  }

  static async deleteByElderId(elderId: number): Promise<boolean> {
    const sql = 'DELETE FROM allergy_record WHERE elder_id = ?';
    const result = await Database.delete(sql, [elderId]);
    return result > 0;
  }
}
