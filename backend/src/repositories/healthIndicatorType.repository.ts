import { Database } from '../config/database';
import { HealthIndicatorType } from '../types/healthIndicatorType';

export class HealthIndicatorTypeRepository {
  static async create(data: Omit<HealthIndicatorType, 'id' | 'created_at' | 'updated_at'>): Promise<number> {
    const sql = `
      INSERT INTO health_indicator_type (indicator_code, indicator_name, unit, min_value, max_value, form_config, status, sort_order)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.indicator_code,
      data.indicator_name,
      data.unit,
      data.min_value,
      data.max_value,
      data.form_config ? JSON.stringify(data.form_config) : null,
      data.status,
      data.sort_order
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<HealthIndicatorType | null> {
    const sql = 'SELECT * FROM health_indicator_type WHERE id = ?';
    const result = await Database.queryOne<HealthIndicatorType>(sql, [id]);
    if (result && result.form_config && typeof result.form_config === 'string') {
      result.form_config = JSON.parse(result.form_config as any);
    }
    return result;
  }

  static async findByCode(code: string): Promise<HealthIndicatorType | null> {
    const sql = 'SELECT * FROM health_indicator_type WHERE indicator_code = ?';
    const result = await Database.queryOne<HealthIndicatorType>(sql, [code]);
    if (result && result.form_config && typeof result.form_config === 'string') {
      result.form_config = JSON.parse(result.form_config as any);
    }
    return result;
  }

  static async findAll(status?: number): Promise<HealthIndicatorType[]> {
    let sql = 'SELECT * FROM health_indicator_type';
    const params: any[] = [];

    if (status !== undefined) {
      sql += ' WHERE status = ?';
      params.push(status);
    }

    sql += ' ORDER BY sort_order ASC, id ASC';

    const results = await Database.query<HealthIndicatorType>(sql, params);
    return results.map(item => {
      if (item.form_config && typeof item.form_config === 'string') {
        item.form_config = JSON.parse(item.form_config as any);
      }
      return item;
    });
  }

  static async update(id: number, data: Partial<Omit<HealthIndicatorType, 'id' | 'created_at' | 'updated_at'>>): Promise<boolean> {
    const fields: string[] = [];
    const params: any[] = [];

    if (data.indicator_code !== undefined) {
      fields.push('indicator_code = ?');
      params.push(data.indicator_code);
    }
    if (data.indicator_name !== undefined) {
      fields.push('indicator_name = ?');
      params.push(data.indicator_name);
    }
    if (data.unit !== undefined) {
      fields.push('unit = ?');
      params.push(data.unit);
    }
    if (data.min_value !== undefined) {
      fields.push('min_value = ?');
      params.push(data.min_value);
    }
    if (data.max_value !== undefined) {
      fields.push('max_value = ?');
      params.push(data.max_value);
    }
    if (data.form_config !== undefined) {
      fields.push('form_config = ?');
      params.push(data.form_config ? JSON.stringify(data.form_config) : null);
    }
    if (data.status !== undefined) {
      fields.push('status = ?');
      params.push(data.status);
    }
    if (data.sort_order !== undefined) {
      fields.push('sort_order = ?');
      params.push(data.sort_order);
    }

    if (fields.length === 0) {
      return false;
    }

    params.push(id);
    const sql = `UPDATE health_indicator_type SET ${fields.join(', ')} WHERE id = ?`;
    const result = await Database.update(sql, params);
    return result > 0;
  }

  static async delete(id: number): Promise<boolean> {
    const sql = 'DELETE FROM health_indicator_type WHERE id = ?';
    const result = await Database.delete(sql, [id]);
    return result > 0;
  }

  static async countByStatus(status: number): Promise<number> {
    const sql = 'SELECT COUNT(*) as count FROM health_indicator_type WHERE status = ?';
    const result = await Database.queryOne<{ count: number }>(sql, [status]);
    return result?.count || 0;
  }
}
