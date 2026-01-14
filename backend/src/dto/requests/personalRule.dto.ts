import Joi from 'joi';
import { HealthStatusLevel } from '../../types/ruleEngine';

export const createPersonalRuleSchema = Joi.object({
  elder_id: Joi.number().integer().positive().optional().allow(null).messages({
    'number.base': '老人ID必须是数字',
    'number.integer': '老人ID必须是整数',
    'number.positive': '老人ID必须是正数'
  }),
  name: Joi.string().min(1).max(100).required().messages({
    'string.base': '规则名称必须是字符串',
    'string.min': '规则名称长度不能少于1个字符',
    'string.max': '规则名称长度不能超过100个字符',
    'any.required': '规则名称为必填项'
  }),
  level: Joi.string()
    .valid('NORMAL', 'MILD', 'MODERATE', 'SEVERE')
    .required()
    .messages({
      'string.base': '规则等级必须是字符串',
      'any.only': '规则等级只能是NORMAL、MILD、MODERATE或SEVERE',
      'any.required': '规则等级为必填项'
    }),
  logic: Joi.object().required().messages({
    'object.base': '规则逻辑必须是对象',
    'any.required': '规则逻辑为必填项'
  }),
  message_template: Joi.string().max(500).optional().allow(null, '').messages({
    'string.base': '提示模板必须是字符串',
    'string.max': '提示模板长度不能超过500个字符'
  }),
  is_active: Joi.boolean().optional().messages({
    'boolean.base': '是否启用必须是布尔值'
  })
});

export const updatePersonalRuleSchema = Joi.object({
  elder_id: Joi.number().integer().positive().optional().allow(null).messages({
    'number.base': '老人ID必须是数字',
    'number.integer': '老人ID必须是整数',
    'number.positive': '老人ID必须是正数'
  }),
  name: Joi.string().min(1).max(100).optional().messages({
    'string.base': '规则名称必须是字符串',
    'string.min': '规则名称长度不能少于1个字符',
    'string.max': '规则名称长度不能超过100个字符'
  }),
  level: Joi.string()
    .valid('NORMAL', 'MILD', 'MODERATE', 'SEVERE')
    .optional()
    .messages({
      'string.base': '规则等级必须是字符串',
      'any.only': '规则等级只能是NORMAL、MILD、MODERATE或SEVERE'
    }),
  logic: Joi.object().optional().messages({
    'object.base': '规则逻辑必须是对象'
  }),
  message_template: Joi.string().max(500).optional().allow(null, '').messages({
    'string.base': '提示模板必须是字符串',
    'string.max': '提示模板长度不能超过500个字符'
  }),
  is_active: Joi.boolean().optional().messages({
    'boolean.base': '是否启用必须是布尔值'
  })
});

export const queryPersonalRuleSchema = Joi.object({
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
  elder_id: Joi.number().integer().positive().optional().allow(null, '').messages({
    'number.base': '老人ID必须是数字',
    'number.integer': '老人ID必须是整数',
    'number.positive': '老人ID必须是正数'
  })
});

export interface CreatePersonalRuleRequest {
  elder_id?: number | null;
  name: string;
  level: HealthStatusLevel;
  logic: unknown;
  message_template?: string | null;
  is_active?: boolean;
}

export interface UpdatePersonalRuleRequest {
  elder_id?: number | null;
  name?: string;
  level?: HealthStatusLevel;
  logic?: unknown;
  message_template?: string | null;
  is_active?: boolean;
}

export interface QueryPersonalRuleRequest {
  page: number;
  pageSize: number;
  elder_id?: number | null;
}

