import { Database } from '../config/database';

export interface Role {
  id: number;
  role_code: string;
  role_name: string;
  description: string | null;
  level: number;
  created_at: string;
  updated_at: string;
}

export class RoleRepository {
  static async create(data: Omit<Role, 'id' | 'created_at' | 'updated_at'>): Promise<number> {
    const sql = `
      INSERT INTO roles (role_code, role_name, description, level)
      VALUES (?, ?, ?, ?)
    `;
    const params = [
      data.role_code,
      data.role_name,
      data.description || null,
      data.level
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<Role | null> {
    const sql = 'SELECT * FROM roles WHERE id = ?';
    return await Database.queryOne<Role>(sql, [id]);
  }

  static async findByRoleCode(roleCode: string): Promise<Role | null> {
    const sql = 'SELECT * FROM roles WHERE role_code = ?';
    return await Database.queryOne<Role>(sql, [roleCode]);
  }

  static async findAll(page: number, pageSize: number, where: string = '1=1', params: any[] = [], orderBy: string = 'level DESC, created_at DESC'): Promise<{ items: Role[]; total: number }> {
    return await Database.paginate<Role>('roles', page, pageSize, where, params, orderBy);
  }

  static async update(id: number, data: Partial<Omit<Role, 'id' | 'created_at' | 'updated_at'>>): Promise<boolean> {
    const fields: string[] = [];
    const params: any[] = [];

    if (data.role_name !== undefined) {
      fields.push('role_name = ?');
      params.push(data.role_name);
    }
    if (data.description !== undefined) {
      fields.push('description = ?');
      params.push(data.description);
    }
    if (data.level !== undefined) {
      fields.push('level = ?');
      params.push(data.level);
    }

    if (fields.length === 0) {
      return false;
    }

    params.push(id);
    const sql = `UPDATE roles SET ${fields.join(', ')} WHERE id = ?`;
    const result = await Database.update(sql, params);
    return result > 0;
  }

  static async delete(id: number): Promise<boolean> {
    const sql = 'DELETE FROM roles WHERE id = ?';
    const result = await Database.delete(sql, [id]);
    return result > 0;
  }

  static async findByUserId(userId: number): Promise<Role[]> {
    const sql = `
      SELECT r.* 
      FROM roles r
      INNER JOIN user_roles ur ON r.id = ur.role_id
      WHERE ur.user_id = ?
    `;
    return await Database.query<Role>(sql, [userId]);
  }

  static async assignRoleToUser(userId: number, roleId: number): Promise<boolean> {
    const checkSql = 'SELECT id FROM user_roles WHERE user_id = ? AND role_id = ?';
    const exists = await Database.queryOne(checkSql, [userId, roleId]);
    
    if (exists) {
      return true;
    }

    const sql = 'INSERT INTO user_roles (user_id, role_id) VALUES (?, ?)';
    const result = await Database.insert(sql, [userId, roleId]);
    return result > 0;
  }

  static async removeRoleFromUser(userId: number, roleId: number): Promise<boolean> {
    const sql = 'DELETE FROM user_roles WHERE user_id = ? AND role_id = ?';
    const result = await Database.delete(sql, [userId, roleId]);
    return result > 0;
  }

  static async updateUserRoles(userId: number, roleIds: number[]): Promise<boolean> {
    const deleteSql = 'DELETE FROM user_roles WHERE user_id = ?';
    await Database.delete(deleteSql, [userId]);

    if (roleIds.length === 0) {
      return true;
    }

    const insertSql = 'INSERT INTO user_roles (user_id, role_id) VALUES (?, ?)';
    for (const roleId of roleIds) {
      await Database.insert(insertSql, [userId, roleId]);
    }

    return true;
  }

  static async getUserCountByRoleId(roleId: number): Promise<number> {
    const sql = 'SELECT COUNT(*) as count FROM user_roles WHERE role_id = ?';
    const result = await Database.queryOne<{ count: number }>(sql, [roleId]);
    return result?.count || 0;
  }
}
