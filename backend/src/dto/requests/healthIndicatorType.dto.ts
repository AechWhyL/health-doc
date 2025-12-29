import Joi from 'joi';

export const createHealthIndicatorTypeSchema = Joi.object({
  indicator_code: Joi.string().max(50).required().messages({
    'string.empty': '指标编码不能为空',
    'string.max': '指标编码长度不能超过50个字符',
    'any.required': '指标编码为必填项'
  }),
  indicator_name: Joi.string().max(100).required().messages({
    'string.empty': '指标名称不能为空',
    'string.max': '指标名称长度不能超过100个字符',
    'any.required': '指标名称为必填项'
  }),
  unit: Joi.string().max(20).required().messages({
    'string.empty': '单位不能为空',
    'string.max': '单位长度不能超过20个字符',
    'any.required': '单位为必填项'
  }),
  min_value: Joi.number().required().messages({
    'number.base': '最小值必须是数字',
    'any.required': '最小值为必填项'
  }),
  max_value: Joi.number().required().messages({
    'number.base': '最大值必须是数字',
    'any.required': '最大值为必填项'
  }),
  form_config: Joi.object().optional(),
  status: Joi.number().valid(0, 1).default(1).messages({
    'number.base': '状态必须是数字',
    'any.only': '状态只能是0或1'
  }),
  sort_order: Joi.number().integer().default(0).messages({
    'number.base': '排序序号必须是数字',
    'number.integer': '排序序号必须是整数'
  })
}).custom((value, helpers) => {
  if (value.min_value >= value.max_value) {
    return helpers.error('any.invalid');
  }
  return value;
}).messages({
  'any.invalid': '最小值必须小于最大值'
});

export const updateHealthIndicatorTypeSchema = Joi.object({
  indicator_code: Joi.string().max(50).optional(),
  indicator_name: Joi.string().max(100).optional(),
  unit: Joi.string().max(20).optional(),
  min_value: Joi.number().optional(),
  max_value: Joi.number().optional(),
  form_config: Joi.object().optional(),
  status: Joi.number().valid(0, 1).optional(),
  sort_order: Joi.number().integer().optional()
}).custom((value, helpers) => {
  if (value.min_value !== undefined && value.max_value !== undefined) {
    if (value.min_value >= value.max_value) {
      return helpers.error('any.invalid');
    }
  }
  return value;
}).messages({
  'any.invalid': '最小值必须小于最大值'
});

export interface CreateHealthIndicatorTypeRequest {
  indicator_code: string;
  indicator_name: string;
  unit: string;
  min_value: number;
  max_value: number;
  form_config?: any;
  status?: number;
  sort_order?: number;
}

export interface UpdateHealthIndicatorTypeRequest {
  indicator_code?: string;
  indicator_name?: string;
  unit?: string;
  min_value?: number;
  max_value?: number;
  form_config?: any;
  status?: number;
  sort_order?: number;
}

export interface HealthIndicatorTypeResponse {
  id: number;
  indicator_code: string;
  indicator_name: string;
  unit: string;
  min_value: number;
  max_value: number;
  form_config?: any;
  status: number;
  sort_order: number;
  created_at: string;
  updated_at: string;
}
