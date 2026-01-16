import { Database } from '../config/database';
import { ConsultationQuestionRecord, ConsultationStatus } from '../types/consultation';

export class ConsultationQuestionRepository {
  static async create(
    data: Omit<
      ConsultationQuestionRecord,
      'id' | 'created_at' | 'updated_at' | 'resolved_at' | 'closed_at'
    >
  ): Promise<number> {
    const sql = `
      INSERT INTO consultation_question (
        code,
        title,
        description,
        creator_type,
        creator_id,
        target_org_id,
        category,
        status,
        priority,
        is_anonymous
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.code,
      data.title,
      data.description ?? null,
      data.creator_type,
      data.creator_id,
      data.target_staff_id,
      data.category ?? null,
      data.status,
      data.priority,
      data.is_anonymous ?? false
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<ConsultationQuestionRecord | null> {
    const sql = 'SELECT * FROM consultation_question WHERE id = ?';
    return await Database.queryOne<ConsultationQuestionRecord>(sql, [id]);
  }

  static async findAll(
    page: number,
    pageSize: number,
    where: string = '1=1',
    params: any[] = [],
    orderBy: string = 'created_at DESC'
  ): Promise<{ items: ConsultationQuestionRecord[]; total: number }> {
    return await Database.paginate<ConsultationQuestionRecord>(
      'consultation_question',
      page,
      pageSize,
      where,
      params,
      orderBy
    );
  }

  static async updateStatus(id: number, status: ConsultationStatus): Promise<boolean> {
    const sql = `
      UPDATE consultation_question
      SET status = ?, updated_at = NOW()
      WHERE id = ?
    `;
    const result = await Database.update(sql, [status, id]);
    return result > 0;
  }
}

