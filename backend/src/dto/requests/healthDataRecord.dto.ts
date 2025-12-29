import Joi from 'joi';

export const createHealthDataRecordSchema = Joi.object({
  elder_id: Joi.number().integer().positive().required().messages({
    'number.base': '老人ID必须是数字',
    'number.integer': '老人ID必须是整数',
    'number.positive': '老人ID必须是正数',
    'any.required': '老人ID为必填项'
  }),
  indicator_type_id: Joi.number().integer().positive().required().messages({
    'number.base': '指标类型ID必须是数字',
    'number.integer': '指标类型ID必须是整数',
    'number.positive': '指标类型ID必须是正数',
    'any.required': '指标类型ID为必填项'
  }),
  measure_time: Joi.date().iso().required().messages({
    'date.base': '测量时间必须是有效的日期',
    'any.required': '测量时间为必填项'
  }),
  measure_value: Joi.object().required().messages({
    'object.base': '测量值必须是对象',
    'any.required': '测量值为必填项'
  }),
  measure_context: Joi.object().optional(),
  remark: Joi.string().max(500).optional().messages({
    'string.max': '备注长度不能超过500个字符'
  }),
  data_source: Joi.string().valid('MANUAL', 'DEVICE').default('MANUAL').messages({
    'string.base': '数据来源必须是字符串',
    'any.only': '数据来源只能是MANUAL或DEVICE'
  }),
  input_user_id: Joi.number().integer().positive().required().messages({
    'number.base': '录入人ID必须是数字',
    'number.integer': '录入人ID必须是整数',
    'number.positive': '录入人ID必须是正数',
    'any.required': '录入人ID为必填项'
  }),
  input_user_type: Joi.string().valid('ELDER', 'FAMILY', 'DOCTOR').required().messages({
    'string.base': '录入人类型必须是字符串',
    'any.only': '录入人类型只能是ELDER、FAMILY或DOCTOR',
    'any.required': '录入人类型为必填项'
  })
});

export const updateHealthDataRecordSchema = Joi.object({
  indicator_type_id: Joi.number().integer().positive().optional(),
  measure_time: Joi.date().iso().optional(),
  measure_value: Joi.object().optional(),
  measure_context: Joi.object().optional(),
  remark: Joi.string().max(500).optional(),
  data_source: Joi.string().valid('MANUAL', 'DEVICE').optional(),
  operation_reason: Joi.string().max(500).optional().messages({
    'string.max': '操作原因长度不能超过500个字符'
  })
});

export const queryHealthDataRecordSchema = Joi.object({
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
  indicator_type_id: Joi.number().integer().positive().optional(),
  start_date: Joi.date().iso().optional(),
  end_date: Joi.date().iso().optional(),
  data_source: Joi.string().valid('MANUAL', 'DEVICE').optional()
});

export interface CreateHealthDataRecordRequest {
  elder_id: number;
  indicator_type_id: number;
  measure_time: string;
  measure_value: any;
  measure_context?: any;
  remark?: string;
  data_source?: string;
  input_user_id: number;
  input_user_type: string;
}

export interface UpdateHealthDataRecordRequest {
  indicator_type_id?: number;
  measure_time?: string;
  measure_value?: any;
  measure_context?: any;
  remark?: string;
  data_source?: string;
  operation_reason?: string;
}

export interface QueryHealthDataRecordRequest {
  page?: number;
  pageSize?: number;
  elder_id?: number;
  indicator_type_id?: number;
  start_date?: string;
  end_date?: string;
  data_source?: string;
}

export interface HealthDataRecordResponse {
  id: number;
  elder_id: number;
  indicator_type_id: number;
  indicator_type?: {
    id: number;
    indicator_code: string;
    indicator_name: string;
    unit: string;
  };
  measure_time: string;
  measure_value: any;
  measure_context?: any;
  remark?: string;
  data_source: string;
  input_user_id: number;
  input_user_type: string;
  created_at: string;
  updated_at: string;
}

export interface HealthDataRecordHistoryResponse {
  id: number;
  health_record_id: number;
  operation_type: string;
  before_value?: any;
  after_value?: any;
  operation_reason?: string;
  operator_id: number;
  operator_type: string;
  created_at: string;
}
