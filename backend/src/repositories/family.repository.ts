import { Database } from '../config/database';
import { FamilyBasicInfo } from '../types/family';

export class FamilyRepository {
    static async create(data: Omit<FamilyBasicInfo, 'id' | 'created_at' | 'updated_at'>): Promise<number> {
        const sql = `
      INSERT INTO family_basic_info (user_id, name, gender, phone)
      VALUES (?, ?, ?, ?)
    `;
        const params = [
            data.user_id,
            data.name,
            data.gender ?? 0,
            data.phone || null
        ];
        return await Database.insert(sql, params);
    }

    static async findById(id: number): Promise<FamilyBasicInfo | null> {
        const sql = 'SELECT * FROM family_basic_info WHERE id = ?';
        return await Database.queryOne<FamilyBasicInfo>(sql, [id]);
    }

    static async findByUserId(userId: number): Promise<FamilyBasicInfo | null> {
        const sql = 'SELECT * FROM family_basic_info WHERE user_id = ?';
        return await Database.queryOne<FamilyBasicInfo>(sql, [userId]);
    }

    static async findAll(page: number, pageSize: number, where: string = '1=1', params: any[] = [], orderBy: string = 'created_at DESC'): Promise<{ items: FamilyBasicInfo[]; total: number }> {
        return await Database.paginate<FamilyBasicInfo>('family_basic_info', page, pageSize, where, params, orderBy);
    }

    static async update(id: number, data: Partial<Omit<FamilyBasicInfo, 'id' | 'user_id' | 'created_at' | 'updated_at'>>): Promise<boolean> {
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
        if (data.phone !== undefined) {
            fields.push('phone = ?');
            params.push(data.phone);
        }

        if (fields.length === 0) {
            return false;
        }

        params.push(id);
        const sql = `UPDATE family_basic_info SET ${fields.join(', ')} WHERE id = ?`;
        const result = await Database.update(sql, params);
        return result > 0;
    }

    static async delete(id: number): Promise<boolean> {
        const sql = 'DELETE FROM family_basic_info WHERE id = ?';
        const result = await Database.delete(sql, [id]);
        return result > 0;
    }
}
