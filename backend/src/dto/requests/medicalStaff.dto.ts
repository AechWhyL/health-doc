import Joi from 'joi';

export const upsertMedicalStaffInfoSchema = Joi.object({
  gender: Joi.number()
    .integer()
    .valid(0, 1, 2)
    .required()
    .messages({
      'number.base': '性别必须是数字',
      'any.only': '性别只能是0、1或2'
    }),
  birth_date: Joi.string()
    .isoDate()
    .optional()
    .allow('')
    .messages({
      'string.base': '出生日期必须是字符串',
      'string.isoDate': '出生日期格式不正确'
    }),
  role_type: Joi.string()
    .max(50)
    .required()
    .messages({
      'string.base': '医护类型必须是字符串',
      'string.max': '医护类型长度不能超过50个字符',
      'any.required': '医护类型为必填项'
    }),
  job_title: Joi.string()
    .max(100)
    .optional()
    .allow('')
    .messages({
      'string.base': '职称必须是字符串',
      'string.max': '职称长度不能超过100个字符'
    }),
  good_at_tags: Joi.string()
    .max(255)
    .optional()
    .allow('')
    .messages({
      'string.base': '擅长领域必须是字符串',
      'string.max': '擅长领域长度不能超过255个字符'
    }),
  enable_online_service: Joi.boolean()
    .optional()
    .messages({
      'boolean.base': '在线服务开关必须是布尔值'
    })
});

export interface UpsertMedicalStaffInfoRequest {
  gender: number;
  birth_date?: string;
  role_type: string;
  job_title?: string;
  good_at_tags?: string;
  enable_online_service?: boolean;
}

