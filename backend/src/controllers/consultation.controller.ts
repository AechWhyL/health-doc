import { Context } from 'koa';
import {
  CreateConsultationMessageRequest,
  CreateConsultationQuestionRequest,
  QueryConsultationMessageRequest,
  QueryConsultationQuestionRequest
} from '../dto/requests/consultation.dto';
import { ConsultationService } from '../services/consultation.service';

export class ConsultationController {
  static async createQuestion(ctx: Context) {
    const data: CreateConsultationQuestionRequest = ctx.state.validatedData || ctx.request.body;
    const result = await ConsultationService.createQuestion(data);
    ctx.success(result, '咨询问题创建成功');
  }

  static async getQuestionById(ctx: Context) {
    const { id } = ctx.state.validatedData || ctx.params;
    const questionId = Number(id);
    const result = await ConsultationService.getQuestionById(questionId);
    ctx.success(result);
  }

  static async getQuestionList(ctx: Context) {
    const data: QueryConsultationQuestionRequest = ctx.state.validatedData || ctx.query;
    const { page, pageSize, status, creator_id, target_staff_id, category, orderBy } = data;

    const { items, total } = await ConsultationService.getQuestionList({
      page,
      pageSize,
      status,
      creator_id,
      target_staff_id,
      category,
      orderBy
    });

    ctx.paginate(items, page, pageSize, total);
  }

  static async createMessage(ctx: Context) {
    const { id } = ctx.params;
    const questionId = Number(id);
    const data: CreateConsultationMessageRequest = ctx.state.validatedData || ctx.request.body;
    const result = await ConsultationService.createMessage(questionId, data);
    ctx.success(result, '咨询消息创建成功');
  }

  static async getMessageList(ctx: Context) {
    const { id } = ctx.params;
    const questionId = Number(id);
    const data: QueryConsultationMessageRequest = ctx.state.validatedData || ctx.query;
    const { page, pageSize } = data;

    const { items, total } = await ConsultationService.getMessageList(questionId, {
      page,
      pageSize
    });

    ctx.paginate(items, page, pageSize, total);
  }
}

