import Joi from 'joi';

export const createUserSchema = Joi.object({
  username: Joi.string().alphanum().min(3).max(30).required().messages({
    'string.base': '用户名必须是字符串',
    'string.alphanum': '用户名只能包含字母和数字',
    'string.min': '用户名长度不能少于3个字符',
    'string.max': '用户名长度不能超过30个字符',
    'any.required': '用户名为必填项'
  }),
  password: Joi.string().min(6).max(100).required().messages({
    'string.base': '密码必须是字符串',
    'string.min': '密码长度不能少于6个字符',
    'string.max': '密码长度不能超过100个字符',
    'any.required': '密码为必填项'
  }),
  email: Joi.string().email().optional().allow('').messages({
    'string.base': '邮箱必须是字符串',
    'string.email': '邮箱格式不正确'
  }),
  phone: Joi.string().pattern(/^1[3-9]\d{9}$/).optional().allow('').messages({
    'string.base': '联系电话必须是字符串',
    'string.pattern.base': '联系电话格式不正确'
  }),
  real_name: Joi.string().max(50).optional().allow('').messages({
    'string.base': '真实姓名必须是字符串',
    'string.max': '真实姓名长度不能超过50个字符'
  }),
  avatar: Joi.string().uri().optional().allow('').messages({
    'string.base': '头像必须是字符串',
    'string.uri': '头像必须是有效的URL'
  }),
  status: Joi.string().valid('active', 'inactive', 'locked').optional().messages({
    'string.base': '状态必须是字符串',
    'any.only': '状态只能是active、inactive或locked'
  }),
  is_verified: Joi.boolean().optional().messages({
    'boolean.base': '是否验证必须是布尔值'
  })
});

export const updateUserSchema = Joi.object({
  password: Joi.string().min(6).max(100).optional().messages({
    'string.base': '密码必须是字符串',
    'string.min': '密码长度不能少于6个字符',
    'string.max': '密码长度不能超过100个字符'
  }),
  email: Joi.string().email().optional().allow('').messages({
    'string.base': '邮箱必须是字符串',
    'string.email': '邮箱格式不正确'
  }),
  phone: Joi.string().pattern(/^1[3-9]\d{9}$/).optional().allow('').messages({
    'string.base': '联系电话必须是字符串',
    'string.pattern.base': '联系电话格式不正确'
  }),
  real_name: Joi.string().max(50).optional().allow('').messages({
    'string.base': '真实姓名必须是字符串',
    'string.max': '真实姓名长度不能超过50个字符'
  }),
  avatar: Joi.string().uri().optional().allow('').messages({
    'string.base': '头像必须是字符串',
    'string.uri': '头像必须是有效的URL'
  }),
  status: Joi.string().valid('active', 'inactive', 'locked').optional().messages({
    'string.base': '状态必须是字符串',
    'any.only': '状态只能是active、inactive或locked'
  }),
  is_verified: Joi.boolean().optional().messages({
    'boolean.base': '是否验证必须是布尔值'
  })
});

export const queryUserSchema = Joi.object({
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
  username: Joi.string().max(30).optional().allow('').messages({
    'string.base': '用户名必须是字符串',
    'string.max': '用户名长度不能超过30个字符'
  }),
  email: Joi.string().email().optional().allow('').messages({
    'string.base': '邮箱必须是字符串',
    'string.email': '邮箱格式不正确'
  }),
  phone: Joi.string().pattern(/^1[3-9]\d{9}$/).optional().allow('').messages({
    'string.base': '联系电话必须是字符串',
    'string.pattern.base': '联系电话格式不正确'
  }),
  real_name: Joi.string().max(50).optional().allow('').messages({
    'string.base': '真实姓名必须是字符串',
    'string.max': '真实姓名长度不能超过50个字符'
  }),
  status: Joi.string().valid('active', 'inactive', 'locked').optional().allow('').messages({
    'string.base': '状态必须是字符串',
    'any.only': '状态只能是active、inactive或locked'
  }),
  orderBy: Joi.string().optional().allow('')
});

export const loginSchema = Joi.object({
  username: Joi.string().required().messages({
    'string.base': '用户名必须是字符串',
    'any.required': '用户名为必填项'
  }),
  password: Joi.string().required().messages({
    'string.base': '密码必须是字符串',
    'any.required': '密码为必填项'
  })
});

export const changePasswordSchema = Joi.object({
  old_password: Joi.string().min(6).max(100).required().messages({
    'string.base': '旧密码必须是字符串',
    'string.min': '旧密码长度不能少于6个字符',
    'string.max': '旧密码长度不能超过100个字符',
    'any.required': '旧密码为必填项'
  }),
  new_password: Joi.string().min(6).max(100).required().messages({
    'string.base': '新密码必须是字符串',
    'string.min': '新密码长度不能少于6个字符',
    'string.max': '新密码长度不能超过100个字符',
    'any.required': '新密码为必填项'
  })
});

export const assignRoleSchema = Joi.object({
  role_ids: Joi.array().items(Joi.number().integer().positive()).min(1).required().messages({
    'array.base': '角色ID列表必须是数组',
    'array.min': '至少需要选择一个角色',
    'any.required': '角色ID列表为必填项'
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

export interface CreateUserRequest {
  username: string;
  password: string;
  email?: string;
  phone?: string;
  real_name?: string;
  avatar?: string;
  status?: 'active' | 'inactive' | 'locked';
  is_verified?: boolean;
}

export interface UpdateUserRequest {
  password?: string;
  email?: string;
  phone?: string;
  real_name?: string;
  avatar?: string;
  status?: 'active' | 'inactive' | 'locked';
  is_verified?: boolean;
}

export interface QueryUserRequest {
  page: number;
  pageSize: number;
  username?: string;
  email?: string;
  phone?: string;
  real_name?: string;
  status?: 'active' | 'inactive' | 'locked';
  orderBy?: string;
}

export interface UserResponse {
  id: number;
  username: string;
  email: string | null;
  phone: string | null;
  real_name: string | null;
  avatar: string | null;
  status: 'active' | 'inactive' | 'locked';
  is_verified: boolean;
  last_login_at: string | null;
  last_login_ip: string | null;
  created_at: string;
  updated_at: string;
}

export interface UserWithRoleResponse extends UserResponse {
  roles: RoleResponse[];
}

export interface RoleResponse {
  id: number;
  role_code: string;
  role_name: string;
  description: string | null;
}

export interface AssignRoleRequest {
  role_ids: number[];
}

export interface ChangePasswordRequest {
  old_password: string;
  new_password: string;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: UserWithRoleResponse;
}
