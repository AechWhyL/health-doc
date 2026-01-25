import { Context } from 'koa';
import { HealthRecordService } from '../services/healthRecord.service';
import { CreateHealthRecordRequest, UpdateHealthRecordRequest, QueryHealthRecordRequest, createHealthRecordSchema, updateHealthRecordSchema, queryHealthRecordSchema } from '../dto/requests/healthRecord.dto';

export class HealthRecordController {
  /**
   * @swagger
   * /api/v1/elder-health/health-record:
   *   post:
   *     summary: 创建健康记录
   *     description: 创建新的健康记录
   *     tags: [健康记录管理]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
 *             required:
 *               - elder_id
 *               - record_type
 *               - record_title
 *               - record_date
 *               - content_structured
   *             properties:
   *               elder_id:
   *                 type: integer
   *                 description: 老人ID
   *                 example: 1
 *               record_type:
 *                 type: string
 *                 description: 记录类型(MEDICAL_HISTORY:病史, CHECK_REPORT:检查报告, MEDICATION:用药记录)
 *                 enum: [MEDICAL_HISTORY, CHECK_REPORT, MEDICATION]
 *               record_title:
 *                 type: string
 *                 maxLength: 100
 *                 description: 记录标题
 *                 example: 体检报告
 *               record_date:
 *                 type: string
 *                 format: date
 *                 description: 记录日期
 *                 example: 2024-01-01
 *               content_structured:
 *                 type: object
 *                 description: 结构化记录内容(JSON)
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
   *                   example: 健康记录创建成功
   *                 data:
   *                   $ref: '#/components/schemas/HealthRecordResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async createHealthRecord(ctx: Context) {
    const { error, value } = createHealthRecordSchema.validate(ctx.request.body);
    if (error) {
      ctx.badRequest(error.details[0].message);
      return;
    }
    const data: CreateHealthRecordRequest = value;
    const result = await HealthRecordService.createHealthRecord(data);
    ctx.success(result, '健康记录创建成功');
  }

  /**
   * @swagger
   * /api/v1/elder-health/health-record/{id}:
   *   get:
   *     summary: 查询健康记录
   *     description: 根据ID查询健康记录
   *     tags: [健康记录管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 健康记录ID
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
   *                   $ref: '#/components/schemas/HealthRecordResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 健康记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getHealthRecordById(ctx: Context) {
    const { id } = ctx.params;
    const recordId = parseInt(id, 10);
    if (isNaN(recordId)) {
      ctx.badRequest('无效的健康记录ID');
      return;
    }
    const result = await HealthRecordService.getHealthRecordById(recordId);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/elder-health/health-record/list:
   *   get:
   *     summary: 查询健康记录列表
 *     description: 分页查询健康记录列表，支持按老人ID、记录类型和日期范围搜索
   *     tags: [健康记录管理]
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
 *         name: record_type
 *         required: false
 *         schema:
 *           type: string
 *           enum: [MEDICAL_HISTORY, CHECK_REPORT, MEDICATION]
 *         description: 记录类型
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
   *                         $ref: '#/components/schemas/HealthRecordResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async getHealthRecordList(ctx: Context) {
    const { error, value } = queryHealthRecordSchema.validate(ctx.query);
    if (error) {
      ctx.badRequest(error.details[0].message);
      return;
    }

    const { page, pageSize, elder_id, record_type, start_date, end_date, sort_by, sort_order } = value;
    const pageNum = parseInt(page.toString(), 10);
    const pageSizeNum = parseInt(pageSize.toString(), 10);

    if (isNaN(pageNum) || pageNum < 1) {
      ctx.badRequest('无效的页码');
      return;
    }
    if (isNaN(pageSizeNum) || pageSizeNum < 1 || pageSizeNum > 100) {
      ctx.badRequest('无效的每页大小');
      return;
    }

    const elderIdNum = elder_id ? parseInt(elder_id.toString(), 10) : undefined;

    if (elder_id && isNaN(elderIdNum!)) {
      ctx.badRequest('无效的老人ID');
      return;
    }

    const { items, total } = await HealthRecordService.getHealthRecordList(
      pageNum,
      pageSizeNum,
      elderIdNum,
      record_type,
      start_date,
      end_date,
      sort_by,
      sort_order
    );
    const pages = Math.ceil(total / pageSizeNum);

    ctx.paginate(items, pageNum, pageSizeNum, total);
  }

  /**
   * @swagger
   * /api/v1/elder-health/elder/{elder_id}/health-records:
   *   get:
   *     summary: 查询老人的所有健康记录
   *     description: 根据老人ID查询该老人的所有健康记录
   *     tags: [健康记录管理]
   *     parameters:
   *       - in: path
   *         name: elder_id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 老人ID
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
   *                     $ref: '#/components/schemas/HealthRecordResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async getHealthRecordsByElderId(ctx: Context) {
    const { elder_id } = ctx.params;
    const elderId = parseInt(elder_id, 10);
    if (isNaN(elderId)) {
      ctx.badRequest('无效的老人ID');
      return;
    }

    const result = await HealthRecordService.getHealthRecordsByElderId(elderId);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/elder-health/health-record/{id}:
   *   put:
   *     summary: 更新健康记录
   *     description: 根据ID更新健康记录
   *     tags: [健康记录管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 健康记录ID
   *         example: 1
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
 *             type: object
 *             properties:
 *               record_type:
 *                 type: string
 *                 description: 记录类型(MEDICAL_HISTORY:病史, CHECK_REPORT:检查报告, MEDICATION:用药记录)
 *                 enum: [MEDICAL_HISTORY, CHECK_REPORT, MEDICATION]
 *               record_title:
 *                 type: string
 *                 maxLength: 100
 *                 description: 记录标题
 *               record_date:
 *                 type: string
 *                 format: date
 *                 description: 记录日期
 *               content_structured:
 *                 type: object
 *                 description: 结构化记录内容(JSON)
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
   *                   example: 健康记录更新成功
   *                 data:
   *                   $ref: '#/components/schemas/HealthRecordResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 健康记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updateHealthRecord(ctx: Context) {
    const { id } = ctx.params;
    const recordId = parseInt(id, 10);
    if (isNaN(recordId)) {
      ctx.badRequest('无效的健康记录ID');
      return;
    }

    const { error, value } = updateHealthRecordSchema.validate(ctx.request.body);
    if (error) {
      ctx.badRequest(error.details[0].message);
      return;
    }

    const data: UpdateHealthRecordRequest = value;
    const result = await HealthRecordService.updateHealthRecord(recordId, data);
    ctx.success(result, '健康记录更新成功');
  }

  /**
   * @swagger
   * /api/v1/elder-health/health-record/{id}:
   *   delete:
   *     summary: 删除健康记录
   *     description: 根据ID删除健康记录
   *     tags: [健康记录管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 健康记录ID
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
   *                   example: 健康记录删除成功
   *                 data:
   *                   type: null
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 健康记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async deleteHealthRecord(ctx: Context) {
    const { id } = ctx.params;
    const recordId = parseInt(id, 10);
    if (isNaN(recordId)) {
      ctx.badRequest('无效的健康记录ID');
      return;
    }

    await HealthRecordService.deleteHealthRecord(recordId);
    ctx.success(null, '健康记录删除成功');
  }
}
