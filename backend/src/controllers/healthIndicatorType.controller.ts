import { Context } from 'koa';
import { HealthIndicatorTypeService } from '../services/healthIndicatorType.service';
import { createHealthIndicatorTypeSchema, updateHealthIndicatorTypeSchema } from '../dto/requests/healthIndicatorType.dto';

export class HealthIndicatorTypeController {
  /**
   * @swagger
   * /api/v1/health-data/indicator-types:
   *   post:
   *     summary: 创建健康指标类型
   *     description: 创建新的健康指标类型
   *     tags: [健康指标类型管理]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - indicator_code
   *               - indicator_name
   *               - unit
   *               - min_value
   *               - max_value
   *             properties:
   *               indicator_code:
   *                 type: string
   *                 maxLength: 50
   *                 description: 指标编码
   *                 example: BLOOD_PRESSURE
   *               indicator_name:
   *                 type: string
   *                 maxLength: 100
   *                 description: 指标名称
   *                 example: 血压
   *               unit:
   *                 type: string
   *                 maxLength: 20
   *                 description: 单位
   *                 example: mmHg
   *               min_value:
   *                 type: number
   *                 description: 最小值
   *                 example: 0
   *               max_value:
   *                 type: number
   *                 description: 最大值
   *                 example: 300
   *               form_config:
   *                 type: object
   *                 description: 表单配置
   *               status:
   *                 type: number
   *                 enum: [0, 1]
   *                 description: 状态（0-禁用，1-启用）
   *                 example: 1
   *               sort_order:
   *                 type: integer
   *                 description: 排序序号
   *                 example: 0
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
   *                   example: 健康指标类型创建成功
   *                 data:
   *                   $ref: '#/components/schemas/HealthIndicatorTypeResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async createIndicatorType(ctx: Context) {
    const { error, value } = createHealthIndicatorTypeSchema.validate(ctx.request.body);
    if (error) {
      ctx.badRequest(error.details[0].message);
      return;
    }
    const result = await HealthIndicatorTypeService.createIndicatorType(value);
    ctx.success(result, '健康指标类型创建成功');
  }

  /**
   * @swagger
   * /api/v1/health-data/indicator-types/{id}:
   *   get:
   *     summary: 查询健康指标类型
   *     description: 根据ID查询健康指标类型
   *     tags: [健康指标类型管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 健康指标类型ID
   *         example: 1
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
   *                   $ref: '#/components/schemas/HealthIndicatorTypeResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 健康指标类型不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getIndicatorTypeById(ctx: Context) {
    const { id } = ctx.params;
    const typeId = parseInt(id, 10);
    if (isNaN(typeId)) {
      ctx.badRequest('无效的健康指标类型ID');
      return;
    }
    const result = await HealthIndicatorTypeService.getIndicatorTypeById(typeId);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/health-data/indicator-types:
   *   get:
   *     summary: 查询健康指标类型列表
   *     description: 查询健康指标类型列表，支持按状态筛选
   *     tags: [健康指标类型管理]
   *     parameters:
   *       - in: query
   *         name: status
   *         required: false
   *         schema:
   *           type: integer
   *           enum: [0, 1]
   *         description: 状态（0-禁用，1-启用）
   *         example: 1
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
   *                   type: array
   *                   items:
   *                     $ref: '#/components/schemas/HealthIndicatorTypeResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async getIndicatorTypes(ctx: Context) {
    const { status } = ctx.query as unknown as { status?: string };
    const statusNum = status !== undefined ? parseInt(status, 10) : undefined;
    
    if (status !== undefined && isNaN(statusNum!)) {
      ctx.badRequest('无效的状态值');
      return;
    }

    const result = await HealthIndicatorTypeService.getIndicatorTypes(statusNum);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/health-data/indicator-types/{id}:
   *   put:
   *     summary: 更新健康指标类型
   *     description: 根据ID更新健康指标类型
   *     tags: [健康指标类型管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 健康指标类型ID
   *         example: 1
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             properties:
   *               indicator_code:
   *                 type: string
   *                 maxLength: 50
   *                 description: 指标编码
   *               indicator_name:
   *                 type: string
   *                 maxLength: 100
   *                 description: 指标名称
   *               unit:
   *                 type: string
   *                 maxLength: 20
   *                 description: 单位
   *               min_value:
   *                 type: number
   *                 description: 最小值
   *               max_value:
   *                 type: number
   *                 description: 最大值
   *               form_config:
   *                 type: object
   *                 description: 表单配置
   *               status:
   *                 type: number
   *                 enum: [0, 1]
   *                 description: 状态（0-禁用，1-启用）
   *               sort_order:
   *                 type: integer
   *                 description: 排序序号
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
   *                   example: 健康指标类型更新成功
   *                 data:
   *                   $ref: '#/components/schemas/HealthIndicatorTypeResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 健康指标类型不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updateIndicatorType(ctx: Context) {
    const { id } = ctx.params;
    const typeId = parseInt(id, 10);
    if (isNaN(typeId)) {
      ctx.badRequest('无效的健康指标类型ID');
      return;
    }

    const { error, value } = updateHealthIndicatorTypeSchema.validate(ctx.request.body);
    if (error) {
      ctx.badRequest(error.details[0].message);
      return;
    }

    const result = await HealthIndicatorTypeService.updateIndicatorType(typeId, value);
    ctx.success(result, '健康指标类型更新成功');
  }

  /**
   * @swagger
   * /api/v1/health-data/indicator-types/{id}:
   *   delete:
   *     summary: 删除健康指标类型
   *     description: 根据ID删除健康指标类型
   *     tags: [健康指标类型管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 健康指标类型ID
   *         example: 1
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
   *                   example: 健康指标类型删除成功
   *                 data:
   *                   type: null
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 健康指标类型不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async deleteIndicatorType(ctx: Context) {
    const { id } = ctx.params;
    const typeId = parseInt(id, 10);
    if (isNaN(typeId)) {
      ctx.badRequest('无效的健康指标类型ID');
      return;
    }

    await HealthIndicatorTypeService.deleteIndicatorType(typeId);
    ctx.success(null, '健康指标类型删除成功');
  }
}
