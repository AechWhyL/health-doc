import { Context } from 'koa';
import { DailyHealthMeasurementService } from '../services/dailyHealthMeasurement.service';
import {
  createDailyHealthMeasurementSchema,
  updateDailyHealthMeasurementSchema,
  queryDailyHealthMeasurementSchema,
  CreateDailyHealthMeasurementRequest,
  UpdateDailyHealthMeasurementRequest,
  QueryDailyHealthMeasurementRequest
} from '../dto/requests/dailyHealthMeasurement.dto';
import { validateBody, validateQuery, validateParams } from '../middlewares/validation.middleware';
import Joi from 'joi';

export class DailyHealthMeasurementController {
  static createDailyHealthMeasurementValidators = [validateBody(createDailyHealthMeasurementSchema)];

  /**
   * @swagger
   * /api/v1/elder-health/daily-health:
   *   post:
   *     summary: 创建日常健康数据
   *     description: 为老人创建一条新的日常健康测量记录
   *     tags: [日常健康管理]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - elder_id
   *               - measured_at
   *             properties:
   *               elder_id:
   *                 type: integer
   *                 description: 老人ID
   *                 example: 3
   *               measured_at:
   *                 type: string
   *                 format: date-time
   *                 description: 测量时间(ISO日期时间字符串)
   *                 example: 2026-01-08T10:00:00.000Z
   *               sbp:
   *                 type: number
   *                 format: float
   *                 description: 收缩压(mmHg)
   *                 example: 120
   *               dbp:
   *                 type: number
   *                 format: float
   *                 description: 舒张压(mmHg)
   *                 example: 80
   *               fpg:
   *                 type: number
   *                 format: float
   *                 description: 空腹血糖(mmol/L)
   *                 example: 5.6
   *               ppg_2h:
   *                 type: number
   *                 format: float
   *                 description: 餐后2小时血糖(mmol/L)
   *                 example: 7.2
   *               weight:
   *                 type: number
   *                 format: float
   *                 description: 体重(kg)
   *                 example: 68.2
   *               steps:
   *                 type: integer
   *                 description: 步数
   *                 example: 6000
   *               source:
   *                 type: string
   *                 description: 数据来源
   *                 enum: [MANUAL, DEVICE, REPORT]
   *                 example: MANUAL
   *               remark:
   *                 type: string
   *                 description: 备注
   *                 example: 早晨空腹测量
   *     responses:
   *       200:
   *         description: 创建成功
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 code:
   *                   type: integer
   *                   example: 200
   *                 message:
   *                   type: string
   *                   example: 请求成功
   *                 data:
   *                   $ref: '#/components/schemas/DailyHealthMeasurement'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async createDailyHealthMeasurement(ctx: Context) {
    const data = (ctx.state.validatedData || ctx.request.body) as CreateDailyHealthMeasurementRequest;
    const result = await DailyHealthMeasurementService.createDailyHealthMeasurement(data);
    ctx.success(result);
  }

  static getDailyHealthMeasurementListValidators = [
    validateQuery(queryDailyHealthMeasurementSchema)
  ];

  /**
   * @swagger
   * /api/v1/elder-health/daily-health/list:
   *   get:
   *     summary: 查询日常健康数据列表
   *     description: 分页查询日常健康数据记录，支持按老人ID过滤，可选附加健康状态判断结果
   *     tags: [日常健康管理]
   *     parameters:
   *       - in: query
   *         name: page
   *         required: false
   *         schema:
   *           type: integer
   *           default: 1
   *         description: 页码
   *       - in: query
   *         name: pageSize
   *         required: false
   *         schema:
   *           type: integer
   *           default: 10
   *         description: 每页大小
   *       - in: query
   *         name: elder_id
   *         required: false
   *         schema:
   *           type: integer
   *         description: 老人ID
   *       - in: query
   *         name: include_judgment
   *         required: false
   *         schema:
   *           type: boolean
   *           default: false
   *         description: 是否附加健康状态判断结果（bp_level/fpg_level/ppg_level）
   *     responses:
   *       200:
   *         description: 查询成功
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 code:
   *                   type: integer
   *                   example: 200
   *                 message:
   *                   type: string
   *                   example: success
   *                 data:
   *                   type: object
   *                   properties:
   *                     total:
   *                       type: integer
   *                       description: 总记录数
   *                     current:
   *                       type: integer
   *                       description: 当前页码
   *                     size:
   *                       type: integer
   *                       description: 每页大小
   *                     records:
   *                       type: array
   *                       items:
   *                         allOf:
   *                           - $ref: '#/components/schemas/DailyHealthMeasurement'
   *                           - type: object
   *                             properties:
   *                               judgment:
   *                                 type: object
   *                                 description: 健康状态判断结果（仅当include_judgment=true时返回）
   *                                 properties:
   *                                   bp_level:
   *                                     type: string
   *                                     enum: [NORMAL, MILD, MODERATE, SEVERE]
   *                                     description: 血压状态级别
   *                                   fpg_level:
   *                                     type: string
   *                                     enum: [NORMAL, MILD, MODERATE, SEVERE]
   *                                     description: 空腹血糖状态级别
   *                                   ppg_level:
   *                                     type: string
   *                                     enum: [NORMAL, MILD, MODERATE, SEVERE]
   *                                     description: 餐后血糖状态级别
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async getDailyHealthMeasurementList(ctx: Context) {
    const query = (ctx.state.validatedData || ctx.query) as QueryDailyHealthMeasurementRequest;
    const result = await DailyHealthMeasurementService.getDailyHealthMeasurementList(query);
    ctx.success({
      total: result.total,
      records: result.items,
      current: query.page || 1,
      size: query.pageSize || 10
    });
  }

  static idParamSchema = validateParams(
    Joi.object({
      id: Joi.number().integer().positive().required().messages({
        'number.base': 'ID必须是数字',
        'number.integer': 'ID必须是整数',
        'number.positive': 'ID必须是正数',
        'any.required': 'ID为必填项'
      })
    })
  );

  /**
   * @swagger
   * /api/v1/elder-health/daily-health/{id}:
   *   get:
   *     summary: 查询日常健康数据详情
   *     description: 根据ID查询单条日常健康测量记录
   *     tags: [日常健康管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 日常健康数据记录ID
   *         example: 2
   *     responses:
   *       200:
   *         description: 查询成功
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 code:
   *                   type: integer
   *                   example: 200
   *                 message:
   *                   type: string
   *                   example: success
   *                 data:
   *                   $ref: '#/components/schemas/DailyHealthMeasurement'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 日常健康数据记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getDailyHealthMeasurementById(ctx: Context) {
    const { id } = (ctx.state.validatedParams || ctx.state.validatedData || ctx.params) as {
      id: number;
    };
    const recordId = Number(id);
    const result = await DailyHealthMeasurementService.getDailyHealthMeasurementById(recordId);
    ctx.success(result);
  }

  static updateDailyHealthMeasurementValidators = [
    validateParams(DailyHealthMeasurementController.idParamSchema.schema),
    validateBody(updateDailyHealthMeasurementSchema)
  ];

  /**
   * @swagger
   * /api/v1/elder-health/daily-health/{id}:
   *   put:
   *     summary: 更新日常健康数据
   *     description: 根据ID更新日常健康测量记录(部分字段可选)
   *     tags: [日常健康管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 日常健康数据记录ID
   *         example: 2
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             properties:
   *               measured_at:
   *                 type: string
   *                 format: date-time
   *                 description: 测量时间(ISO日期时间字符串)
   *               sbp:
   *                 type: number
   *                 format: float
   *                 description: 收缩压(mmHg)
   *               dbp:
   *                 type: number
   *                 format: float
   *                 description: 舒张压(mmHg)
   *               fpg:
   *                 type: number
   *                 format: float
   *                 description: 空腹血糖(mmol/L)
   *               ppg_2h:
   *                 type: number
   *                 format: float
   *                 description: 餐后2小时血糖(mmol/L)
   *               weight:
   *                 type: number
   *                 format: float
   *                 description: 体重(kg)
   *               steps:
   *                 type: integer
   *                 description: 步数
   *               source:
   *                 type: string
   *                 description: 数据来源
   *                 enum: [MANUAL, DEVICE, REPORT]
   *               remark:
   *                 type: string
   *                 description: 备注
   *     responses:
   *       200:
   *         description: 更新成功
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 code:
   *                   type: integer
   *                   example: 200
   *                 message:
   *                   type: string
   *                   example: 请求成功
   *                 data:
   *                   $ref: '#/components/schemas/DailyHealthMeasurement'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 日常健康数据记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updateDailyHealthMeasurement(ctx: Context) {
    const { id } = (ctx.state.validatedParams || ctx.state.validatedData || ctx.params) as {
      id: number;
    };
    const recordId = Number(id);
    const data = ctx.state.validatedData as UpdateDailyHealthMeasurementRequest;
    const result = await DailyHealthMeasurementService.updateDailyHealthMeasurement(recordId, data);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/elder-health/daily-health/{id}:
   *   delete:
   *     summary: 删除日常健康数据
   *     description: 根据ID删除日常健康测量记录
   *     tags: [日常健康管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 日常健康数据记录ID
   *         example: 2
   *     responses:
   *       200:
   *         description: 删除成功
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 code:
   *                   type: integer
   *                   example: 200
   *                 message:
   *                   type: string
   *                   example: 请求成功
   *                 data:
   *                   type: boolean
   *                   example: true
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 日常健康数据记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async deleteDailyHealthMeasurement(ctx: Context) {
    const { id } = (ctx.state.validatedParams || ctx.state.validatedData || ctx.params) as {
      id: number;
    };
    const recordId = Number(id);
    await DailyHealthMeasurementService.deleteDailyHealthMeasurement(recordId);
    ctx.success(true);
  }
}
