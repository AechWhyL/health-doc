import { Database } from '../config/database';
import { InterventionPlan } from '../types/interventionPlan';

export class InterventionPlanRepository {
  static async create(
    data: Omit<InterventionPlan, 'id' | 'created_at' | 'updated_at'>
  ): Promise<number> {
    const sql = `
      INSERT INTO intervention_plan (
        elder_user_id,
        title,
        description,
        status,
        start_date,
        end_date,
        created_by_user_id
      )
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.elder_user_id,
      data.title,
      data.description ?? null,
      data.status,
      data.start_date,
      data.end_date ?? null,
      data.created_by_user_id
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<InterventionPlan | null> {
    const sql = 'SELECT * FROM intervention_plan WHERE id = ?';
    return await Database.queryOne<InterventionPlan>(sql, [id]);
  }

  static async update(
    id: number,
    data: Partial<Omit<InterventionPlan, 'id'>>
  ): Promise<number> {
    const fields: string[] = [];
    const params: any[] = [];

    if (data.title !== undefined) {
      fields.push('title = ?');
      params.push(data.title);
    }
    if (data.description !== undefined) {
      fields.push('description = ?');
      params.push(data.description);
    }
    if (data.status !== undefined) {
      fields.push('status = ?');
      params.push(data.status);
    }
    if (data.start_date !== undefined) {
      fields.push('start_date = ?');
      params.push(data.start_date);
    }
    if (data.end_date !== undefined) {
      fields.push('end_date = ?');
      params.push(data.end_date);
    }

    if (fields.length === 0) {
      return 0;
    }

    const sql = `
      UPDATE intervention_plan
      SET ${fields.join(', ')}
      WHERE id = ?
    `;
    params.push(id);

    return await Database.update(sql, params);
  }

  static async findByElderUserId(
    elderUserId: number,
    page: number,
    pageSize: number,
    status?: string,
    orderBy?: string,
    createdByUserId?: number
  ): Promise<{ items: InterventionPlan[]; total: number }> {
    const whereParts: string[] = ['elder_user_id = ?'];
    const params: any[] = [elderUserId];

    if (status) {
      whereParts.push('status = ?');
      params.push(status);
    }

    if (createdByUserId) {
      whereParts.push('created_by_user_id = ?');
      params.push(createdByUserId);
    }

    const where = whereParts.join(' AND ');
    const order = orderBy || 'created_at DESC';

    return await Database.paginate<InterventionPlan>(
      'intervention_plan',
      page,
      pageSize,
      where,
      params,
      order
    );
  }
}

