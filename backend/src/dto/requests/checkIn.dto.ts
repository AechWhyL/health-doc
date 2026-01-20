import Joi from 'joi';

/**
 * 签到请求DTO
 */
export interface CheckInRequest {
    task_instance_id: number;
    remark?: string;
}

/**
 * 签到请求验证schema
 */
export const checkInSchema = Joi.object({
    task_instance_id: Joi.number()
        .integer()
        .positive()
        .required()
        .messages({
            'number.base': '任务实例ID必须是数字',
            'number.integer': '任务实例ID必须是整数',
            'number.positive': '任务实例ID必须大于0',
            'any.required': '任务实例ID不能为空'
        }),
    remark: Joi.string()
        .max(1000)
        .optional()
        .allow('')
        .messages({
            'string.max': '备注不能超过1000个字符'
        })
});
