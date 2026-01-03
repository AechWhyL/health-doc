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
            category_id: {
              type: 'integer',
              description: '健康类别ID',
            },
            record_date: {
              type: 'string',
              format: 'date',
              description: '记录日期',
            },
            record_content: {
              type: 'string',
              description: '记录内容',
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
