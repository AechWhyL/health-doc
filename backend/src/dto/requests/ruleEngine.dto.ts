import Joi from 'joi';

export const evaluateRulesQuerySchema = Joi.object({
  elder_id: Joi.number().integer().positive().required().messages({
    'number.base': '老人ID必须是数字',
    'number.integer': '老人ID必须是整数',
    'number.positive': '老人ID必须是正数',
    'any.required': '老人ID为必填项'
  }),
  windowDays: Joi.number().integer().min(1).max(365).default(30).messages({
    'number.base': '时间窗口必须是数字',
    'number.integer': '时间窗口必须是整数',
    'number.min': '时间窗口至少为1天',
    'number.max': '时间窗口不能超过365天'
  })
});

export interface EvaluateRulesQuery {
  elder_id: number;
  windowDays?: number;
}

