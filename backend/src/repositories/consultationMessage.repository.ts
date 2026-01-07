import { Database } from '../config/database';
import { ConsultationMessageRecord } from '../types/consultation';

export class ConsultationMessageRepository {
  static async create(
    data: Omit<ConsultationMessageRecord, 'id' | 'created_at'>
  ): Promise<number> {
    const sql = `
      INSERT INTO consultation_message (
        question_id,
        sender_type,
        sender_id,
        role_display_name,
        content_type,
        content_text,
        sent_at,
        status,
        is_visible_to_patient
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.question_id,
      data.sender_type,
      data.sender_id ?? null,
      data.role_display_name ?? null,
      data.content_type,
      data.content_text ?? null,
      data.sent_at,
      data.status,
      data.is_visible_to_patient ?? true
    ];
    return await Database.insert(sql, params);
  }

  static async findById(id: number): Promise<ConsultationMessageRecord | null> {
    const sql = 'SELECT * FROM consultation_message WHERE id = ?';
    return await Database.queryOne<ConsultationMessageRecord>(sql, [id]);
  }

  static async findByQuestionId(
    questionId: number,
    page: number,
    pageSize: number
  ): Promise<{ items: ConsultationMessageRecord[]; total: number }> {
    const where = 'question_id = ?';
    const params = [questionId];
    const orderBy = 'sent_at ASC, id ASC';
    return await Database.paginate<ConsultationMessageRecord>(
      'consultation_message',
      page,
      pageSize,
      where,
      params,
      orderBy
    );
  }
}

