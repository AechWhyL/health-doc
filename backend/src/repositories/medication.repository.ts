import { Database } from '../config/database';
import { MedicationRecord } from '../types/healthRecord';

export class MedicationRepository {
  static async create(data: Omit<MedicationRecord, 'id' | 'created_at' | 'updated_at'>): Promise<number> {
    const sql = `
      INSERT INTO medication_record (elder_id, drug_name, dosage, frequency, start_date, end_date, notes)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.elder_id,
      data.drug_name,
      data.dosage || null,
      data.frequency || null,
      data.start_date,
      data.end_date || null,
      data.notes || null
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<MedicationRecord | null> {
    const sql = 'SELECT * FROM medication_record WHERE id = ?';
    return await Database.queryOne<MedicationRecord>(sql, [id]);
  }

  static async findAll(page: number, pageSize: number, where: string = '1=1', params: any[] = [], orderBy: string = 'created_at DESC'): Promise<{ items: MedicationRecord[]; total: number }> {
    return await Database.paginate<MedicationRecord>('medication_record', page, pageSize, where, params, orderBy);
  }

  static async findByElderId(elderId: number): Promise<MedicationRecord[]> {
    const sql = 'SELECT * FROM medication_record WHERE elder_id = ? ORDER BY start_date DESC, created_at DESC';
    return await Database.query<MedicationRecord>(sql, [elderId]);
  }

  static async update(id: number, data: Partial<Omit<MedicationRecord, 'id' | 'elder_id' | 'created_at' | 'updated_at'>>): Promise<boolean> {
    const fields: string[] = [];
    const params: any[] = [];

    if (data.drug_name !== undefined) {
      fields.push('drug_name = ?');
      params.push(data.drug_name);
    }
    if (data.dosage !== undefined) {
      fields.push('dosage = ?');
      params.push(data.dosage);
    }
    if (data.frequency !== undefined) {
      fields.push('frequency = ?');
      params.push(data.frequency);
    }
    if (data.start_date !== undefined) {
      fields.push('start_date = ?');
      params.push(data.start_date);
    }
    if (data.end_date !== undefined) {
      fields.push('end_date = ?');
      params.push(data.end_date);
    }
    if (data.notes !== undefined) {
      fields.push('notes = ?');
      params.push(data.notes);
    }

    if (fields.length === 0) {
      return false;
    }

    params.push(id);
    const sql = `UPDATE medication_record SET ${fields.join(', ')} WHERE id = ?`;
    const result = await Database.update(sql, params);
    return result > 0;
  }

  static async delete(id: number): Promise<boolean> {
    const sql = 'DELETE FROM medication_record WHERE id = ?';
    const result = await Database.delete(sql, [id]);
    return result > 0;
  }

  static async deleteByElderId(elderId: number): Promise<boolean> {
    const sql = 'DELETE FROM medication_record WHERE elder_id = ?';
    const result = await Database.delete(sql, [elderId]);
    return result > 0;
  }
}
