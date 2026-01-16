import {
  ConsultationAttachmentRecord,
  ConsultationMessageRecord,
  ConsultationPriority,
  ConsultationQuestionRecord,
  ConsultationStatus
} from '../types/consultation';
import {
  CreateConsultationMessageRequest,
  CreateConsultationQuestionRequest,
  ConsultationAttachmentInput,
  ConsultationMessageResponse,
  ConsultationQuestionResponse,
  QueryConsultationMessageRequest,
  QueryConsultationQuestionRequest
} from '../dto/requests/consultation.dto';
import { ConsultationQuestionRepository } from '../repositories/consultationQuestion.repository';
import { ConsultationMessageRepository } from '../repositories/consultationMessage.repository';
import { ConsultationAttachmentRepository } from '../repositories/consultationAttachment.repository';
import { Database } from '../config/database';

export class ConsultationService {
  private static generateQuestionCode(): string {
    const now = new Date();
    const timestamp = now.getTime();
    return `CQ${timestamp}`;
  }

  static async createQuestion(
    data: CreateConsultationQuestionRequest
  ): Promise<ConsultationQuestionResponse> {
    const code = this.generateQuestionCode();

    const record: Omit<
      ConsultationQuestionRecord,
      'id' | 'created_at' | 'updated_at' | 'resolved_at' | 'closed_at'
    > = {
      code,
      title: data.title,
      description: data.description ?? null,
      creator_type: data.creator_type,
      creator_id: data.creator_id,
      target_staff_id: data.target_staff_id,
      category: data.category ?? null,
      status: 'PENDING',
      priority: (data.priority || 'NORMAL') as ConsultationPriority,
      is_anonymous: data.is_anonymous ?? false
    };

    const id = await ConsultationQuestionRepository.create(record);
    const created = await ConsultationQuestionRepository.findById(id);
    if (!created) {
      throw new Error('创建咨询问题失败');
    }

    return created;
  }

  static async getQuestionById(id: number): Promise<ConsultationQuestionResponse> {
    const question = await ConsultationQuestionRepository.findById(id);
    if (!question) {
      throw new Error('咨询问题不存在');
    }
    return question;
  }

  static async getQuestionList(
    query: QueryConsultationQuestionRequest
  ): Promise<{ items: ConsultationQuestionResponse[]; total: number }> {
    const { page, pageSize, status, creator_id, target_staff_id, category, orderBy } = query;

    let where = '1=1';
    const params: any[] = [];

    if (status) {
      where += ' AND status = ?';
      params.push(status);
    }

    if (creator_id) {
      where += ' AND creator_id = ?';
      params.push(creator_id);
    }

    if (target_staff_id) {
      where += ' AND target_staff_id = ?';
      params.push(target_staff_id);
    }

    if (category) {
      where += ' AND category = ?';
      params.push(category);
    }

    const orderByClause = orderBy && orderBy.trim().length > 0 ? orderBy : 'created_at DESC';

    const { items, total } = await ConsultationQuestionRepository.findAll(
      page,
      pageSize,
      where,
      params,
      orderByClause
    );

    return {
      items,
      total
    };
  }

  static async createMessage(
    questionId: number,
    data: CreateConsultationMessageRequest
  ): Promise<ConsultationMessageResponse> {
    const question = await ConsultationQuestionRepository.findById(questionId);
    if (!question) {
      throw new Error('咨询问题不存在');
    }

    const sentAt = new Date().toISOString().slice(0, 19).replace('T', ' ');

    const messageRecord: Omit<ConsultationMessageRecord, 'id' | 'created_at'> = {
      question_id: questionId,
      sender_type: data.sender_type,
      sender_id: data.sender_id ?? null,
      role_display_name: data.role_display_name ?? null,
      content_type: data.content_type,
      content_text: data.content_text ?? null,
      sent_at: sentAt,
      status: 'SENT',
      is_visible_to_patient: true
    };

    const connection = await Database.beginTransaction();

    try {
      const insertMessageSql = `
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

      const messageParams = [
        messageRecord.question_id,
        messageRecord.sender_type,
        messageRecord.sender_id ?? null,
        messageRecord.role_display_name ?? null,
        messageRecord.content_type,
        messageRecord.content_text ?? null,
        messageRecord.sent_at,
        messageRecord.status,
        messageRecord.is_visible_to_patient ?? true
      ];

      const [result] = await connection.execute(insertMessageSql, messageParams);
      const messageId = (result as any).insertId as number;

      const attachments: ConsultationAttachmentRecord[] = [];
      if (data.attachments && data.attachments.length > 0) {
        for (const attachment of data.attachments) {
          attachments.push(
            this.toAttachmentRecord(messageId, attachment)
          );
        }

        if (attachments.length > 0) {
          const insertAttachmentSql = `
            INSERT INTO consultation_attachment (
              message_id,
              url,
              thumbnail_url,
              duration,
              size
            )
            VALUES ${attachments.map(() => '(?, ?, ?, ?, ?)').join(', ')}
          `;

          const attachmentParams: any[] = [];
          for (const attachment of attachments) {
            attachmentParams.push(
              attachment.message_id,
              attachment.url,
              attachment.thumbnail_url ?? null,
              attachment.duration ?? null,
              attachment.size ?? null
            );
          }

          await connection.execute(insertAttachmentSql, attachmentParams);
        }
      }

      await Database.commitTransaction(connection);

      const createdMessage = await ConsultationMessageRepository.findById(messageId);
      if (!createdMessage) {
        throw new Error('创建咨询消息失败');
      }

      const response: ConsultationMessageResponse = {
        ...createdMessage,
        attachments: data.attachments
      };

      if (question.status === 'PENDING') {
        await ConsultationQuestionRepository.updateStatus(questionId, 'IN_PROGRESS');
      }

      return response;
    } catch (error) {
      await Database.rollbackTransaction(connection);
      throw error;
    }
  }

  static async getMessageList(
    questionId: number,
    query: QueryConsultationMessageRequest
  ): Promise<{ items: ConsultationMessageResponse[]; total: number }> {
    console.log("questionId", questionId)
    const question = await ConsultationQuestionRepository.findById(questionId);
    if (!question) {
      throw new Error('咨询问题不存在');
    }

    const { page, pageSize } = query;
    const { items, total } = await ConsultationMessageRepository.findByQuestionId(
      questionId,
      page,
      pageSize
    );

    const responses: ConsultationMessageResponse[] = [];
    for (const item of items) {
      const attachments = await ConsultationAttachmentRepository.findByMessageId(item.id!);
      const attachmentInputs: ConsultationAttachmentInput[] = attachments.map(att => ({
        url: att.url,
        thumbnail_url: att.thumbnail_url ?? undefined,
        duration: att.duration ?? undefined,
        size: att.size ?? undefined
      }));

      responses.push({
        ...item,
        attachments: attachmentInputs
      });
    }

    return {
      items: responses,
      total
    };
  }

  private static toAttachmentRecord(
    messageId: number,
    input: ConsultationAttachmentInput
  ): ConsultationAttachmentRecord {
    return {
      message_id: messageId,
      url: input.url,
      thumbnail_url: input.thumbnail_url ?? null,
      duration: input.duration ?? null,
      size: input.size ?? null
    };
  }
}

