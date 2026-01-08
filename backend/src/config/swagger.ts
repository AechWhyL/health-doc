import swaggerJsdoc from 'swagger-jsdoc';

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: '老人健康档案管理系统 API',
      version: '1.0.0',
      description: '基于Koa框架的老人健康档案管理系统REST API文档',
    },
    servers: [
      {
        url: 'http://localhost:3000',
        description: '开发服务器',
      },
    ],
    components: {
      schemas: {
        ElderBasicInfo: {
          type: 'object',
          properties: {
            id: {
              type: 'integer',
              description: '老人ID',
            },
            name: {
              type: 'string',
              description: '姓名',
            },
            gender: {
              type: 'integer',
              description: '性别(0:女,1:男)',
              enum: [0, 1],
            },
            birth_date: {
              type: 'string',
              format: 'date',
              description: '出生日期',
            },
            phone: {
              type: 'string',
              description: '联系电话',
            },
            address: {
              type: 'string',
              description: '居住地址',
            },
            emergency_contact: {
              type: 'string',
              description: '紧急联系人',
            },
            height: {
              type: 'number',
              description: '身高(cm)',
            },
            weight: {
              type: 'number',
              description: '体重(kg)',
            },
            blood_type: {
              type: 'string',
              description: '血型',
            },
            created_at: {
              type: 'string',
              format: 'date-time',
              description: '创建时间',
            },
            updated_at: {
              type: 'string',
              format: 'date-time',
              description: '更新时间',
            },
          },
        },
        AllergyInfo: {
          type: 'object',
          properties: {
            id: {
              type: 'integer',
              description: '过敏记录ID',
            },
            elder_id: {
              type: 'integer',
              description: '老人ID',
            },
            allergy_item: {
              type: 'string',
              description: '过敏物品名称',
            },
            allergy_description: {
              type: 'string',
              description: '过敏相关描述',
            },
            created_at: {
              type: 'string',
              format: 'date-time',
              description: '创建时间',
            },
            updated_at: {
              type: 'string',
              format: 'date-time',
              description: '更新时间',
            },
          },
        },
        HealthRecord: {
          type: 'object',
          properties: {
            id: {
              type: 'integer',
              description: '健康记录ID',
            },
            elder_id: {
              type: 'integer',
              description: '老人ID',
            },
            record_type: {
              type: 'string',
              description:
                '记录类型(MEDICAL_HISTORY:病史, CHECK_REPORT:检查报告, MEDICATION:用药记录, ALLERGY:过敏史)',
              enum: ['MEDICAL_HISTORY', 'CHECK_REPORT', 'MEDICATION', 'ALLERGY'],
            },
            record_title: {
              type: 'string',
              description: '记录标题',
            },
            record_date: {
              type: 'string',
              format: 'date',
              description: '记录日期',
            },
            content_structured: {
              type: 'object',
              description: '结构化记录内容(JSON)',
            },
            created_at: {
              type: 'string',
              format: 'date-time',
              description: '创建时间',
            },
            updated_at: {
              type: 'string',
              format: 'date-time',
              description: '更新时间',
            },
          },
        },
        MedicationRecord: {
          type: 'object',
          properties: {
            id: {
              type: 'integer',
              description: '用药记录ID',
            },
            elder_id: {
              type: 'integer',
              description: '老人ID',
            },
            drug_name: {
              type: 'string',
              description: '药品名称',
            },
            dosage: {
              type: 'string',
              description: '剂量',
            },
            frequency: {
              type: 'string',
              description: '用药频次',
            },
            start_date: {
              type: 'string',
              format: 'date',
              description: '开始用药日期',
            },
            end_date: {
              type: 'string',
              format: 'date',
              description: '结束用药日期',
            },
            notes: {
              type: 'string',
              description: '备注',
            },
            created_at: {
              type: 'string',
              format: 'date-time',
              description: '创建时间',
            },
            updated_at: {
              type: 'string',
              format: 'date-time',
              description: '更新时间',
            },
          },
        },
        DailyHealthMeasurement: {
          type: 'object',
          properties: {
            id: {
              type: 'integer',
              description: '日常健康数据记录ID'
            },
            elder_id: {
              type: 'integer',
              description: '老人ID'
            },
            measured_at: {
              type: 'string',
              format: 'date-time',
              description: '测量时间(ISO日期时间字符串)'
            },
            sbp: {
              type: 'number',
              format: 'float',
              description: '收缩压(mmHg)',
              nullable: true
            },
            dbp: {
              type: 'number',
              format: 'float',
              description: '舒张压(mmHg)',
              nullable: true
            },
            fpg: {
              type: 'number',
              format: 'float',
              description: '空腹血糖(mmol/L)',
              nullable: true
            },
            ppg_2h: {
              type: 'number',
              format: 'float',
              description: '餐后2小时血糖(mmol/L)',
              nullable: true
            },
            weight: {
              type: 'number',
              format: 'float',
              description: '体重(kg)',
              nullable: true
            },
            steps: {
              type: 'integer',
              description: '步数',
              nullable: true
            },
            source: {
              type: 'string',
              description: '数据来源(MANUAL:手动录入, DEVICE:设备上传, REPORT:报告导入)',
              enum: ['MANUAL', 'DEVICE', 'REPORT']
            },
            remark: {
              type: 'string',
              description: '备注',
              nullable: true
            },
            created_at: {
              type: 'string',
              format: 'date-time',
              description: '创建时间'
            },
            updated_at: {
              type: 'string',
              format: 'date-time',
              description: '更新时间'
            }
          }
        },
        InterventionPlanResponse: {
          type: 'object',
          properties: {
            id: {
              type: 'integer',
              description: '干预计划ID',
            },
            elder_user_id: {
              type: 'integer',
              description: '老人用户ID',
            },
            title: {
              type: 'string',
              description: '计划标题',
            },
            description: {
              type: 'string',
              description: '计划说明',
              nullable: true,
            },
            status: {
              type: 'string',
              description: '计划状态',
              enum: ['DRAFT', 'PENDING', 'ACTIVE', 'PAUSED', 'FINISHED', 'CANCELLED'],
            },
            start_date: {
              type: 'string',
              format: 'date',
              description: '计划开始日期',
            },
            end_date: {
              type: 'string',
              format: 'date',
              description: '计划结束日期',
              nullable: true,
            },
            created_by_user_id: {
              type: 'integer',
              description: '创建计划的医护人员用户ID',
            },
            created_at: {
              type: 'string',
              format: 'date-time',
              description: '创建时间',
            },
            updated_at: {
              type: 'string',
              format: 'date-time',
              description: '更新时间',
            },
          },
        },
        MedicationPlanItemResponse: {
          type: 'object',
          properties: {
            id: {
              type: 'integer',
              description: '计划项ID',
            },
            plan_id: {
              type: 'integer',
              description: '所属干预计划ID',
            },
            item_type: {
              type: 'string',
              description: '计划项类型',
              enum: ['MEDICATION'],
            },
            name: {
              type: 'string',
              description: '计划项名称',
            },
            description: {
              type: 'string',
              description: '计划项说明',
              nullable: true,
            },
            status: {
              type: 'string',
              description: '计划项状态',
              enum: ['ACTIVE', 'PAUSED', 'STOPPED'],
            },
            start_date: {
              type: 'string',
              format: 'date',
              description: '计划项开始日期',
            },
            end_date: {
              type: 'string',
              format: 'date',
              description: '计划项结束日期',
              nullable: true,
            },
            drug_name: {
              type: 'string',
              description: '药品名称',
            },
            dosage: {
              type: 'string',
              description: '剂量描述',
            },
            frequency_type: {
              type: 'string',
              description: '用药频次描述',
            },
            instructions: {
              type: 'string',
              description: '用药指示',
              nullable: true,
            },
          },
        },
        RehabPlanItemResponse: {
          type: 'object',
          properties: {
            id: {
              type: 'integer',
              description: '计划项ID',
            },
            plan_id: {
              type: 'integer',
              description: '所属干预计划ID',
            },
            item_type: {
              type: 'string',
              description: '计划项类型',
              enum: ['REHAB'],
            },
            name: {
              type: 'string',
              description: '计划项名称',
            },
            description: {
              type: 'string',
              description: '计划项说明',
              nullable: true,
            },
            status: {
              type: 'string',
              description: '计划项状态',
              enum: ['ACTIVE', 'PAUSED', 'STOPPED'],
            },
            start_date: {
              type: 'string',
              format: 'date',
              description: '计划项开始日期',
            },
            end_date: {
              type: 'string',
              format: 'date',
              description: '计划项结束日期',
              nullable: true,
            },
            exercise_name: {
              type: 'string',
              description: '康复训练名称',
            },
            exercise_type: {
              type: 'string',
              description: '康复训练类型',
              nullable: true,
            },
            guide_resource_url: {
              type: 'string',
              description: '康复训练指导资源地址',
              nullable: true,
            },
          },
        },
        PlanItemResponse: {
          oneOf: [
            {
              $ref: '#/components/schemas/MedicationPlanItemResponse',
            },
            {
              $ref: '#/components/schemas/RehabPlanItemResponse',
            },
          ],
          description: '干预计划项详情（用药或康复）',
        },
        PlanItemScheduleResponse: {
          type: 'object',
          properties: {
            id: {
              type: 'integer',
              description: '日程ID',
            },
            item_id: {
              type: 'integer',
              description: '所属计划项ID',
            },
            schedule_type: {
              type: 'string',
              description: '日程类型',
              enum: ['ONCE', 'DAILY', 'WEEKLY'],
            },
            start_date: {
              type: 'string',
              format: 'date',
              description: '日程开始日期',
            },
            end_date: {
              type: 'string',
              format: 'date',
              description: '日程结束日期',
              nullable: true,
            },
            times_of_day: {
              type: 'array',
              description: '每日执行时间点(HH:mm)',
              items: {
                type: 'string',
              },
            },
            weekdays: {
              type: 'array',
              description: '每周执行的星期列表(1-7，1表示周一)',
              nullable: true,
              items: {
                type: 'integer',
                minimum: 1,
                maximum: 7,
              },
            },
            created_at: {
              type: 'string',
              format: 'date-time',
              description: '创建时间',
            },
            updated_at: {
              type: 'string',
              format: 'date-time',
              description: '更新时间',
            },
          },
        },
        PlanTaskInstanceResponse: {
          type: 'object',
          properties: {
            id: {
              type: 'integer',
              description: '任务实例ID',
            },
            item_id: {
              type: 'integer',
              description: '所属计划项ID',
            },
            schedule_id: {
              type: 'integer',
              description: '所属日程ID',
              nullable: true,
            },
            task_date: {
              type: 'string',
              format: 'date',
              description: '任务日期',
            },
            task_time: {
              type: 'string',
              description: '任务执行时间(HH:mm)',
              nullable: true,
            },
            status: {
              type: 'string',
              description: '任务状态',
              enum: ['PENDING', 'COMPLETED', 'SKIPPED', 'MISSED'],
            },
            complete_time: {
              type: 'string',
              format: 'date-time',
              description: '完成时间',
              nullable: true,
            },
            created_at: {
              type: 'string',
              format: 'date-time',
              description: '创建时间',
            },
            updated_at: {
              type: 'string',
              format: 'date-time',
              description: '更新时间',
            },
          },
        },
        SuccessResponse: {
          type: 'object',
          properties: {
            code: {
              type: 'integer',
              description: '状态码',
              example: 200,
            },
            message: {
              type: 'string',
              description: '响应消息',
            },
            data: {
              type: 'object',
              description: '响应数据',
            },
          },
        },
        ErrorResponse: {
          type: 'object',
          properties: {
            code: {
              type: 'integer',
              description: '错误码',
              example: 400,
            },
            message: {
              type: 'string',
              description: '错误消息',
            },
          },
        },
        PaginatedResponse: {
          type: 'object',
          properties: {
            code: {
              type: 'integer',
              description: '状态码',
              example: 200,
            },
            message: {
              type: 'string',
              description: '响应消息',
            },
            data: {
              type: 'object',
              properties: {
                items: {
                  type: 'array',
                  description: '数据列表',
                },
                pagination: {
                  type: 'object',
                  properties: {
                    page: {
                      type: 'integer',
                      description: '当前页码',
                    },
                    pageSize: {
                      type: 'integer',
                      description: '每页大小',
                    },
                    total: {
                      type: 'integer',
                      description: '总记录数',
                    },
                    pages: {
                      type: 'integer',
                      description: '总页数',
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  },
  apis: ['./src/controllers/*.ts', './src/routes/*.ts'],
};

export const swaggerSpec = swaggerJsdoc(options);
