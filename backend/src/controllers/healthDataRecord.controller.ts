import { Context } from 'koa';
import { HealthDataRecordService } from '../services/healthDataRecord.service';
import { createHealthDataRecordSchema, updateHealthDataRecordSchema, queryHealthDataRecordSchema } from '../dto/requests/healthDataRecord.dto';

export class HealthDataRecordController {
  /**
   * @swagger
   * /api/v1/health-data/records:
   *   post:
   *     summary: 创建健康数据记录
   *     description: 创建新的健康数据记录
   *     tags: [健康数据记录管理]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - elder_id
   *               - indicator_type_id
   *               - measure_time
   *               - measure_value
   *               - input_user_id
   *               - input_user_type
   *             properties:
   *               elder_id:
   *                 type: integer
   *                 description: 老人ID
   *                 example: 1
   *               indicator_type_id:
   *                 type: integer
   *                 description: 指标类型ID
   *                 example: 1
   *               measure_time:
   *                 type: string
   *                 format: date-time
   *                 description: 测量时间
   *                 example: 2024-01-01T10:00:00Z
   *               measure_value:
   *                 type: object
   *                 description: 测量值
   *                 example: {"systolic": 120, "diastolic": 80}
   *               measure_context:
   *                 type: object
   *                 description: 测量上下文
   *               remark:
   *                 type: string
   *                 maxLength: 500
   *                 description: 备注
   *               data_source:
   *                 type: string
   *                 enum: [MANUAL, DEVICE]
   *                 description: 数据来源（MANUAL-手动录入，DEVICE-设备上传）
   *                 example: MANUAL
   *               input_user_id:
   *                 type: integer
   *                 description: 录入人ID
   *                 example: 1
   *               input_user_type:
   *                 type: string
   *                 enum: [ELDER, FAMILY, DOCTOR]
   *                 description: 录入人类型（ELDER-老人，FAMILY-家属，DOCTOR-医生）
   *                 example: FAMILY
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
   *                   example: 健康数据记录创建成功
   *                 data:
   *                   $ref: '#/components/schemas/HealthDataRecordResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async createHealthDataRecord(ctx: Context) {
    const { error, value } = createHealthDataRecordSchema.validate(ctx.request.body);
    if (error) {
      ctx.badRequest(error.details[0].message);
      return;
    }
    const result = await HealthDataRecordService.createHealthDataRecord(value);
    ctx.success(result, '健康数据记录创建成功');
  }

  /**
   * @swagger
   * /api/v1/health-data/records/{id}:
   *   get:
   *     summary: 查询健康数据记录
   *     description: 根据ID查询健康数据记录
   *     tags: [健康数据记录管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 健康数据记录ID
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
   *                   $ref: '#/components/schemas/HealthDataRecordResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 健康数据记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getHealthDataRecordById(ctx: Context) {
    const { id } = ctx.params;
    const recordId = parseInt(id, 10);
    if (isNaN(recordId)) {
      ctx.badRequest('无效的健康数据记录ID');
      return;
    }
    const result = await HealthDataRecordService.getHealthDataRecordById(recordId);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/health-data/records:
   *   get:
   *     summary: 查询健康数据记录列表
   *     description: 分页查询健康数据记录列表，支持按老人ID、指标类型ID、日期范围和数据来源筛选
   *     tags: [健康数据记录管理]
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
   *         name: indicator_type_id
   *         required: false
   *         schema:
   *           type: integer
   *         description: 指标类型ID
   *       - in: query
   *         name: start_date
   *         required: false
   *         schema:
   *           type: string
   *           format: date
   *         description: 开始日期
   *       - in: query
   *         name: end_date
   *         required: false
   *         schema:
   *           type: string
   *           format: date
   *         description: 结束日期
   *       - in: query
   *         name: data_source
   *         required: false
   *         schema:
   *           type: string
   *           enum: [MANUAL, DEVICE]
   *         description: 数据来源（MANUAL-手动录入，DEVICE-设备上传）
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
   *                     pages:
   *                       type: integer
   *                       description: 总页数
   *                     current:
   *                       type: integer
   *                       description: 当前页码
   *                     size:
   *                       type: integer
   *                       description: 每页大小
   *                     records:
   *                       type: array
   *                       items:
   *                         $ref: '#/components/schemas/HealthDataRecordResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async getHealthDataRecords(ctx: Context) {
    const { error, value } = queryHealthDataRecordSchema.validate(ctx.query);
    if (error) {
      ctx.badRequest(error.details[0].message);
      return;
    }

    const { page, pageSize, elder_id, indicator_type_id, start_date, end_date, data_source } = value;

    const { items, total } = await HealthDataRecordService.getHealthDataRecords(
      page,
      pageSize,
      elder_id,
      indicator_type_id,
      start_date,
      end_date,
      data_source
    );

    ctx.paginate(items, page, pageSize, total);
  }

  /**
   * @swagger
   * /api/v1/health-data/records/{id}:
   *   put:
   *     summary: 更新健康数据记录
   *     description: 根据ID更新健康数据记录
   *     tags: [健康数据记录管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 健康数据记录ID
   *         example: 1
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             properties:
   *               indicator_type_id:
   *                 type: integer
   *                 description: 指标类型ID
   *               measure_time:
   *                 type: string
   *                 format: date-time
   *                 description: 测量时间
   *               measure_value:
   *                 type: object
   *                 description: 测量值
   *               measure_context:
   *                 type: object
   *                 description: 测量上下文
   *               remark:
   *                 type: string
   *                 maxLength: 500
   *                 description: 备注
   *               data_source:
   *                 type: string
   *                 enum: [MANUAL, DEVICE]
   *                 description: 数据来源（MANUAL-手动录入，DEVICE-设备上传）
   *               operation_reason:
   *                 type: string
   *                 maxLength: 500
   *                 description: 操作原因
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
   *                   example: 健康数据记录更新成功
   *                 data:
   *                   $ref: '#/components/schemas/HealthDataRecordResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 健康数据记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updateHealthDataRecord(ctx: Context) {
    const { id } = ctx.params;
    const recordId = parseInt(id, 10);
    if (isNaN(recordId)) {
      ctx.badRequest('无效的健康数据记录ID');
      return;
    }

    const { error, value } = updateHealthDataRecordSchema.validate(ctx.request.body);
    if (error) {
      ctx.badRequest(error.details[0].message);
      return;
    }

    const result = await HealthDataRecordService.updateHealthDataRecord(recordId, value);
    ctx.success(result, '健康数据记录更新成功');
  }

  /**
   * @swagger
   * /api/v1/health-data/records/{id}:
   *   delete:
   *     summary: 删除健康数据记录
   *     description: 根据ID删除健康数据记录
   *     tags: [健康数据记录管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 健康数据记录ID
   *         example: 1
   *     requestBody:
   *       required: false
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             properties:
   *               reason:
   *                 type: string
   *                 description: 删除原因
   *                 example: 数据录入错误
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
   *                   example: 健康数据记录删除成功
   *                 data:
   *                   type: null
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 健康数据记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async deleteHealthDataRecord(ctx: Context) {
    const { id } = ctx.params;
    const recordId = parseInt(id, 10);
    if (isNaN(recordId)) {
      ctx.badRequest('无效的健康数据记录ID');
      return;
    }

    const body = ctx.request.body || {};
    const { reason } = body as { reason?: string };
    await HealthDataRecordService.deleteHealthDataRecord(recordId, reason);
    ctx.success(null, '健康数据记录删除成功');
  }

  /**
   * @swagger
   * /api/v1/health-data/records/{id}/history:
   *   get:
   *     summary: 查询健康数据记录历史
   *     description: 查询健康数据记录的变更历史
   *     tags: [健康数据记录管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 健康数据记录ID
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
   *                     $ref: '#/components/schemas/HealthDataRecordHistoryResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 健康数据记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getHealthDataRecordHistory(ctx: Context) {
    const { id } = ctx.params;
    const recordId = parseInt(id, 10);
    if (isNaN(recordId)) {
      ctx.badRequest('无效的健康数据记录ID');
      return;
    }

    const result = await HealthDataRecordService.getHealthDataRecordHistory(recordId);
    ctx.success(result);
  }
}
