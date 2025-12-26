import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '3306', 10),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'elder_health',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  charset: 'utf8mb4',
  timezone: '+08:00'
});

export class Database {
  static async query<T = any>(sql: string, params?: any[]): Promise<T[]> {
    try {
      const [rows] = await pool.execute(sql, params);
      return rows as T[];
    } catch (error) {
      console.error('Database query error:', error);
      throw error;
    }
  }

  static async queryOne<T = any>(sql: string, params?: any[]): Promise<T | null> {
    const results = await this.query<T>(sql, params);
    return results.length > 0 ? results[0] : null;
  }

  static async insert(sql: string, params?: any[]): Promise<number> {
    try {
      const [result] = await pool.execute(sql, params);
      return (result as any).insertId;
    } catch (error) {
      console.error('Database insert error:', error);
      throw error;
    }
  }

  static async update(sql: string, params?: any[]): Promise<number> {
    try {
      const [result] = await pool.execute(sql, params);
      return (result as any).affectedRows;
    } catch (error) {
      console.error('Database update error:', error);
      throw error;
    }
  }

  static async delete(sql: string, params?: any[]): Promise<number> {
    try {
      const [result] = await pool.execute(sql, params);
      return (result as any).affectedRows;
    } catch (error) {
      console.error('Database delete error:', error);
      throw error;
    }
  }

  static async paginate<T = any>(
    tableName: string,
    page: number,
    pageSize: number,
    where: string = '1=1',
    params: any[] = [],
    orderBy: string = 'created_at DESC'
  ): Promise<{ items: T[]; total: number }> {
    const offset = (page - 1) * pageSize;

    const countSql = `SELECT COUNT(*) as total FROM ${tableName} WHERE ${where}`;
    const countResult = await this.queryOne<{ total: number }>(countSql, params);
    const total = countResult?.total || 0;

    const dataSql = `SELECT * FROM ${tableName} WHERE ${where} ORDER BY ${orderBy} LIMIT ? OFFSET ?`;
    const items = await this.query<T>(dataSql, [...params, pageSize, offset]);

    return { items, total };
  }

  static async beginTransaction(): Promise<mysql.PoolConnection> {
    const connection = await pool.getConnection();
    await connection.beginTransaction();
    return connection;
  }

  static async commitTransaction(connection: mysql.PoolConnection): Promise<void> {
    await connection.commit();
    connection.release();
  }

  static async rollbackTransaction(connection: mysql.PoolConnection): Promise<void> {
    await connection.rollback();
    connection.release();
  }
}

export default pool;
