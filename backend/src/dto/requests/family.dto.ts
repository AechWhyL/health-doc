import Joi from 'joi';
import { PaginationQuery } from './common.dto';

export const createFamilySchema = Joi.object({
    user_id: Joi.number().integer().positive().required().messages({
        'number.base': '用户ID必须是数字',
        'number.integer': '用户ID必须是整数',
        'number.positive': '用户ID必须是正数',
        'any.required': '用户ID为必填项'
    }),
    name: Joi.string().min(1).max(50).required().messages({
        'string.base': '姓名必须是字符串',
        'string.empty': '姓名不能为空',
        'string.min': '姓名长度不能少于1个字符',
        'string.max': '姓名长度不能超过50个字符',
        'any.required': '姓名为必填项'
    }),
    gender: Joi.number().integer().valid(0, 1, 2).default(0).messages({
        'number.base': '性别必须是数字',
        'number.integer': '性别必须是整数',
        'any.only': '性别只能是0（未知）、1（男）或2（女）'
    }),
    phone: Joi.string().pattern(/^1[3-9]\d{9}$/).optional().allow('', null).messages({
        'string.base': '联系电话必须是字符串',
        'string.pattern.base': '联系电话格式不正确'
    })
});

export const updateFamilySchema = Joi.object({
    name: Joi.string().min(1).max(50).optional().messages({
        'string.base': '姓名必须是字符串',
        'string.empty': '姓名不能为空',
        'string.min': '姓名长度不能少于1个字符',
        'string.max': '姓名长度不能超过50个字符'
    }),
    gender: Joi.number().integer().valid(0, 1, 2).optional().messages({
        'number.base': '性别必须是数字',
        'number.integer': '性别必须是整数',
        'any.only': '性别只能是0（未知）、1（男）或2（女）'
    }),
    phone: Joi.string().pattern(/^1[3-9]\d{9}$/).optional().allow('', null).messages({
        'string.base': '联系电话必须是字符串',
        'string.pattern.base': '联系电话格式不正确'
    })
});

export const queryFamilySchema = Joi.object({
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

export const userIdParamSchema = Joi.object({
    user_id: Joi.number().integer().positive().required().messages({
        'number.base': '用户ID必须是数字',
        'number.integer': '用户ID必须是整数',
        'number.positive': '用户ID必须是正数',
        'any.required': '用户ID为必填项'
    })
});

export interface CreateFamilyRequest {
    user_id: number;
    name: string;
    gender?: number;
    phone?: string;
}

export interface UpdateFamilyRequest {
    name?: string;
    gender?: number;
    phone?: string;
}

export interface QueryFamilyRequest extends PaginationQuery {
    name?: string;
}

export interface FamilyResponse {
    id: number;
    user_id: number;
    name: string;
    gender: number;
    phone: string | null;
    created_at: string;
    updated_at: string;
}
