import { Database } from '../config/database';
import { ConsultationAttachmentRecord } from '../types/consultation';

export class ConsultationAttachmentRepository {
  static async createMany(
    attachments: Omit<ConsultationAttachmentRecord, 'id' | 'created_at'>[]
  ): Promise<void> {
    if (attachments.length === 0) {
      return;
    }

    const sql = `
      INSERT INTO consultation_attachment (
        message_id,
        url,
        thumbnail_url,
        duration,
        size
      )
      VALUES ${attachments.map(() => '(?, ?, ?, ?, ?)').join(', ')}
    `;

    const params: any[] = [];
    for (const attachment of attachments) {
      params.push(
        attachment.message_id,
        attachment.url,
        attachment.thumbnail_url ?? null,
        attachment.duration ?? null,
        attachment.size ?? null
      );
    }

    await Database.insert(sql, params);
  }

  static async findByMessageId(messageId: number): Promise<ConsultationAttachmentRecord[]> {
    const sql = 'SELECT * FROM consultation_attachment WHERE message_id = ?';
    return await Database.query<ConsultationAttachmentRecord>(sql, [messageId]);
  }
}

