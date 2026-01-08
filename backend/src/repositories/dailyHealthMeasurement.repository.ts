import { Database } from '../config/database';
import { DailyHealthMeasurement } from '../types/dailyHealthMeasurement';

export class DailyHealthMeasurementRepository {
  static async create(
    data: Omit<DailyHealthMeasurement, 'id' | 'created_at' | 'updated_at'>
  ): Promise<number> {
    const sql = `
      INSERT INTO daily_health_measurement (
        elder_id,
        measured_at,
        sbp,
        dbp,
        fpg,
        ppg_2h,
        weight,
        steps,
        source,
        remark
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.elder_id,
      data.measured_at,
      data.sbp ?? null,
      data.dbp ?? null,
      data.fpg ?? null,
      data.ppg_2h ?? null,
      data.weight ?? null,
      data.steps ?? null,
      data.source,
      data.remark ?? null
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<DailyHealthMeasurement | null> {
    const sql = 'SELECT * FROM daily_health_measurement WHERE id = ?';
    return await Database.queryOne<DailyHealthMeasurement>(sql, [id]);
  }

  static async findAll(
    page: number,
    pageSize: number,
    elderId?: number
  ): Promise<{ items: DailyHealthMeasurement[]; total: number }> {
    let where = '1=1';
    const params: any[] = [];

    if (elderId) {
      where += ' AND elder_id = ?';
      params.push(elderId);
    }

    const result = await Database.paginate<DailyHealthMeasurement>(
      'daily_health_measurement',
      page,
      pageSize,
      where,
      params,
      'measured_at DESC, created_at DESC'
    );

    return {
      items: result.items,
      total: result.total
    };
  }

  static async update(
    id: number,
    data: Partial<Omit<DailyHealthMeasurement, 'id' | 'elder_id' | 'created_at' | 'updated_at'>>
  ): Promise<boolean> {
    const fields: string[] = [];
    const params: any[] = [];

    if (data.measured_at !== undefined) {
      fields.push('measured_at = ?');
      params.push(data.measured_at);
    }
    if (data.sbp !== undefined) {
      fields.push('sbp = ?');
      params.push(data.sbp);
    }
    if (data.dbp !== undefined) {
      fields.push('dbp = ?');
      params.push(data.dbp);
    }
    if (data.fpg !== undefined) {
      fields.push('fpg = ?');
      params.push(data.fpg);
    }
    if (data.ppg_2h !== undefined) {
      fields.push('ppg_2h = ?');
      params.push(data.ppg_2h);
    }
    if (data.weight !== undefined) {
      fields.push('weight = ?');
      params.push(data.weight);
    }
    if (data.steps !== undefined) {
      fields.push('steps = ?');
      params.push(data.steps);
    }
    if (data.source !== undefined) {
      fields.push('source = ?');
      params.push(data.source);
    }
    if (data.remark !== undefined) {
      fields.push('remark = ?');
      params.push(data.remark);
    }

    if (fields.length === 0) {
      return false;
    }

    params.push(id);
    const sql = `UPDATE daily_health_measurement SET ${fields.join(', ')} WHERE id = ?`;
    const result = await Database.update(sql, params);
    return result > 0;
  }

  static async delete(id: number): Promise<boolean> {
    const sql = 'DELETE FROM daily_health_measurement WHERE id = ?';
    const result = await Database.delete(sql, [id]);
    return result > 0;
  }
}

