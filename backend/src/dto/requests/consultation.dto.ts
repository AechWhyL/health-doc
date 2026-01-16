import Joi from 'joi';
import { PaginationQuery } from './common.dto';
import {
  ConsultationContentType,
  ConsultationCreatorType,
  ConsultationMessageRecord,
  ConsultationPriority,
  ConsultationQuestionRecord,
  ConsultationSenderType,
  ConsultationStatus
} from '../../types/consultation';

export const createConsultationQuestionSchema = Joi.object({
  title: Joi.string().max(200).required().messages({
    'string.base': '标题必须是字符串',
    'string.max': '标题长度不能超过200个字符',
    'any.required': '标题为必填项'
  }),
  description: Joi.string().max(2000).optional().allow('').messages({
    'string.base': '描述必须是字符串',
    'string.max': '描述长度不能超过2000个字符'
  }),
  creator_type: Joi.string()
    .valid('ELDER', 'FAMILY', 'STAFF')
    .required()
    .messages({
      'string.base': '创建人类型必须是字符串',
      'any.only': '创建人类型只能是ELDER、FAMILY或STAFF',
      'any.required': '创建人类型为必填项'
    }),
  creator_id: Joi.number().integer().positive().required().messages({
    'number.base': '创建人ID必须是数字',
    'number.integer': '创建人ID必须是整数',
    'number.positive': '创建人ID必须是正数',
    'any.required': '创建人ID为必填项'
  }),
  target_staff_id: Joi.number().integer().positive().required().messages({
    'number.base': '目标医护人员ID必须是数字',
    'number.integer': '目标医护人员ID必须是整数',
    'number.positive': '目标医护人员ID必须是正数',
    'any.required': '目标医护人员ID为必填项'
  }),
  category: Joi.string().max(100).optional().allow('').messages({
    'string.base': '分类必须是字符串',
    'string.max': '分类长度不能超过100个字符'
  }),
  priority: Joi.string()
    .valid('NORMAL', 'URGENT')
    .default('NORMAL')
    .messages({
      'string.base': '优先级必须是字符串',
      'any.only': '优先级只能是NORMAL或URGENT'
    }),
  is_anonymous: Joi.boolean().optional().messages({
    'boolean.base': '是否匿名必须是布尔值'
  })
});

export const queryConsultationQuestionSchema = Joi.object({
  page: Joi.number().integer().min(1).default(1).messages({
    'number.base': '页码必须是数字',
    'number.integer': '页码必须是整数',
    'number.min': '页码必须大于0'
  }),
  pageSize: Joi.number().integer().min(1).max(100).default(10).messages({
    'number.base': '每页数量必须是数字',
    'number.integer': '每页数量必须是整数',
    'number.min': '每页数量必须大于0',
    'number.max': '每页数量不能超过100'
  }),
  status: Joi.string()
    .valid('PENDING', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')
    .optional()
    .messages({
      'string.base': '状态必须是字符串',
      'any.only': '状态值不合法'
    }),
  creator_id: Joi.number().integer().positive().optional().messages({
    'number.base': '创建人ID必须是数字',
    'number.integer': '创建人ID必须是整数',
    'number.positive': '创建人ID必须是正数'
  }),
  target_staff_id: Joi.number().integer().positive().optional().messages({
    'number.base': '目标医护人员ID必须是数字',
    'number.integer': '目标医护人员ID必须是整数',
    'number.positive': '目标医护人员ID必须是正数'
  }),
  category: Joi.string().max(100).optional().allow('').messages({
    'string.base': '分类必须是字符串',
    'string.max': '分类长度不能超过100个字符'
  }),
  orderBy: Joi.string().optional().allow('')
});

export const idParamSchema = Joi.object({
  id: Joi.number().integer().positive().required().messages({
    'number.base': 'ID必须是数字',
    'number.integer': 'ID必须是整数',
    'number.positive': 'ID必须是正数',
    'any.required': 'ID为必填项'
  })
});

export const createConsultationMessageSchema = Joi.object({
  sender_type: Joi.string()
    .valid('ELDER', 'FAMILY', 'STAFF', 'SYSTEM')
    .required()
    .messages({
      'string.base': '发送方类型必须是字符串',
      'any.only': '发送方类型只能是ELDER、FAMILY、STAFF或SYSTEM',
      'any.required': '发送方类型为必填项'
    }),
  sender_id: Joi.number().integer().positive().optional().messages({
    'number.base': '发送方ID必须是数字',
    'number.integer': '发送方ID必须是整数',
    'number.positive': '发送方ID必须是正数'
  }),
  role_display_name: Joi.string().max(100).optional().allow('').messages({
    'string.base': '展示名称必须是字符串',
    'string.max': '展示名称长度不能超过100个字符'
  }),
  content_type: Joi.string()
    .valid('TEXT', 'IMAGE', 'AUDIO', 'SYSTEM')
    .required()
    .messages({
      'string.base': '消息类型必须是字符串',
      'any.only': '消息类型值不合法',
      'any.required': '消息类型为必填项'
    }),
  content_text: Joi.string().max(4000).optional().allow('').messages({
    'string.base': '消息内容必须是字符串',
    'string.max': '消息内容长度不能超过4000个字符'
  }),
  attachments: Joi.array()
    .items(
      Joi.object({
        url: Joi.string().uri().required().messages({
          'string.base': '附件URL必须是字符串',
          'string.uri': '附件URL必须是有效的URL',
          'any.required': '附件URL为必填项'
        }),
        thumbnail_url: Joi.string().uri().optional().allow('').messages({
          'string.base': '缩略图URL必须是字符串',
          'string.uri': '缩略图URL必须是有效的URL'
        }),
        duration: Joi.number().integer().min(0).optional().messages({
          'number.base': '时长必须是数字',
          'number.integer': '时长必须是整数',
          'number.min': '时长不能为负数'
        }),
        size: Joi.number().integer().min(0).optional().messages({
          'number.base': '文件大小必须是数字',
          'number.integer': '文件大小必须是整数',
          'number.min': '文件大小不能为负数'
        })
      })
    )
    .optional()
});

export const queryConsultationMessageSchema = Joi.object({
  page: Joi.number().integer().min(1).default(1).messages({
    'number.base': '页码必须是数字',
    'number.integer': '页码必须是整数',
    'number.min': '页码必须大于0'
  }),
  pageSize: Joi.number().integer().min(1).max(100).default(20).messages({
    'number.base': '每页数量必须是数字',
    'number.integer': '每页数量必须是整数',
    'number.min': '每页数量必须大于0',
    'number.max': '每页数量不能超过100'
  })
});

export interface CreateConsultationQuestionRequest {
  title: string;
  description?: string;
  creator_type: ConsultationCreatorType;
  creator_id: number;
  target_staff_id: number;
  category?: string;
  priority: ConsultationPriority;
  is_anonymous?: boolean;
}

export interface ConsultationQuestionResponse extends ConsultationQuestionRecord {}

export interface QueryConsultationQuestionRequest extends PaginationQuery {
  status?: ConsultationStatus;
  creator_id?: number;
  target_staff_id?: number;
  category?: string;
  orderBy?: string;
}

export interface ConsultationAttachmentInput {
  url: string;
  thumbnail_url?: string;
  duration?: number;
  size?: number;
}

export interface CreateConsultationMessageRequest {
  sender_type: ConsultationSenderType;
  sender_id?: number;
  role_display_name?: string;
  content_type: ConsultationContentType;
  content_text?: string;
  attachments?: ConsultationAttachmentInput[];
}

export interface ConsultationMessageResponse extends ConsultationMessageRecord {
  attachments?: ConsultationAttachmentInput[];
}

export interface QueryConsultationMessageRequest extends PaginationQuery {}
