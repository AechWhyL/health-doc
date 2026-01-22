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

    // 使用认证用户的ID作为creator_id
    if (!ctx.state.user || !ctx.state.user.userId) {
      ctx.unauthorized('未认证或用户信息缺失');
      return;
    }

    data.creator_id = ctx.state.user.userId;

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
    const { page, pageSize, status, creator_id, target_staff_id, user_id, category, orderBy } = data;

    // If authenticated and no specific filter provided, use user_id to match
    // either creator_id OR target_staff_id (for "my consultations")
    let effectiveUserId = user_id;
    if (!effectiveUserId && !creator_id && !target_staff_id && ctx.state.user) {
      effectiveUserId = ctx.state.user.userId;
    }
    console.log('ctx.state.user:', ctx.state.user);
    console.log('effectiveUserId:', effectiveUserId);

    const { items, total } = await ConsultationService.getQuestionList({
      page,
      pageSize,
      status,
      creator_id,
      target_staff_id,
      user_id: effectiveUserId,
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

