import { Database } from '../config/database';
import { ElderBasicInfo } from '../types/healthRecord';

export class ElderRepository {
  static async create(data: Omit<ElderBasicInfo, 'id' | 'created_at' | 'updated_at'>): Promise<number> {
    const sql = `
      INSERT INTO elder_basic_info (name, gender, birth_date, phone, address, id_card, emergency_contact, height, weight, blood_type)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.name,
      data.gender,
      data.birth_date,
      data.phone,
      data.address || null,
      data.id_card,
      data.emergency_contact,
      data.height || null,
      data.weight || null,
      data.blood_type || null
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<ElderBasicInfo | null> {
    const sql = 'SELECT * FROM elder_basic_info WHERE id = ?';
    return await Database.queryOne<ElderBasicInfo>(sql, [id]);
  }

  static async findAll(page: number, pageSize: number, where: string = '1=1', params: any[] = [], orderBy: string = 'created_at DESC'): Promise<{ items: ElderBasicInfo[]; total: number }> {
    return await Database.paginate<ElderBasicInfo>('elder_basic_info', page, pageSize, where, params, orderBy);
  }

  static async update(id: number, data: Partial<Omit<ElderBasicInfo, 'id' | 'created_at' | 'updated_at'>>): Promise<boolean> {
    const fields: string[] = [];
    const params: any[] = [];

    if (data.name !== undefined) {
      fields.push('name = ?');
      params.push(data.name);
    }
    if (data.gender !== undefined) {
      fields.push('gender = ?');
      params.push(data.gender);
    }
    if (data.birth_date !== undefined) {
      fields.push('birth_date = ?');
      params.push(data.birth_date);
    }
    if (data.phone !== undefined) {
      fields.push('phone = ?');
      params.push(data.phone);
    }
    if (data.address !== undefined) {
      fields.push('address = ?');
      params.push(data.address);
    }
    if (data.emergency_contact !== undefined) {
      fields.push('emergency_contact = ?');
      params.push(data.emergency_contact);
    }
    if (data.height !== undefined) {
      fields.push('height = ?');
      params.push(data.height);
    }
    if (data.weight !== undefined) {
      fields.push('weight = ?');
      params.push(data.weight);
    }
    if (data.blood_type !== undefined) {
      fields.push('blood_type = ?');
      params.push(data.blood_type);
    }

    if (fields.length === 0) {
      return false;
    }

    params.push(id);
    const sql = `UPDATE elder_basic_info SET ${fields.join(', ')} WHERE id = ?`;
    const result = await Database.update(sql, params);
    return result > 0;
  }

  static async delete(id: number): Promise<boolean> {
    const sql = 'DELETE FROM elder_basic_info WHERE id = ?';
    const result = await Database.delete(sql, [id]);
    return result > 0;
  }

  static async findByIdCard(idCard: string): Promise<ElderBasicInfo | null> {
    const sql = 'SELECT * FROM elder_basic_info WHERE id_card = ?';
    return await Database.queryOne<ElderBasicInfo>(sql, [idCard]);
  }
}
