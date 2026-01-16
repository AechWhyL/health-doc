import { httpRequest } from './HttpUtil';
import { RequestEnum } from './httpEnum';
import { ConsultationQuestion, ConsultationMessage } from '../../models/ConsultationModels';
import { ApiResponse, PaginationResponse } from '../../models/DTO/types';

export class ConsultationService {
  
  static getQuestionList(params?: Record<string, Object>): Promise<ApiResponse<PaginationResponse<ConsultationQuestion>>> {
    return httpRequest<ApiResponse<PaginationResponse<ConsultationQuestion>>, Record<string, Object>>({
      url: '/api/v1/consultation/questions',
      method: RequestEnum.GET,
      params: params
    });
  }

  static getQuestionById(id: number): Promise<ApiResponse<ConsultationQuestion>> {
    return httpRequest<ApiResponse<ConsultationQuestion>, Object>({
      url: `/api/v1/consultation/questions/${id}`,
      method: RequestEnum.GET
    });
  }

  static getMessageList(questionId: number, params?: Record<string, Object>): Promise<ApiResponse<PaginationResponse<ConsultationMessage>>> {
    return httpRequest<ApiResponse<PaginationResponse<ConsultationMessage>>, Record<string, Object>>({
      url: `/api/v1/consultation/questions/${questionId}/messages`,
      method: RequestEnum.GET,
      params: params
    });
  }

  static createMessage(questionId: number, data: Object): Promise<ApiResponse<ConsultationMessage>> {
    return httpRequest<ApiResponse<ConsultationMessage>, Object>({
      url: `/api/v1/consultation/questions/${questionId}/messages`,
      method: RequestEnum.POST,
      params: data
    });
  }
}
