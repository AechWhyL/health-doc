import Joi from 'joi';
import { NotificationStatus, UserNotificationRecord } from '../../types/notification';
import { PaginationQuery } from './common.dto';

export const queryNotificationSchema = Joi.object({
  page: Joi.number().integer().min(1).default(1).messages({
    'number.base': '页码必须是数字',
    'number.integer': '页码必须是整数',
    'number.min': '页码必须大于0'
  }),
  pageSize: Joi.number().integer().min(1).max(100).default(20).messages({
    'number.base': '每页数量必须是数字',
    'number.integer': '每页数量必须是整数',
    'number.min': '每页数量必须大于0',
    'number.max': '每页数量不能超过100'
  }),
  status: Joi.string()
    .valid('UNREAD', 'READ')
    .optional()
    .messages({
      'string.base': '状态必须是字符串',
      'any.only': '状态值不合法'
    })
});

export const notificationIdParamSchema = Joi.object({
  id: Joi.number().integer().positive().required().messages({
    'number.base': '通知ID必须是数字',
    'number.integer': '通知ID必须是整数',
    'number.positive': '通知ID必须是正数',
    'any.required': '通知ID为必填项'
  })
});

export interface QueryNotificationRequest extends PaginationQuery {
  status?: NotificationStatus;
}

export interface NotificationResponse extends UserNotificationRecord {
  id: number;
  user_id: number;
  biz_type: string;
  biz_id: number;
  title: string;
  content: string;
  status: NotificationStatus;
  created_at: string;
  read_at: string | null;
}
