import { Database } from '../config/database';

export interface MedicalStaffBasicInfo {
  id: number;
  user_id: number;
  gender: number;
  birth_date: string | null;
  role_type: string;
  job_title: string | null;
  good_at_tags: string | null;
  enable_online_service: boolean;
  created_at: string;
  updated_at: string;
}

export class MedicalStaffRepository {
  static async create(data: {
    user_id: number;
    gender: number;
    birth_date: string | null;
    role_type: string;
    job_title: string | null;
    good_at_tags: string | null;
    enable_online_service: boolean;
  }): Promise<number> {
    const sql = `
      INSERT INTO medical_staff_basic_info (
        user_id,
        gender,
        birth_date,
        role_type,
        job_title,
        good_at_tags,
        enable_online_service
      )
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.user_id,
      data.gender,
      data.birth_date,
      data.role_type,
      data.job_title,
      data.good_at_tags,
      data.enable_online_service ? 1 : 0
    ];
    return await Database.insert(sql, params);
  }

  static async updateByUserId(
    userId: number,
    data: Partial<{
      gender: number;
      birth_date: string | null;
      role_type: string;
      job_title: string | null;
      good_at_tags: string | null;
      enable_online_service: boolean;
    }>
  ): Promise<boolean> {
    const fields: string[] = [];
    const params: any[] = [];

    if (data.gender !== undefined) {
      fields.push('gender = ?');
      params.push(data.gender);
    }
    if (data.birth_date !== undefined) {
      fields.push('birth_date = ?');
      params.push(data.birth_date);
    }
    if (data.role_type !== undefined) {
      fields.push('role_type = ?');
      params.push(data.role_type);
    }
    if (data.job_title !== undefined) {
      fields.push('job_title = ?');
      params.push(data.job_title);
    }
    if (data.good_at_tags !== undefined) {
      fields.push('good_at_tags = ?');
      params.push(data.good_at_tags);
    }
    if (data.enable_online_service !== undefined) {
      fields.push('enable_online_service = ?');
      params.push(data.enable_online_service ? 1 : 0);
    }

    if (fields.length === 0) {
      return false;
    }

    params.push(userId);
    const sql = `UPDATE medical_staff_basic_info SET ${fields.join(', ')} WHERE user_id = ?`;
    const result = await Database.update(sql, params);
    return result > 0;
  }

  static async findByUserId(userId: number): Promise<MedicalStaffBasicInfo | null> {
    const sql = 'SELECT * FROM medical_staff_basic_info WHERE user_id = ? LIMIT 1';
    const result = await Database.queryOne<MedicalStaffBasicInfo>(sql, [userId]);
    return result;
  }
}
