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

  static async findOnlineStaff(
    page: number = 1,
    pageSize: number = 10,
    filters?: { goodAtTags?: string; phone?: string }
  ): Promise<{
    items: Array<MedicalStaffBasicInfo & { real_name: string | null; username: string; phone: string | null }>;
    total: number;
  }> {
    const pageNum = Math.max(1, Math.floor(Number(page) || 1));
    const pageSizeNum = Math.max(1, Math.min(100, Math.floor(Number(pageSize) || 10)));
    const offset = (pageNum - 1) * pageSizeNum;

    let whereClause = "ms.enable_online_service = 1 AND u.status = 'active'";
    const params: any[] = [];

    if (filters?.goodAtTags && filters.goodAtTags.trim()) {
      whereClause += " AND ms.good_at_tags LIKE ?";
      params.push(`%${filters.goodAtTags.trim()}%`);
    }

    if (filters?.phone && filters.phone.trim()) {
      whereClause += " AND u.phone LIKE ?";
      params.push(`%${filters.phone.trim()}%`);
    }

    const countSql = `
      SELECT COUNT(*) as total
      FROM medical_staff_basic_info ms
      JOIN users u ON ms.user_id = u.id
      WHERE ${whereClause}
    `;
    const countResult = await Database.queryOne<{ total: number }>(countSql, params);
    const total = countResult?.total || 0;

    const sql = `
      SELECT ms.*, u.real_name, u.username, u.phone
      FROM medical_staff_basic_info ms
      JOIN users u ON ms.user_id = u.id
      WHERE ${whereClause}
      ORDER BY ms.created_at DESC
      LIMIT ${pageSizeNum} OFFSET ${offset}
    `;
    const items = await Database.query<MedicalStaffBasicInfo & { real_name: string | null; username: string; phone: string | null }>(sql, params);
    return { items, total };
  }
}
