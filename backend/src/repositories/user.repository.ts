import { Database } from '../config/database';
import { Role } from './role.repository';

export interface User {
  id: number;
  username: string;
  password: string;
  email: string | null;
  phone: string | null;
  real_name: string | null;
  avatar: string | null;
  status: 'active' | 'inactive' | 'locked';
  is_verified: boolean;
  last_login_at: string | null;
  last_login_ip: string | null;
  created_at: string;
  updated_at: string;
}

export interface UserWithRoles extends User {
  roles: Role[];
}

export class UserRepository {
  static async create(data: Omit<User, 'id' | 'created_at' | 'updated_at'>): Promise<number> {
    const sql = `
      INSERT INTO users (username, password, email, phone, real_name, avatar, status, is_verified, last_login_at, last_login_ip)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.username,
      data.password,
      data.email || null,
      data.phone || null,
      data.real_name || null,
      data.avatar || null,
      data.status,
      data.is_verified,
      data.last_login_at || null,
      data.last_login_ip || null
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<User | null> {
    const sql = 'SELECT * FROM users WHERE id = ?';
    return await Database.queryOne<User>(sql, [id]);
  }

  static async findByIdWithRoles(id: number): Promise<UserWithRoles | null> {
    const user = await this.findById(id);
    if (!user) {
      return null;
    }

    const roles = await Database.query<Role>(`
      SELECT r.* 
      FROM roles r
      INNER JOIN user_roles ur ON r.id = ur.role_id
      WHERE ur.user_id = ?
    `, [id]);

    return {
      ...user,
      roles
    };
  }

  static async findByUsername(username: string): Promise<User | null> {
    const sql = 'SELECT * FROM users WHERE username = ?';
    return await Database.queryOne<User>(sql, [username]);
  }

  static async findByEmail(email: string): Promise<User | null> {
    const sql = 'SELECT * FROM users WHERE email = ?';
    return await Database.queryOne<User>(sql, [email]);
  }

  static async findByPhone(phone: string): Promise<User | null> {
    const sql = 'SELECT * FROM users WHERE phone = ?';
    return await Database.queryOne<User>(sql, [phone]);
  }

  static async findAll(page: number, pageSize: number, where: string = '1=1', params: any[] = [], orderBy: string = 'created_at DESC'): Promise<{ items: User[]; total: number }> {
    return await Database.paginate<User>('users', page, pageSize, where, params, orderBy);
  }

  static async update(id: number, data: Partial<Omit<User, 'id' | 'created_at' | 'updated_at'>>): Promise<boolean> {
    const fields: string[] = [];
    const params: any[] = [];

    if (data.password !== undefined) {
      fields.push('password = ?');
      params.push(data.password);
    }
    if (data.email !== undefined) {
      fields.push('email = ?');
      params.push(data.email);
    }
    if (data.phone !== undefined) {
      fields.push('phone = ?');
      params.push(data.phone);
    }
    if (data.real_name !== undefined) {
      fields.push('real_name = ?');
      params.push(data.real_name);
    }
    if (data.avatar !== undefined) {
      fields.push('avatar = ?');
      params.push(data.avatar);
    }
    if (data.status !== undefined) {
      fields.push('status = ?');
      params.push(data.status);
    }
    if (data.is_verified !== undefined) {
      fields.push('is_verified = ?');
      params.push(data.is_verified);
    }
    if (data.last_login_at !== undefined) {
      fields.push('last_login_at = ?');
      params.push(data.last_login_at);
    }
    if (data.last_login_ip !== undefined) {
      fields.push('last_login_ip = ?');
      params.push(data.last_login_ip);
    }

    if (fields.length === 0) {
      return false;
    }

    params.push(id);
    const sql = `UPDATE users SET ${fields.join(', ')} WHERE id = ?`;
    const result = await Database.update(sql, params);
    return result > 0;
  }

  static async delete(id: number): Promise<boolean> {
    const sql = 'DELETE FROM users WHERE id = ?';
    const result = await Database.delete(sql, [id]);
    return result > 0;
  }

  static async updateLastLogin(id: number, ip: string): Promise<boolean> {
    const sql = 'UPDATE users SET last_login_at = NOW(), last_login_ip = ? WHERE id = ?';
    const result = await Database.update(sql, [ip, id]);
    return result > 0;
  }

  static async checkUsernameExists(username: string, excludeId?: number): Promise<boolean> {
    let sql = 'SELECT id FROM users WHERE username = ?';
    const params: any[] = [username];

    if (excludeId !== undefined) {
      sql += ' AND id != ?';
      params.push(excludeId);
    }

    const result = await Database.queryOne(sql, params);
    return result !== null;
  }

  static async checkEmailExists(email: string, excludeId?: number): Promise<boolean> {
    let sql = 'SELECT id FROM users WHERE email = ?';
    const params: any[] = [email];

    if (excludeId !== undefined) {
      sql += ' AND id != ?';
      params.push(excludeId);
    }

    const result = await Database.queryOne(sql, params);
    return result !== null;
  }

  static async checkPhoneExists(phone: string, excludeId?: number): Promise<boolean> {
    let sql = 'SELECT id FROM users WHERE phone = ?';
    const params: any[] = [phone];

    if (excludeId !== undefined) {
      sql += ' AND id != ?';
      params.push(excludeId);
    }

    const result = await Database.queryOne(sql, params);
    return result !== null;
  }
}
