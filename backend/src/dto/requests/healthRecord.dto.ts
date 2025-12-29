import Joi from 'joi';

export const createHealthRecordSchema = Joi.object({
  elder_id: Joi.number().integer().positive().required().messages({
    'number.base': '老人ID必须是数字',
    'number.integer': '老人ID必须是整数',
    'number.positive': '老人ID必须是正数',
    'any.required': '老人ID为必填项'
  }),
  category_id: Joi.number().integer().positive().required().messages({
    'number.base': '分类ID必须是数字',
    'number.integer': '分类ID必须是整数',
    'number.positive': '分类ID必须是正数',
    'any.required': '分类ID为必填项'
  }),
  record_title: Joi.string().max(100).required().messages({
    'string.base': '记录标题必须是字符串',
    'string.max': '记录标题长度不能超过100个字符',
    'any.required': '记录标题为必填项'
  }),
  record_content: Joi.string().required().messages({
    'string.base': '记录内容必须是字符串',
    'any.required': '记录内容为必填项'
  }),
  record_date: Joi.date().iso().required().messages({
    'date.base': '记录日期必须是有效的日期',
    'any.required': '记录日期为必填项'
  })
});

export const updateHealthRecordSchema = Joi.object({
  category_id: Joi.number().integer().positive().optional(),
  record_title: Joi.string().max(100).optional(),
  record_content: Joi.string().optional(),
  record_date: Joi.date().iso().optional()
});

export const queryHealthRecordSchema = Joi.object({
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
  elder_id: Joi.number().integer().positive().optional(),
  category_id: Joi.number().integer().positive().optional(),
  start_date: Joi.date().iso().optional(),
  end_date: Joi.date().iso().optional()
});

export interface CreateHealthRecordRequest {
  elder_id: number;
  category_id: number;
  record_title: string;
  record_content: string;
  record_date: string;
}

export interface UpdateHealthRecordRequest {
  category_id?: number;
  record_title?: string;
  record_content?: string;
  record_date?: string;
}

export interface QueryHealthRecordRequest {
  page: number;
  pageSize: number;
  elder_id?: number;
  category_id?: number;
  start_date?: string;
  end_date?: string;
  orderBy?: string;
}

export interface HealthRecordResponse {
  id: number;
  elder_id: number;
  category_id: number;
  record_title: string;
  record_content: string;
  record_date: string;
  created_at: string;
  updated_at: string;
}
