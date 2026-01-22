import Joi from 'joi';
import {
  PlanItemType,
  PlanItemStatus,
  PlanScheduleType,
  PlanTaskStatus,
  PlanItemResponse,
  MedicationPlanItemResponse,
  RehabPlanItemResponse,
  PlanItemScheduleResponse,
  PlanTaskInstanceResponse
} from '../../types/interventionPlanItem';

export const createPlanItemSchema = Joi.object({
  itemType: Joi.string()
    .valid('MEDICATION', 'REHAB')
    .required()
    .messages({
      'string.base': '计划项类型必须是字符串',
      'any.only': '计划项类型不合法',
      'any.required': '计划项类型为必填项'
    }),
  name: Joi.string().min(1).max(100).required().messages({
    'string.base': '计划项名称必须是字符串',
    'string.min': '计划项名称长度不能少于1个字符',
    'string.max': '计划项名称长度不能超过100个字符',
    'any.required': '计划项名称为必填项'
  }),
  description: Joi.string().max(1000).allow(null, '').optional().messages({
    'string.base': '计划项说明必须是字符串',
    'string.max': '计划项说明长度不能超过1000个字符'
  }),
  startDate: Joi.date().iso().required().messages({
    'date.base': '开始日期必须是有效的日期',
    'any.required': '开始日期为必填项'
  }),
  endDate: Joi.date().iso().greater(Joi.ref('startDate')).allow(null).optional().messages({
    'date.base': '结束日期必须是有效的日期',
    'date.greater': '结束日期必须晚于开始日期'
  }),
  medicationDetail: Joi.object({
    drug_name: Joi.string().max(100).required().messages({
      'string.base': '药品名称必须是字符串',
      'string.max': '药品名称长度不能超过100个字符',
      'any.required': '药品名称为必填项'
    }),
    dosage: Joi.string().max(50).required().messages({
      'string.base': '剂量必须是字符串',
      'string.max': '剂量长度不能超过50个字符',
      'any.required': '剂量为必填项'
    }),
    frequency_type: Joi.string().max(50).required().messages({
      'string.base': '用药频次描述必须是字符串',
      'string.max': '用药频次描述长度不能超过50个字符',
      'any.required': '用药频次描述为必填项'
    }),
    instructions: Joi.string().max(1000).allow(null, '').optional().messages({
      'string.base': '用药指示必须是字符串',
      'string.max': '用药指示长度不能超过1000个字符'
    })
  })
    .optional()
    .when('itemType', {
      is: 'MEDICATION',
      then: Joi.required().messages({
        'any.required': '用药计划项必须提供medicationDetail'
      })
    }),
  rehabDetail: Joi.object({
    exercise_name: Joi.string().max(100).required().messages({
      'string.base': '训练名称必须是字符串',
      'string.max': '训练名称长度不能超过100个字符',
      'any.required': '训练名称为必填项'
    }),
    exercise_type: Joi.string().max(50).allow(null, '').optional().messages({
      'string.base': '训练类型必须是字符串',
      'string.max': '训练类型长度不能超过50个字符'
    }),
    guide_resource_url: Joi.string().uri().allow(null, '').optional().messages({
      'string.base': '训练资源地址必须是字符串',
      'string.uri': '训练资源地址必须是有效的URL'
    })
  })
    .optional()
    .when('itemType', {
      is: 'REHAB',
      then: Joi.required().messages({
        'any.required': '康复计划项必须提供rehabDetail'
      })
    })
});

export const updatePlanItemSchema = Joi.object({
  name: Joi.string().min(1).max(100).optional().messages({
    'string.base': '计划项名称必须是字符串',
    'string.min': '计划项名称长度不能少于1个字符',
    'string.max': '计划项名称长度不能超过100个字符'
  }),
  description: Joi.string().max(1000).allow(null, '').optional().messages({
    'string.base': '计划项说明必须是字符串',
    'string.max': '计划项说明长度不能超过1000个字符'
  }),
  startDate: Joi.date().iso().optional().messages({
    'date.base': '开始日期必须是有效的日期'
  }),
  endDate: Joi.date().iso().optional().messages({
    'date.base': '结束日期必须是有效的日期'
  }),
  medicationDetail: Joi.object({
    drug_name: Joi.string().max(100).optional().messages({
      'string.base': '药品名称必须是字符串',
      'string.max': '药品名称长度不能超过100个字符'
    }),
    dosage: Joi.string().max(50).optional().messages({
      'string.base': '剂量必须是字符串',
      'string.max': '剂量长度不能超过50个字符'
    }),
    frequency_type: Joi.string().max(50).optional().messages({
      'string.base': '用药频次描述必须是字符串',
      'string.max': '用药频次描述长度不能超过50个字符'
    }),
    instructions: Joi.string().max(1000).allow(null, '').optional().messages({
      'string.base': '用药指示必须是字符串',
      'string.max': '用药指示长度不能超过1000个字符'
    })
  }).optional(),
  rehabDetail: Joi.object({
    exercise_name: Joi.string().max(100).optional().messages({
      'string.base': '训练名称必须是字符串',
      'string.max': '训练名称长度不能超过100个字符'
    }),
    exercise_type: Joi.string().max(50).allow(null, '').optional().messages({
      'string.base': '训练类型必须是字符串',
      'string.max': '训练类型长度不能超过50个字符'
    }),
    guide_resource_url: Joi.string().uri().allow(null, '').optional().messages({
      'string.base': '训练资源地址必须是字符串',
      'string.uri': '训练资源地址必须是有效的URL'
    })
  }).optional()
}).or('name', 'description', 'startDate', 'endDate', 'medicationDetail', 'rehabDetail');

export const planIdParamSchema = Joi.object({
  planId: Joi.number().integer().positive().required().messages({
    'number.base': '计划ID必须是数字',
    'number.integer': '计划ID必须是整数',
    'number.positive': '计划ID必须是正数',
    'any.required': '计划ID为必填项'
  })
});

export const planItemIdParamSchema = Joi.object({
  itemId: Joi.number().integer().positive().required().messages({
    'number.base': '计划项ID必须是数字',
    'number.integer': '计划项ID必须是整数',
    'number.positive': '计划项ID必须是正数',
    'any.required': '计划项ID为必填项'
  })
});

export const queryPlanItemSchema = Joi.object({
  status: Joi.string()
    .valid('ACTIVE', 'STOPPED')
    .optional()
    .messages({
      'string.base': '计划项状态必须是字符串',
      'any.only': '计划项状态不合法(有效值: ACTIVE=进行中, STOPPED=已停止)'
    })
});

export const updatePlanItemStatusSchema = Joi.object({
  status: Joi.string()
    .valid('ACTIVE', 'STOPPED')
    .required()
    .messages({
      'string.base': '计划项状态必须是字符串',
      'any.only': '计划项状态不合法(有效值: ACTIVE=进行中, STOPPED=已停止)',
      'any.required': '计划项状态为必填项'
    })
});

export const createPlanItemScheduleSchema = Joi.object({
  scheduleType: Joi.string()
    .valid('ONCE', 'DAILY', 'WEEKLY')
    .required()
    .messages({
      'string.base': '日程类型必须是字符串',
      'any.only': '日程类型不合法',
      'any.required': '日程类型为必填项'
    }),
  startDate: Joi.date().iso().required().messages({
    'date.base': '开始日期必须是有效的日期',
    'any.required': '开始日期为必填项'
  }),
  endDate: Joi.date().iso().greater(Joi.ref('startDate')).required().messages({
    'date.base': '结束日期必须是有效的日期',
    'date.greater': '结束日期必须晚于开始日期',
    'any.required': '结束日期为必填项'
  }),
  timesOfDay: Joi.array()
    .items(
      Joi.string()
        .pattern(/^\d{2}:\d{2}$/)
        .messages({
          'string.base': '时间必须是字符串',
          'string.pattern.base': '时间格式必须为HH:mm'
        })
    )
    .min(1)
    .required()
    .messages({
      'array.base': '每日时间列表必须是数组',
      'array.min': '每日时间列表至少包含一个时间点',
      'any.required': '每日时间列表为必填项'
    }),
  weekdays: Joi.array()
    .items(
      Joi.number().integer().min(1).max(7).messages({
        'number.base': '星期必须是数字',
        'number.integer': '星期必须是整数',
        'number.min': '星期最小为1',
        'number.max': '星期最大为7'
      })
    )
    .when('scheduleType', {
      is: 'WEEKLY',
      then: Joi.array().min(1).required().messages({
        'array.base': '星期列表必须是数组',
        'array.min': '星期列表至少包含一个元素',
        'any.required': '每周日程必须指定星期列表'
      }),
      otherwise: Joi.array().optional()
    })
});

export const updatePlanItemScheduleSchema = Joi.object({
  scheduleType: Joi.string()
    .valid('ONCE', 'DAILY', 'WEEKLY')
    .optional()
    .messages({
      'string.base': '日程类型必须是字符串',
      'any.only': '日程类型不合法'
    }),
  startDate: Joi.date().iso().optional().messages({
    'date.base': '开始日期必须是有效的日期'
  }),
  endDate: Joi.date().iso().optional().messages({
    'date.base': '结束日期必须是有效的日期'
  }),
  timesOfDay: Joi.array()
    .items(
      Joi.string()
        .pattern(/^\d{2}:\d{2}$/)
        .messages({
          'string.base': '时间必须是字符串',
          'string.pattern.base': '时间格式必须为HH:mm'
        })
    )
    .min(1)
    .optional()
    .messages({
      'array.base': '每日时间列表必须是数组',
      'array.min': '每日时间列表至少包含一个时间点'
    }),
  weekdays: Joi.array()
    .items(
      Joi.number().integer().min(1).max(7).messages({
        'number.base': '星期必须是数字',
        'number.integer': '星期必须是整数',
        'number.min': '星期最小为1',
        'number.max': '星期最大为7'
      })
    )
    .optional()
}).or('scheduleType', 'startDate', 'endDate', 'timesOfDay', 'weekdays');

export const scheduleIdParamSchema = Joi.object({
  scheduleId: Joi.number().integer().positive().required().messages({
    'number.base': '日程ID必须是数字',
    'number.integer': '日程ID必须是整数',
    'number.positive': '日程ID必须是正数',
    'any.required': '日程ID为必填项'
  })
});

export const createTaskInstancesSchema = Joi.object({
  startDate: Joi.date().iso().required().messages({
    'date.base': '开始日期必须是有效的日期',
    'any.required': '开始日期为必填项'
  }),
  endDate: Joi.date().iso().greater(Joi.ref('startDate')).required().messages({
    'date.base': '结束日期必须是有效的日期',
    'date.greater': '结束日期必须晚于开始日期',
    'any.required': '结束日期为必填项'
  }),
  overrideExisting: Joi.boolean().optional().messages({
    'boolean.base': '覆盖已有任务标志必须是布尔值'
  })
});

export const queryPlanTaskInstanceSchema = Joi.object({
  startDate: Joi.date().iso().optional().messages({
    'date.base': '开始日期必须是有效的日期'
  }),
  endDate: Joi.date().iso().optional().messages({
    'date.base': '结束日期必须是有效的日期'
  }),
  status: Joi.string()
    .valid('PENDING', 'COMPLETED', 'SKIPPED', 'MISSED')
    .optional()
    .messages({
      'string.base': '任务状态必须是字符串',
      'any.only': '任务状态不合法'
    })
});

export const taskIdParamSchema = Joi.object({
  taskId: Joi.number().integer().positive().required().messages({
    'number.base': '任务ID必须是数字',
    'number.integer': '任务ID必须是整数',
    'number.positive': '任务ID必须是正数',
    'any.required': '任务ID为必填项'
  })
});

export const updateTaskInstanceStatusSchema = Joi.object({
  status: Joi.string()
    .valid('PENDING', 'COMPLETED', 'SKIPPED', 'MISSED')
    .required()
    .messages({
      'string.base': '任务状态必须是字符串',
      'any.only': '任务状态不合法',
      'any.required': '任务状态为必填项'
    })
});

export interface CreatePlanItemRequest {
  itemType: PlanItemType;
  name: string;
  description?: string | null;
  startDate: string;
  endDate?: string | null;
  medicationDetail?: {
    drug_name: string;
    dosage: string;
    frequency_type: string;
    instructions?: string | null;
  };
  rehabDetail?: {
    exercise_name: string;
    exercise_type?: string | null;
    guide_resource_url?: string | null;
  };
}

export interface UpdatePlanItemRequest {
  name?: string;
  description?: string | null;
  startDate?: string;
  endDate?: string | null;
  medicationDetail?: {
    drug_name?: string;
    dosage?: string;
    frequency_type?: string;
    instructions?: string | null;
  };
  rehabDetail?: {
    exercise_name?: string;
    exercise_type?: string | null;
    guide_resource_url?: string | null;
  };
}

export interface QueryPlanItemRequest {
  status?: PlanItemStatus;
}

export interface CreatePlanItemScheduleRequest {
  scheduleType: PlanScheduleType;
  startDate: string;
  endDate?: string | null;
  timesOfDay: string[];
  weekdays?: number[];
}

export interface UpdatePlanItemScheduleRequest {
  scheduleType?: PlanScheduleType;
  startDate?: string;
  endDate?: string | null;
  timesOfDay?: string[];
  weekdays?: number[];
}

export interface QueryPlanTaskInstanceRequest {
  startDate?: string;
  endDate?: string;
  status?: PlanTaskStatus;
}

export interface CreateTaskInstancesRequest {
  startDate: string;
  endDate: string;
  overrideExisting?: boolean;
}

export interface UpdateTaskInstanceStatusRequest {
  status: PlanTaskStatus;
  remark?: string;
  proof_image_url?: string;
}

export interface ElderTaskStats {
  elder_id: number;
  total_tasks: number;
  completed_tasks: number;
}

export interface TodayTaskStatsResponse {
  total_elders: number;
  total_tasks: number;
  completed_tasks: number;
  elder_stats: ElderTaskStats[];
}

export {
  PlanItemResponse,
  MedicationPlanItemResponse,
  RehabPlanItemResponse,
  PlanItemScheduleResponse,
  PlanTaskInstanceResponse,
  PlanItemType,
  PlanItemStatus,
  PlanScheduleType,
  PlanTaskStatus
};
