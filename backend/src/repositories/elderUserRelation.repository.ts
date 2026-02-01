import { Database } from '../config/database';

export interface ElderUserRelationRecord {
  id: number;
  user_id: number;
  elder_id: number;
  relation_name: string | null;
  remark: string | null;
  created_at: string;
  updated_at: string;
}

export interface ElderUserRelationWithElderRaw {
  relation_id: number;
  user_id: number;
  relation_name: string | null;
  remark: string | null;
  relation_created_at: string;
  relation_updated_at: string;
  elder_id: number;
  elder_user_id: number | null; // Added: the elder's user account ID
  elder_name: string;
  elder_gender: number;
  elder_birth_date: string;
  elder_phone: string;
  elder_address: string | null;
  elder_emergency_contact: string;
  elder_height: number | null;
  elder_weight: number | null;
  elder_blood_type: string | null;
  elder_created_at: string;
  elder_updated_at: string;
}

export class ElderUserRelationRepository {
  static async create(data: {
    user_id: number;
    elder_id: number;
    relation_name?: string | null;
    remark?: string | null;
  }): Promise<number> {
    const sql = `
      INSERT INTO elder_user_relations (user_id, elder_id, relation_name, remark)
      VALUES (?, ?, ?, ?)
    `;
    const params = [
      data.user_id,
      data.elder_id,
      data.relation_name ?? null,
      data.remark ?? null
    ];
    return await Database.insert(sql, params);
  }

  static async findByUserAndElder(userId: number, elderId: number): Promise<ElderUserRelationRecord | null> {
    const sql = `
      SELECT id, user_id, elder_id, relation_name, remark, created_at, updated_at
      FROM elder_user_relations
      WHERE user_id = ? AND elder_id = ?
    `;
    return await Database.queryOne<ElderUserRelationRecord>(sql, [userId, elderId]);
  }

  static async findByUserIdWithElder(
    userId: number,
    page: number,
    pageSize: number,
    elderName?: string,
    phone?: string,
    linkedOnly: boolean = true
  ): Promise<{ items: ElderUserRelationWithElderRaw[]; total: number }> {
    const offset = (page - 1) * pageSize;
    const whereParts: string[] = [];
    const params: any[] = [];

    // 如果 linkedOnly 为 true，只查询当前用户关联的老人
    if (linkedOnly) {
      whereParts.push('r.user_id = ?');
      params.push(userId);
    }

    if (elderName) {
      whereParts.push('e.name LIKE ?');
      params.push(`%${elderName}%`);
    }

    if (phone) {
      whereParts.push('e.phone LIKE ?');
      params.push(`%${phone}%`);
    }

    const whereClause = whereParts.length > 0 ? whereParts.join(' AND ') : '1=1';

    // 根据 linkedOnly 决定使用 INNER JOIN 还是 LEFT JOIN
    const joinType = linkedOnly ? 'INNER JOIN' : 'LEFT JOIN';

    const countSql = `
      SELECT COUNT(*) AS total
      FROM elder_basic_info e
      ${joinType} elder_user_relations r ON r.elder_id = e.user_id ${linkedOnly ? '' : 'AND r.user_id = ?'}
      WHERE ${whereClause}
    `;

    const countParams = linkedOnly ? params : [userId, ...params];
    const countResult = await Database.queryOne<{ total: number }>(countSql, countParams);
    const total = countResult?.total || 0;

    const dataSql = `
      SELECT
        r.id AS relation_id,
        r.user_id,
        r.relation_name,
        r.remark,
        r.created_at AS relation_created_at,
        r.updated_at AS relation_updated_at,
        e.id AS elder_id,
        e.user_id AS elder_user_id,
        e.name AS elder_name,
        e.gender AS elder_gender,
        e.birth_date AS elder_birth_date,
        e.phone AS elder_phone,
        e.address AS elder_address,
        e.emergency_contact AS elder_emergency_contact,
        e.height AS elder_height,
        e.weight AS elder_weight,
        e.blood_type AS elder_blood_type,
        e.created_at AS elder_created_at,
        e.updated_at AS elder_updated_at
      FROM elder_basic_info e
      ${joinType} elder_user_relations r ON r.elder_id = e.user_id ${linkedOnly ? '' : 'AND r.user_id = ?'}
      WHERE ${whereClause}
      ORDER BY ${linkedOnly ? 'r.created_at DESC, r.id DESC' : 'e.created_at DESC, e.id DESC'}
      LIMIT ${parseInt(String(pageSize), 10)} OFFSET ${parseInt(String(offset), 10)}
    `;

    const dataParams = linkedOnly ? params : [userId, ...params];
    const items = await Database.query<ElderUserRelationWithElderRaw>(dataSql, dataParams);

    return { items, total };
  }

  static async findByUserAndElderUser(userId: number, elderUserId: number): Promise<ElderUserRelationRecord | null> {
    const sql = `
      SELECT id, user_id, elder_id, relation_name, remark, created_at, updated_at
      FROM elder_user_relations
      WHERE user_id = ? AND elder_id = ?
    `;
    return await Database.queryOne<ElderUserRelationRecord>(sql, [userId, elderUserId]);
  }

  static async deleteByIdAndUserId(id: number, userId: number): Promise<boolean> {
    const sql = `
      DELETE FROM elder_user_relations
      WHERE id = ? AND user_id = ?
    `;
    const result = await Database.delete(sql, [id, userId]);
    return result > 0;
  }

  static async findAllByElderUserId(elderUserId: number): Promise<number[]> {
    const sql = `
      SELECT user_id FROM elder_user_relations WHERE elder_id = ?
    `;
    const rows = await Database.query<{ user_id: number }>(sql, [elderUserId]);
    return rows.map(row => row.user_id);
  }
}
