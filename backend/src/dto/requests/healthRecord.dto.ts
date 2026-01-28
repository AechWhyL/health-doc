import Joi from 'joi';
import { PaginationQuery } from './common.dto';
import {
  HealthRecordType,
  HealthRecordContent,
  MedicalHistoryContent,
  CheckReportContent,
  MedicationContent,
  AllergyContent
} from '../../types/healthRecord';

const attachmentSchema = Joi.object({
  type: Joi.string().valid('IMAGE', 'FILE').required().messages({
    'string.base': '附件类型必须是字符串',
    'any.only': '附件类型只能是IMAGE或FILE',
    'any.required': '附件类型为必填项'
  }),
  url: Joi.string().uri().required().messages({
    'string.base': '附件URL必须是字符串',
    'string.uri': '附件URL必须是合法的URL',
    'any.required': '附件URL为必填项'
  }),
  name: Joi.string().max(200).optional().messages({
    'string.base': '附件名称必须是字符串',
    'string.max': '附件名称长度不能超过200个字符'
  })
});

const medicalHistoryContentSchema = Joi.object<MedicalHistoryContent>({
  disease_name: Joi.string().max(100).required().messages({
    'string.base': '疾病名称必须是字符串',
    'string.max': '疾病名称长度不能超过100个字符',
    'any.required': '疾病名称为必填项'
  }),
  diagnosed_at: Joi.date().iso().required().messages({
    'date.base': '确诊日期必须是有效的日期',
    'any.required': '确诊日期为必填项'
  }),
  status: Joi.string().valid('ONGOING', 'REMISSION', 'CURED').required().messages({
    'string.base': '状态必须是字符串',
    'any.only': '状态只能是ONGOING、REMISSION或CURED',
    'any.required': '状态为必填项'
  }),
  notes: Joi.string().max(500).optional().messages({
    'string.base': '备注必须是字符串',
    'string.max': '备注长度不能超过500个字符'
  }),
  attachments: Joi.array().items(attachmentSchema).optional()
});

const checkReportContentSchema = Joi.object<CheckReportContent>({
  check_date: Joi.date().iso().required().messages({
    'date.base': '检查日期必须是有效的日期',
    'any.required': '检查日期为必填项'
  }),
  hospital_name: Joi.string().max(200).required().messages({
    'string.base': '检查医院必须是字符串',
    'string.max': '检查医院长度不能超过200个字符',
    'any.required': '检查医院为必填项'
  }),
  check_item: Joi.string().max(200).required().messages({
    'string.base': '检查项目必须是字符串',
    'string.max': '检查项目长度不能超过200个字符',
    'any.required': '检查项目为必填项'
  }),
  result_summary: Joi.string()
    .valid('NORMAL', 'MILD_ABNORMAL', 'SIGNIFICANT_ABNORMAL')
    .required()
    .messages({
      'string.base': '结论概述必须是字符串',
      'any.only': '结论概述只能是NORMAL、MILD_ABNORMAL或SIGNIFICANT_ABNORMAL',
      'any.required': '结论概述为必填项'
    }),
  notes: Joi.string().max(500).optional().messages({
    'string.base': '备注必须是字符串',
    'string.max': '备注长度不能超过500个字符'
  }),
  attachments: Joi.array().items(attachmentSchema).optional()
});

const medicationContentSchema = Joi.object<MedicationContent>({
  drug_name: Joi.array()
    .items(
      Joi.string().max(100).messages({
        'string.base': '药品名称必须是字符串',
        'string.max': '药品名称长度不能超过100个字符'
      })
    )
    .min(1)
    .required()
    .messages({
      'array.base': '药品名称必须是字符串数组',
      'array.min': '至少需要一个药品名称',
      'any.required': '药品名称为必填项'
    }),
  dosage: Joi.string().max(50).required().messages({
    'string.base': '剂量必须是字符串',
    'string.max': '剂量长度不能超过50个字符',
    'any.required': '剂量为必填项'
  }),
  frequency: Joi.string().max(50).required().messages({
    'string.base': '频次必须是字符串',
    'string.max': '频次长度不能超过50个字符',
    'any.required': '频次为必填项'
  }),
  route: Joi.string().max(50).required().messages({
    'string.base': '给药途径必须是字符串',
    'string.max': '给药途径长度不能超过50个字符',
    'any.required': '给药途径为必填项'
  }),
  start_date: Joi.date().iso().required().messages({
    'date.base': '开始日期必须是有效的日期',
    'any.required': '开始日期为必填项'
  }),
  end_date: Joi.date().iso().optional().messages({
    'date.base': '结束日期必须是有效的日期'
  }),
  notes: Joi.string().max(500).optional().messages({
    'string.base': '备注必须是字符串',
    'string.max': '备注长度不能超过500个字符'
  }),
  prescribing_doctor: Joi.string().max(100).optional().messages({
    'string.base': '开药医生必须是字符串',
    'string.max': '开药医生长度不能超过100个字符'
  }),
  hospital_name: Joi.string().max(200).optional().messages({
    'string.base': '开药医院必须是字符串',
    'string.max': '开药医院长度不能超过200个字符'
  }),
  attachments: Joi.array().items(attachmentSchema).optional()
});

const allergyContentSchema = Joi.object<AllergyContent>({
  allergy_item: Joi.string().max(100).required().messages({
    'string.base': '过敏源必须是字符串',
    'string.max': '过敏源长度不能超过100个字符',
    'any.required': '过敏源为必填项'
  }),
  reaction_symptoms: Joi.array()
    .items(
      Joi.string().max(100).messages({
        'string.base': '过敏反应症状必须是字符串',
        'string.max': '过敏反应症状长度不能超过100个字符'
      })
    )
    .min(1)
    .required()
    .messages({
      'array.base': '过敏反应症状必须是字符串数组',
      'array.min': '至少需要一个过敏反应症状',
      'any.required': '过敏反应症状为必填项'
    }),
  first_occurrence_date: Joi.date().iso().required().messages({
    'date.base': '首次发生日期必须是有效的日期',
    'any.required': '首次发生日期为必填项'
  }),
  last_occurrence_date: Joi.date().iso().optional().messages({
    'date.base': '最近发生日期必须是有效的日期'
  }),
  notes: Joi.string().max(500).optional().messages({
    'string.base': '备注必须是字符串',
    'string.max': '备注长度不能超过500个字符'
  }),
  attachments: Joi.array().items(attachmentSchema).optional()
});

export const createHealthRecordSchema = Joi.object({
  elder_id: Joi.number().integer().positive().required().messages({
    'number.base': '老人ID必须是数字',
    'number.integer': '老人ID必须是整数',
    'number.positive': '老人ID必须是正数',
    'any.required': '老人ID为必填项'
  }),
  record_type: Joi.string()
    .valid('MEDICAL_HISTORY', 'CHECK_REPORT', 'MEDICATION', 'ALLERGY')
    .required()
    .messages({
      'string.base': '记录类型必须是字符串',
      'any.only': '记录类型只能是MEDICAL_HISTORY、CHECK_REPORT、MEDICATION或ALLERGY',
      'any.required': '记录类型为必填项'
    }),
  record_title: Joi.string().max(100).required().messages({
    'string.base': '记录标题必须是字符串',
    'string.max': '记录标题长度不能超过100个字符',
    'any.required': '记录标题为必填项'
  }),
  record_date: Joi.date().iso().required().messages({
    'date.base': '记录日期必须是有效的日期',
    'any.required': '记录日期为必填项'
  }),
  content_structured: Joi.alternatives()
    .conditional('record_type', {
      is: 'MEDICAL_HISTORY',
      then: medicalHistoryContentSchema.required(),
      otherwise: Joi.alternatives().conditional('record_type', {
        is: 'CHECK_REPORT',
        then: checkReportContentSchema.required(),
        otherwise: Joi.alternatives().conditional('record_type', {
          is: 'MEDICATION',
          then: medicationContentSchema.required(),
          otherwise: allergyContentSchema.required()
        })
      })
    })
    .messages({
      'any.required': '结构化内容为必填项'
    })
});

export const updateHealthRecordSchema = Joi.object({
  record_type: Joi.string().valid('MEDICAL_HISTORY', 'CHECK_REPORT', 'MEDICATION', 'ALLERGY').optional(),
  record_title: Joi.string().max(100).optional(),
  record_date: Joi.date().iso().optional(),
  content_structured: Joi.alternatives().conditional('record_type', {
    is: 'MEDICAL_HISTORY',
    then: medicalHistoryContentSchema.optional(),
    otherwise: Joi.alternatives()
      .conditional('record_type', {
        is: 'CHECK_REPORT',
        then: checkReportContentSchema.optional(),
        otherwise: Joi.alternatives().conditional('record_type', {
          is: 'MEDICATION',
          then: medicationContentSchema.optional(),
          otherwise: allergyContentSchema.optional()
        })
      })
  })
});

export const queryHealthRecordSchema = Joi.object({
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
  elder_id: Joi.number().integer().positive().optional(),
  record_type: Joi.string().valid('MEDICAL_HISTORY', 'CHECK_REPORT', 'MEDICATION', 'ALLERGY').optional(),
  start_date: Joi.date().iso().optional(),
  end_date: Joi.date().iso().optional(),
  sort_by: Joi.string().valid('created_at', 'record_date').optional(),
  sort_order: Joi.string().valid('asc', 'desc').optional()
});

export interface CreateHealthRecordRequest {
  elder_id: number;
  record_type: HealthRecordType;
  record_title: string;
  record_date: string;
  content_structured: HealthRecordContent;
  creator_id: number;
}

export interface UpdateHealthRecordRequest {
  record_type?: HealthRecordType;
  record_title?: string;
  record_date?: string;
  content_structured?: HealthRecordContent;
}

export interface QueryHealthRecordRequest extends PaginationQuery {
  elder_id?: number;
  record_type?: HealthRecordType;
  start_date?: string;
  end_date?: string;
  orderBy?: string;
}

export interface HealthRecordResponse {
  id: number;
  elder_id: number;
  record_type: HealthRecordType;
  record_title: string;
  record_date: string;
  content_structured: HealthRecordContent;
  creator_id: number;
  creator_name?: string;
  created_at: string;
  updated_at: string;
}
