import Joi from 'joi';
import { PaginationQuery } from './common.dto';

export const createDailyHealthMeasurementSchema = Joi.object({
  elder_id: Joi.number().integer().positive().required().messages({
    'number.base': '老人ID必须是数字',
    'number.integer': '老人ID必须是整数',
    'number.positive': '老人ID必须是正数',
    'any.required': '老人ID为必填项'
  }),
  measured_at: Joi.date().iso().required().messages({
    'date.base': '测量时间必须是有效的日期',
    'any.required': '测量时间为必填项'
  }),
  sbp: Joi.number().precision(2).optional(),
  dbp: Joi.number().precision(2).optional(),
  fpg: Joi.number().precision(2).optional(),
  ppg_2h: Joi.number().precision(2).optional(),
  weight: Joi.number().precision(2).optional(),
  steps: Joi.number().integer().min(0).optional(),
  source: Joi.string().valid('MANUAL', 'DEVICE', 'REPORT').default('MANUAL'),
  remark: Joi.string().max(255).optional().messages({
    'string.max': '备注长度不能超过255个字符'
  })
});

export const updateDailyHealthMeasurementSchema = Joi.object({
  measured_at: Joi.date().iso().optional(),
  sbp: Joi.number().precision(2).optional(),
  dbp: Joi.number().precision(2).optional(),
  fpg: Joi.number().precision(2).optional(),
  ppg_2h: Joi.number().precision(2).optional(),
  weight: Joi.number().precision(2).optional(),
  steps: Joi.number().integer().min(0).optional(),
  source: Joi.string().valid('MANUAL', 'DEVICE', 'REPORT').optional(),
  remark: Joi.string().max(255).optional().messages({
    'string.max': '备注长度不能超过255个字符'
  })
});

export const queryDailyHealthMeasurementSchema = Joi.object({
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
  })
});

export const idParamSchema = Joi.object({
  id: Joi.number().integer().positive().required().messages({
    'number.base': 'ID必须是数字',
    'number.integer': 'ID必须是整数',
    'number.positive': 'ID必须是正数',
    'any.required': 'ID为必填项'
  })
});

export interface CreateDailyHealthMeasurementRequest {
  elder_id: number;
  measured_at: string;
  sbp?: number;
  dbp?: number;
  fpg?: number;
  ppg_2h?: number;
  weight?: number;
  steps?: number;
  source?: string;
  remark?: string;
}

export interface UpdateDailyHealthMeasurementRequest {
  measured_at?: string;
  sbp?: number;
  dbp?: number;
  fpg?: number;
  ppg_2h?: number;
  weight?: number;
  steps?: number;
  source?: string;
  remark?: string;
}

export interface QueryDailyHealthMeasurementRequest extends PaginationQuery {
  elder_id?: number;
}

export interface DailyHealthMeasurementResponse {
  id: number;
  elder_id: number;
  measured_at: string;
  sbp?: number;
  dbp?: number;
  fpg?: number;
  ppg_2h?: number;
  weight?: number;
  steps?: number;
  source: string;
  remark?: string;
  created_at: string;
  updated_at: string;
}
