import { Context } from 'koa';
import { HealthRecordService } from '../services/healthRecord.service';
import { CreateHealthRecordRequest, UpdateHealthRecordRequest, QueryHealthRecordRequest } from '../dto/requests/healthRecord.dto';

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
   *               - category_id
   *               - record_date
   *               - record_content
   *             properties:
   *               elder_id:
   *                 type: integer
   *                 description: 老人ID
   *                 example: 1
   *               category_id:
   *                 type: integer
   *                 description: 健康记录分类ID（1：血压，2：血糖，3：心率，4：体重，5：其他）
   *                 example: 1
   *               record_date:
   *                 type: string
   *                 format: date-time
   *                 description: 记录日期时间
   *                 example: "2024-01-15T08:00:00Z"
   *               record_content:
   *                 type: string
   *                 description: 记录内容
   *                 example: 血压：120/80 mmHg
   *               record_value:
   *                 type: string
   *                 description: 记录数值
   *                 example: "120/80"
   *               unit:
   *                 type: string
   *                 description: 单位
   *                 example: mmHg
   *               notes:
   *                 type: string
   *                 description: 备注
   *                 example: 血压正常
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
   *                   type: object
   *                   properties:
   *                     id:
   *                       type: integer
   *                       example: 1
   *                     elder_id:
   *                       type: integer
   *                       example: 1
   *                     category_id:
   *                       type: integer
   *                       example: 1
   *                     record_date:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
   *                     record_content:
   *                       type: string
   *                       example: 血压：120/80 mmHg
   *                     record_value:
   *                       type: string
   *                       example: "120/80"
   *                     unit:
   *                       type: string
   *                       example: mmHg
   *                     notes:
   *                       type: string
   *                       example: 血压正常
   *                     created_at:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
   *                     updated_at:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
   */
  static async createHealthRecord(ctx: Context) {
    const data: CreateHealthRecordRequest = ctx.request.body;
    const result = await HealthRecordService.createHealthRecord(data);
    ctx.success(result, '健康记录创建成功');
  }

  /**
   * @swagger
   * /api/v1/elder-health/health-record/{id}:
   *   get:
   *     summary: 获取健康记录详情
   *     description: 根据ID获取健康记录详细信息
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
   *                   example: 操作成功
   *                 data:
   *                   type: object
   *                   properties:
   *                     id:
   *                       type: integer
   *                       example: 1
   *                     elder_id:
   *                       type: integer
   *                       example: 1
   *                     category_id:
   *                       type: integer
   *                       example: 1
   *                     record_date:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
   *                     record_content:
   *                       type: string
   *                       example: 血压：120/80 mmHg
   *                     record_value:
   *                       type: string
   *                       example: "120/80"
   *                     unit:
   *                       type: string
   *                       example: mmHg
   *                     notes:
   *                       type: string
   *                       example: 血压正常
   *                     created_at:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
   *                     updated_at:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
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
   *     summary: 获取健康记录列表
   *     description: 分页查询健康记录列表，支持按老人ID、分类ID、日期范围筛选
   *     tags: [健康记录管理]
   *     parameters:
   *       - in: query
   *         name: page
   *         schema:
   *           type: integer
   *           default: 1
   *         description: 页码
   *       - in: query
   *         name: pageSize
   *         schema:
   *           type: integer
   *           default: 10
   *         description: 每页数量
   *       - in: query
   *         name: elder_id
   *         schema:
   *           type: integer
   *         description: 老人ID
   *       - in: query
   *         name: category_id
   *         schema:
   *           type: integer
   *         description: 健康记录分类ID（1：血压，2：血糖，3：心率，4：体重，5：其他）
   *       - in: query
   *         name: start_date
   *         schema:
   *           type: string
   *           format: date-time
   *         description: 开始日期
   *       - in: query
   *         name: end_date
   *         schema:
   *           type: string
   *           format: date-time
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
   *                   example: 操作成功
   *                 data:
   *                   type: object
   *                   properties:
   *                     items:
   *                       type: array
   *                       items:
   *                         type: object
   *                         properties:
   *                           id:
   *                             type: integer
   *                           elder_id:
   *                             type: integer
   *                           category_id:
   *                             type: integer
   *                           record_date:
   *                             type: string
   *                             format: date-time
   *                           record_content:
   *                             type: string
   *                           record_value:
   *                             type: string
   *                           unit:
   *                             type: string
   *                           notes:
   *                             type: string
   *                           created_at:
   *                             type: string
   *                             format: date-time
   *                           updated_at:
   *                             type: string
   *                             format: date-time
   *                     pagination:
   *                       type: object
   *                       properties:
   *                         page:
   *                           type: integer
   *                         pageSize:
   *                           type: integer
   *                         total:
   *                           type: integer
   *                         pages:
   *                           type: integer
   */
  static async getHealthRecordList(ctx: Context) {
    const { page = 1, pageSize = 10, elder_id, category_id, start_date, end_date } = ctx.query as unknown as QueryHealthRecordRequest;
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
    const categoryIdNum = category_id ? parseInt(category_id.toString(), 10) : undefined;
    
    if (elder_id && isNaN(elderIdNum!)) {
      ctx.badRequest('无效的老人ID');
      return;
    }
    if (category_id && isNaN(categoryIdNum!)) {
      ctx.badRequest('无效的分类ID');
      return;
    }

    const { items, total } = await HealthRecordService.getHealthRecordList(
      pageNum,
      pageSizeNum,
      elderIdNum,
      categoryIdNum,
      start_date,
      end_date
    );
    const pages = Math.ceil(total / pageSizeNum);
    
    ctx.paginate(items, pageNum, pageSizeNum, total);
  }

  /**
   * @swagger
   * /api/v1/elder-health/health-record/elder/{elder_id}:
   *   get:
   *     summary: 获取老人的健康记录
   *     description: 根据老人ID获取该老人的所有健康记录
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
   *                   example: 操作成功
   *                 data:
   *                   type: array
   *                   items:
   *                     type: object
   *                     properties:
   *                       id:
   *                         type: integer
   *                       elder_id:
   *                         type: integer
   *                       category_id:
   *                         type: integer
   *                       record_date:
   *                         type: string
   *                         format: date-time
   *                       record_content:
   *                         type: string
   *                       record_value:
   *                         type: string
   *                       unit:
   *                         type: string
   *                       notes:
   *                         type: string
   *                       created_at:
   *                         type: string
   *                         format: date-time
   *                       updated_at:
   *                         type: string
   *                         format: date-time
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
   *     description: 根据ID更新健康记录信息
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
   *               category_id:
   *                 type: integer
   *                 description: 健康记录分类ID（1：血压，2：血糖，3：心率，4：体重，5：其他）
   *                 example: 1
   *               record_date:
   *                 type: string
   *                 format: date-time
   *                 description: 记录日期时间
   *                 example: "2024-01-15T08:00:00Z"
   *               record_content:
   *                 type: string
   *                 description: 记录内容
   *                 example: 血压：120/80 mmHg
   *               record_value:
   *                 type: string
   *                 description: 记录数值
   *                 example: "120/80"
   *               unit:
   *                 type: string
   *                 description: 单位
   *                 example: mmHg
   *               notes:
   *                 type: string
   *                 description: 备注
   *                 example: 血压正常
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
   *                   type: object
   *                   properties:
   *                     id:
   *                       type: integer
   *                       example: 1
   *                     elder_id:
   *                       type: integer
   *                       example: 1
   *                     category_id:
   *                       type: integer
   *                       example: 1
   *                     record_date:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
   *                     record_content:
   *                       type: string
   *                       example: 血压：120/80 mmHg
   *                     record_value:
   *                       type: string
   *                       example: "120/80"
   *                     unit:
   *                       type: string
   *                       example: mmHg
   *                     notes:
   *                       type: string
   *                       example: 血压正常
   *                     created_at:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
   *                     updated_at:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
   */
  static async updateHealthRecord(ctx: Context) {
    const { id } = ctx.params;
    const recordId = parseInt(id, 10);
    if (isNaN(recordId)) {
      ctx.badRequest('无效的健康记录ID');
      return;
    }

    const data: UpdateHealthRecordRequest = ctx.request.body;
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
   *                   type: object
   *                   nullable: true
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
