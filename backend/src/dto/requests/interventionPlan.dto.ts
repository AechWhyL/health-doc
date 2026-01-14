import Joi from 'joi';
import { PaginationQuery } from './common.dto';
import { InterventionPlanStatus, InterventionPlanResponse } from '../../types/interventionPlan';

export const createInterventionPlanSchema = Joi.object({
  elderUserId: Joi.number().integer().positive().required().messages({
    'number.base': '老人用户ID必须是数字',
    'number.integer': '老人用户ID必须是整数',
    'number.positive': '老人用户ID必须是正数',
    'any.required': '老人用户ID为必填项'
  }),
  title: Joi.string().min(1).max(100).required().messages({
    'string.base': '计划标题必须是字符串',
    'string.min': '计划标题长度不能少于1个字符',
    'string.max': '计划标题长度不能超过100个字符',
    'any.required': '计划标题为必填项'
  }),
  description: Joi.string().max(1000).allow(null, '').optional().messages({
    'string.base': '计划描述必须是字符串',
    'string.max': '计划描述长度不能超过1000个字符'
  }),
  startDate: Joi.date().iso().required().messages({
    'date.base': '开始日期必须是有效的日期',
    'any.required': '开始日期为必填项'
  }),
  endDate: Joi.date().iso().greater(Joi.ref('startDate')).allow(null).optional().messages({
    'date.base': '结束日期必须是有效的日期',
    'date.greater': '结束日期必须晚于开始日期'
  }),
  createdByUserId: Joi.number().integer().positive().required().messages({
    'number.base': '创建人用户ID必须是数字',
    'number.integer': '创建人用户ID必须是整数',
    'number.positive': '创建人用户ID必须是正数',
    'any.required': '创建人用户ID为必填项'
  })
});

export const updateInterventionPlanSchema = Joi.object({
  title: Joi.string().min(1).max(100).optional().messages({
    'string.base': '计划标题必须是字符串',
    'string.min': '计划标题长度不能少于1个字符',
    'string.max': '计划标题长度不能超过100个字符'
  }),
  description: Joi.string().max(1000).allow(null, '').optional().messages({
    'string.base': '计划描述必须是字符串',
    'string.max': '计划描述长度不能超过1000个字符'
  }),
  startDate: Joi.date().iso().optional().messages({
    'date.base': '开始日期必须是有效的日期'
  }),
  endDate: Joi.date().iso().optional().messages({
    'date.base': '结束日期必须是有效的日期'
  })
}).or('title', 'description', 'startDate', 'endDate');

export const updateInterventionPlanStatusSchema = Joi.object({
  status: Joi.string()
    .valid('DRAFT', 'PENDING', 'ACTIVE', 'PAUSED', 'FINISHED', 'CANCELLED')
    .required()
    .messages({
      'string.base': '计划状态必须是字符串',
      'any.only': '计划状态不合法',
      'any.required': '计划状态为必填项'
    })
});

export const queryInterventionPlanSchema = Joi.object({
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
    .valid('DRAFT', 'PENDING', 'ACTIVE', 'PAUSED', 'FINISHED', 'CANCELLED')
    .optional()
    .messages({
      'string.base': '计划状态必须是字符串',
      'any.only': '计划状态不合法'
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

export const elderUserIdParamSchema = Joi.object({
  elderUserId: Joi.number().integer().positive().required().messages({
    'number.base': '老人用户ID必须是数字',
    'number.integer': '老人用户ID必须是整数',
    'number.positive': '老人用户ID必须是正数',
    'any.required': '老人用户ID为必填项'
  })
});

export interface CreateInterventionPlanRequest {
  elderUserId: number;
  title: string;
  description?: string | null;
  startDate: string;
  endDate?: string | null;
  createdByUserId: number;
}

export interface UpdateInterventionPlanRequest {
  title?: string;
  description?: string | null;
  startDate?: string;
  endDate?: string | null;
}

export interface QueryInterventionPlanRequest extends PaginationQuery {
  status?: InterventionPlanStatus;
  orderBy?: string;
}

export interface InterventionPlanStatusUpdateRequest {
  status: InterventionPlanStatus;
}

export { InterventionPlanResponse };
