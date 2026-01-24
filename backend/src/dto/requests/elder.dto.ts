import Joi from 'joi';
import { PaginationQuery } from './common.dto';

export const createElderSchema = Joi.object({
  name: Joi.string().min(1).max(50).required().messages({
    'string.base': '姓名必须是字符串',
    'string.empty': '姓名不能为空',
    'string.min': '姓名长度不能少于1个字符',
    'string.max': '姓名长度不能超过50个字符',
    'any.required': '姓名为必填项'
  }),
  gender: Joi.number().integer().valid(0, 1).required().messages({
    'number.base': '性别必须是数字',
    'number.integer': '性别必须是整数',
    'any.only': '性别只能是0（女）或1（男）',
    'any.required': '性别为必填项'
  }),
  birth_date: Joi.string().isoDate().required().messages({
    'string.base': '出生日期必须是字符串',
    'string.isoDate': '出生日期格式不正确',
    'any.required': '出生日期为必填项'
  }),
  phone: Joi.string().pattern(/^1[3-9]\d{9}$/).required().messages({
    'string.base': '联系电话必须是字符串',
    'string.pattern.base': '联系电话格式不正确',
    'any.required': '联系电话为必填项'
  }),
  emergency_contact: Joi.string().min(1).max(50).required().messages({
    'string.base': '紧急联系人必须是字符串',
    'string.empty': '紧急联系人不能为空',
    'string.min': '紧急联系人长度不能少于1个字符',
    'string.max': '紧急联系人长度不能超过50个字符',
    'any.required': '紧急联系人为必填项'
  }),
  address: Joi.string().max(200).optional().allow('').messages({
    'string.base': '家庭住址必须是字符串',
    'string.max': '家庭住址长度不能超过200个字符'
  }),
  height: Joi.number().positive().max(300).optional().allow(null).messages({
    'number.base': '身高必须是数字',
    'number.positive': '身高必须是正数',
    'number.max': '身高不能超过300厘米'
  }),
  weight: Joi.number().positive().max(500).optional().allow(null).messages({
    'number.base': '体重必须是数字',
    'number.positive': '体重必须是正数',
    'number.max': '体重不能超过500公斤'
  }),
  blood_type: Joi.string().valid('A', 'B', 'AB', 'O').optional().allow(null, '').messages({
    'string.base': '血型必须是字符串',
    'any.only': '血型只能是A、B、AB或O'
  })
});

export const updateElderSchema = Joi.object({
  name: Joi.string().min(1).max(50).optional().messages({
    'string.base': '姓名必须是字符串',
    'string.empty': '姓名不能为空',
    'string.min': '姓名长度不能少于1个字符',
    'string.max': '姓名长度不能超过50个字符'
  }),
  gender: Joi.number().integer().valid(0, 1).optional().messages({
    'number.base': '性别必须是数字',
    'number.integer': '性别必须是整数',
    'any.only': '性别只能是0（女）或1（男）'
  }),
  birth_date: Joi.string().isoDate().optional().messages({
    'string.base': '出生日期必须是字符串',
    'string.isoDate': '出生日期格式不正确'
  }),
  phone: Joi.string().pattern(/^1[3-9]\d{9}$/).optional().messages({
    'string.base': '联系电话必须是字符串',
    'string.pattern.base': '联系电话格式不正确'
  }),
  emergency_contact: Joi.string().min(1).max(50).optional().messages({
    'string.base': '紧急联系人必须是字符串',
    'string.empty': '紧急联系人不能为空',
    'string.min': '紧急联系人长度不能少于1个字符',
    'string.max': '紧急联系人长度不能超过50个字符'
  }),
  address: Joi.string().max(200).optional().allow('').messages({
    'string.base': '家庭住址必须是字符串',
    'string.max': '家庭住址长度不能超过200个字符'
  }),
  height: Joi.number().positive().max(300).optional().allow(null).messages({
    'number.base': '身高必须是数字',
    'number.positive': '身高必须是正数',
    'number.max': '身高不能超过300厘米'
  }),
  weight: Joi.number().positive().max(500).optional().allow(null).messages({
    'number.base': '体重必须是数字',
    'number.positive': '体重必须是正数',
    'number.max': '体重不能超过500公斤'
  }),
  blood_type: Joi.string().valid('A', 'B', 'AB', 'O').optional().allow(null, '').messages({
    'string.base': '血型必须是字符串',
    'any.only': '血型只能是A、B、AB或O'
  })
});

export const queryElderSchema = Joi.object({
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
  name: Joi.string().max(50).optional().allow('').messages({
    'string.base': '姓名必须是字符串',
    'string.max': '姓名长度不能超过50个字符'
  }),
  phone: Joi.string().max(20).optional().allow('').messages({
    'string.base': '手机号必须是字符串',
    'string.max': '手机号长度不能超过20个字符'
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

export interface CreateElderRequest {
  name: string;
  gender: number;
  birth_date: string;
  phone: string;
  emergency_contact: string;
  address?: string;
  height?: number;
  weight?: number;
  blood_type?: string;
}

export interface UpdateElderRequest {
  name?: string;
  gender?: number;
  birth_date?: string;
  phone?: string;
  address?: string;
  emergency_contact?: string;
  height?: number;
  weight?: number;
  blood_type?: string;
}

export interface QueryElderRequest extends PaginationQuery {
  name?: string;
  phone?: string;
  orderBy?: string;
}

export interface ElderResponse {
  id: number;
  user_id: number | null; // Added user_id for frontend to use in relations
  name: string;
  gender: number;
  birth_date: string;
  phone: string;
  address: string | null;
  emergency_contact: string;
  height: number | null;
  weight: number | null;
  blood_type: string | null;
  age: number;
  created_at: string;
  updated_at: string;
}
