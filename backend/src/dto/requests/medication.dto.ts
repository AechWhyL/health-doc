import Joi from 'joi';
import { PaginationQuery } from './common.dto';

export const createMedicationSchema = Joi.object({
  elder_id: Joi.number().integer().positive().required().messages({
    'number.base': '老人ID必须是数字',
    'number.integer': '老人ID必须是整数',
    'number.positive': '老人ID必须是正数',
    'any.required': '老人ID为必填项'
  }),
  drug_name: Joi.string().min(1).max(100).required().messages({
    'string.base': '药品名称必须是字符串',
    'string.empty': '药品名称不能为空',
    'string.min': '药品名称长度不能少于1个字符',
    'string.max': '药品名称长度不能超过100个字符',
    'any.required': '药品名称为必填项'
  }),
  dosage: Joi.string().max(50).optional().allow('').messages({
    'string.base': '用药剂量必须是字符串',
    'string.max': '用药剂量长度不能超过50个字符'
  }),
  frequency: Joi.string().max(50).optional().allow('').messages({
    'string.base': '用药频次必须是字符串',
    'string.max': '用药频次长度不能超过50个字符'
  }),
  start_date: Joi.date().iso().required().messages({
    'date.base': '开始用药日期必须是有效的日期',
    'date.format': '开始用药日期格式不正确',
    'any.required': '开始用药日期为必填项'
  }),
  end_date: Joi.date().iso().optional().allow(null).messages({
    'date.base': '结束用药日期必须是有效的日期',
    'date.format': '结束用药日期格式不正确'
  }),
  notes: Joi.string().max(500).optional().allow('').messages({
    'string.base': '备注必须是字符串',
    'string.max': '备注长度不能超过500个字符'
  })
});

export const updateMedicationSchema = Joi.object({
  drug_name: Joi.string().min(1).max(100).optional().messages({
    'string.base': '药品名称必须是字符串',
    'string.empty': '药品名称不能为空',
    'string.min': '药品名称长度不能少于1个字符',
    'string.max': '药品名称长度不能超过100个字符'
  }),
  dosage: Joi.string().max(50).optional().allow('').messages({
    'string.base': '用药剂量必须是字符串',
    'string.max': '用药剂量长度不能超过50个字符'
  }),
  frequency: Joi.string().max(50).optional().allow('').messages({
    'string.base': '用药频次必须是字符串',
    'string.max': '用药频次长度不能超过50个字符'
  }),
  start_date: Joi.date().iso().optional().messages({
    'date.base': '开始用药日期必须是有效的日期',
    'date.format': '开始用药日期格式不正确'
  }),
  end_date: Joi.date().iso().optional().allow(null).messages({
    'date.base': '结束用药日期必须是有效的日期',
    'date.format': '结束用药日期格式不正确'
  }),
  notes: Joi.string().max(500).optional().allow('').messages({
    'string.base': '备注必须是字符串',
    'string.max': '备注长度不能超过500个字符'
  })
});

export const queryMedicationSchema = Joi.object({
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
  elder_id: Joi.number().integer().positive().optional().messages({
    'number.base': '老人ID必须是数字',
    'number.integer': '老人ID必须是整数',
    'number.positive': '老人ID必须是正数'
  }),
  drug_name: Joi.string().max(100).optional().allow('').messages({
    'string.base': '药品名称必须是字符串',
    'string.max': '药品名称长度不能超过100个字符'
  }),
  start_date: Joi.date().iso().optional().messages({
    'date.base': '开始日期必须是有效的日期',
    'date.format': '开始日期格式不正确'
  }),
  end_date: Joi.date().iso().optional().messages({
    'date.base': '结束日期必须是有效的日期',
    'date.format': '结束日期格式不正确'
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

export const elderIdParamSchema = Joi.object({
  elder_id: Joi.number().integer().positive().required().messages({
    'number.base': '老人ID必须是数字',
    'number.integer': '老人ID必须是整数',
    'number.positive': '老人ID必须是正数',
    'any.required': '老人ID为必填项'
  })
});

export interface CreateMedicationRequest {
  elder_id: number;
  drug_name: string;
  dosage?: string;
  frequency?: string;
  start_date: string;
  end_date?: string;
  notes?: string;
}

export interface UpdateMedicationRequest {
  drug_name?: string;
  dosage?: string;
  frequency?: string;
  start_date?: string;
  end_date?: string;
  notes?: string;
}

export interface QueryMedicationRequest extends PaginationQuery {
  elder_id?: number;
  drug_name?: string;
  start_date?: string;
  end_date?: string;
  orderBy?: string;
}

export interface MedicationResponse {
  id: number;
  elder_id: number;
  drug_name: string;
  dosage: string | null;
  frequency: string | null;
  start_date: string;
  end_date: string | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
}
