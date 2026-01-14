import { Database } from '../config/database';
import { HealthStatusLevel, PersonalHealthRuleConfig, PersonalHealthRuleRecord } from '../types/ruleEngine';

export class PersonalHealthRuleRepository {
  static async create(
    data: Omit<PersonalHealthRuleConfig, 'id' | 'isActive'> & { createdByUserId?: number }
  ): Promise<number> {
    const sql = `
      INSERT INTO personal_health_rule (
        elder_id,
        name,
        level,
        logic,
        message_template,
        is_active,
        created_by_user_id
      )
      VALUES (?, ?, ?, ?, ?, 1, ?)
    `;
    const params = [
      data.elderId ?? null,
      data.name,
      data.level,
      JSON.stringify(data.logic ?? {}),
      data.messageTemplate ?? null,
      data.createdByUserId ?? null
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<PersonalHealthRuleConfig | null> {
    const sql = 'SELECT * FROM personal_health_rule WHERE id = ?';
    const record = await Database.queryOne<PersonalHealthRuleRecord>(sql, [id]);
    if (!record) {
      return null;
    }
    return this.toConfig(record);
  }

  static async findByElderId(elderId: number): Promise<PersonalHealthRuleConfig[]> {
    const sql = `
      SELECT *
      FROM personal_health_rule
      WHERE (elder_id IS NULL OR elder_id = ?)
        AND is_active = 1
      ORDER BY elder_id IS NULL ASC, id ASC
    `;
    const records = await Database.query<PersonalHealthRuleRecord>(sql, [elderId]);
    return records.map(r => this.toConfig(r));
  }

  static async findAll(
    page: number,
    pageSize: number,
    elderId?: number
  ): Promise<{ items: PersonalHealthRuleConfig[]; total: number }> {
    const whereParts: string[] = [];
    const params: (number | string)[] = [];

    if (elderId !== undefined) {
      whereParts.push('(elder_id = ?)');
      params.push(elderId);
    }

    const where = whereParts.length > 0 ? whereParts.join(' AND ') : '1=1';
    const { items, total } = await Database.paginate<PersonalHealthRuleRecord>(
      'personal_health_rule',
      page,
      pageSize,
      where,
      params
    );
    return {
      items: items.map(r => this.toConfig(r)),
      total
    };
  }

  static async update(
    id: number,
    data: Partial<Omit<PersonalHealthRuleConfig, 'id'>> & { isActive?: boolean }
  ): Promise<boolean> {
    const fields: string[] = [];
    const params: (number | string | null)[] = [];

    if (data.elderId !== undefined) {
      fields.push('elder_id = ?');
      params.push(data.elderId ?? null);
    }
    if (data.name !== undefined) {
      fields.push('name = ?');
      params.push(data.name);
    }
    if (data.level !== undefined) {
      fields.push('level = ?');
      params.push(data.level as HealthStatusLevel);
    }
    if (data.logic !== undefined) {
      fields.push('logic = ?');
      params.push(JSON.stringify(data.logic ?? {}));
    }
    if (data.messageTemplate !== undefined) {
      fields.push('message_template = ?');
      params.push(data.messageTemplate ?? null);
    }
    if (data.isActive !== undefined) {
      fields.push('is_active = ?');
      params.push(data.isActive ? 1 : 0);
    }

    if (!fields.length) {
      return false;
    }

    params.push(id);
    const sql = `
      UPDATE personal_health_rule
      SET ${fields.join(', ')}
      WHERE id = ?
    `;
    const affected = await Database.update(sql, params);
    return affected > 0;
  }

  static async delete(id: number): Promise<boolean> {
    const sql = 'DELETE FROM personal_health_rule WHERE id = ?';
    const affected = await Database.delete(sql, [id]);
    return affected > 0;
  }

  private static toConfig(record: PersonalHealthRuleRecord): PersonalHealthRuleConfig {
    let parsedLogic: unknown = {};
    if (record.logic !== null && record.logic !== undefined) {
      if (typeof record.logic === 'string') {
        try {
          parsedLogic = JSON.parse(record.logic);
        } catch {
          parsedLogic = {};
        }
      } else {
        parsedLogic = record.logic;
      }
    }

    return {
      id: String(record.id),
      name: record.name,
      elderId: record.elder_id ?? undefined,
      level: record.level,
      logic: parsedLogic,
      messageTemplate: record.message_template ?? undefined,
      isActive: record.is_active === 1
    };
  }
}

