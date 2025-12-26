import { Context } from 'koa';
import { MedicationService } from '../services/medication.service';
import { CreateMedicationRequest, UpdateMedicationRequest, QueryMedicationRequest } from '../dto/requests/medication.dto';

export class MedicationController {
  /**
   * @swagger
   * /api/v1/elder-health/medication:
   *   post:
   *     summary: 创建用药记录
   *     description: 创建新的用药记录
   *     tags: [用药记录管理]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - elder_id
   *               - drug_name
   *               - dosage
   *               - frequency
   *               - start_date
   *             properties:
   *               elder_id:
   *                 type: integer
   *                 description: 老人ID
   *                 example: 1
   *               drug_name:
   *                 type: string
   *                 description: 药品名称
   *                 example: 阿司匹林
   *               dosage:
   *                 type: string
   *                 description: 用药剂量
   *                 example: 100mg
   *               frequency:
   *                 type: string
   *                 description: 用药频次
   *                 example: 每日一次
   *               start_date:
   *                 type: string
   *                 format: date
   *                 description: 开始用药日期
   *                 example: "2024-01-15"
   *               end_date:
   *                 type: string
   *                 format: date
   *                 description: 结束用药日期
   *                 example: "2024-02-15"
   *               notes:
   *                 type: string
   *                 description: 备注
   *                 example: 饭后服用
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
   *                   example: 用药记录创建成功
   *                 data:
   *                   type: object
   *                   properties:
   *                     id:
   *                       type: integer
   *                       example: 1
   *                     elder_id:
   *                       type: integer
   *                       example: 1
   *                     drug_name:
   *                       type: string
   *                       example: 阿司匹林
   *                     dosage:
   *                       type: string
   *                       example: 100mg
   *                     frequency:
   *                       type: string
   *                       example: 每日一次
   *                     start_date:
   *                       type: string
   *                       format: date
   *                       example: "2024-01-15"
   *                     end_date:
   *                       type: string
   *                       format: date
   *                       example: "2024-02-15"
   *                     notes:
   *                       type: string
   *                       example: 饭后服用
   *                     created_at:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
   *                     updated_at:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
   */
  static async createMedication(ctx: Context) {
    const data: CreateMedicationRequest = ctx.request.body;
    const result = await MedicationService.createMedication(data);
    ctx.success(result, '用药记录创建成功');
  }

  /**
   * @swagger
   * /api/v1/elder-health/medication/{id}:
   *   get:
   *     summary: 获取用药记录详情
   *     description: 根据ID获取用药记录详细信息
   *     tags: [用药记录管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 用药记录ID
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
   *                     drug_name:
   *                       type: string
   *                       example: 阿司匹林
   *                     dosage:
   *                       type: string
   *                       example: 100mg
   *                     frequency:
   *                       type: string
   *                       example: 每日一次
   *                     start_date:
   *                       type: string
   *                       format: date
   *                       example: "2024-01-15"
   *                     end_date:
   *                       type: string
   *                       format: date
   *                       example: "2024-02-15"
   *                     notes:
   *                       type: string
   *                       example: 饭后服用
   *                     created_at:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
   *                     updated_at:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
   */
  static async getMedicationById(ctx: Context) {
    const { id } = ctx.params;
    const medicationId = parseInt(id, 10);
    if (isNaN(medicationId)) {
      ctx.badRequest('无效的用药记录ID');
      return;
    }
    const result = await MedicationService.getMedicationById(medicationId);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/elder-health/medication/list:
   *   get:
   *     summary: 获取用药记录列表
   *     description: 分页查询用药记录列表，支持按老人ID、药品名称、日期范围筛选
   *     tags: [用药记录管理]
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
   *         name: drug_name
   *         schema:
   *           type: string
   *         description: 药品名称（模糊搜索）
   *       - in: query
   *         name: start_date
   *         schema:
   *           type: string
   *           format: date
   *         description: 开始日期
   *       - in: query
   *         name: end_date
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
   *                           drug_name:
   *                             type: string
   *                           dosage:
   *                             type: string
   *                           frequency:
   *                             type: string
   *                           start_date:
   *                             type: string
   *                             format: date
   *                           end_date:
   *                             type: string
   *                             format: date
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
  static async getMedicationList(ctx: Context) {
    const { page = 1, pageSize = 10, elder_id, drug_name, start_date, end_date } = ctx.query as unknown as QueryMedicationRequest;
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

    const { items, total } = await MedicationService.getMedicationList(
      pageNum,
      pageSizeNum,
      elderIdNum,
      drug_name,
      start_date,
      end_date
    );
    
    ctx.paginate(items, pageNum, pageSizeNum, total);
  }

  /**
   * @swagger
   * /api/v1/elder-health/medication/elder/{elder_id}:
   *   get:
   *     summary: 获取老人的用药记录
   *     description: 根据老人ID获取该老人的所有用药记录
   *     tags: [用药记录管理]
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
   *                       drug_name:
   *                         type: string
   *                       dosage:
   *                         type: string
   *                       frequency:
   *                         type: string
   *                       start_date:
   *                         type: string
   *                         format: date
   *                       end_date:
   *                         type: string
   *                         format: date
   *                       notes:
   *                         type: string
   *                       created_at:
   *                         type: string
   *                         format: date-time
   *                       updated_at:
   *                         type: string
   *                         format: date-time
   */
  static async getMedicationsByElderId(ctx: Context) {
    const { elder_id } = ctx.params;
    const elderId = parseInt(elder_id, 10);
    if (isNaN(elderId)) {
      ctx.badRequest('无效的老人ID');
      return;
    }

    const result = await MedicationService.getMedicationsByElderId(elderId);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/elder-health/medication/{id}:
   *   put:
   *     summary: 更新用药记录
   *     description: 根据ID更新用药记录信息
   *     tags: [用药记录管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 用药记录ID
   *         example: 1
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             properties:
   *               drug_name:
   *                 type: string
   *                 description: 药品名称
   *                 example: 阿司匹林
   *               dosage:
   *                 type: string
   *                 description: 用药剂量
   *                 example: 100mg
   *               frequency:
   *                 type: string
   *                 description: 用药频次
   *                 example: 每日一次
   *               start_date:
   *                 type: string
   *                 format: date
   *                 description: 开始用药日期
   *                 example: "2024-01-15"
   *               end_date:
   *                 type: string
   *                 format: date
   *                 description: 结束用药日期
   *                 example: "2024-02-15"
   *               notes:
   *                 type: string
   *                 description: 备注
   *                 example: 饭后服用
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
   *                   example: 用药记录更新成功
   *                 data:
   *                   type: object
   *                   properties:
   *                     id:
   *                       type: integer
   *                       example: 1
   *                     elder_id:
   *                       type: integer
   *                       example: 1
   *                     drug_name:
   *                       type: string
   *                       example: 阿司匹林
   *                     dosage:
   *                       type: string
   *                       example: 100mg
   *                     frequency:
   *                       type: string
   *                       example: 每日一次
   *                     start_date:
   *                       type: string
   *                       format: date
   *                       example: "2024-01-15"
   *                     end_date:
   *                       type: string
   *                       format: date
   *                       example: "2024-02-15"
   *                     notes:
   *                       type: string
   *                       example: 饭后服用
   *                     created_at:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
   *                     updated_at:
   *                       type: string
   *                       format: date-time
   *                       example: "2024-01-15T08:00:00Z"
   */
  static async updateMedication(ctx: Context) {
    const { id } = ctx.params;
    const medicationId = parseInt(id, 10);
    if (isNaN(medicationId)) {
      ctx.badRequest('无效的用药记录ID');
      return;
    }

    const data: UpdateMedicationRequest = ctx.request.body;
    const result = await MedicationService.updateMedication(medicationId, data);
    ctx.success(result, '用药记录更新成功');
  }

  /**
   * @swagger
   * /api/v1/elder-health/medication/{id}:
   *   delete:
   *     summary: 删除用药记录
   *     description: 根据ID删除用药记录
   *     tags: [用药记录管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 用药记录ID
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
   *                   example: 用药记录删除成功
   *                 data:
   *                   type: object
   *                   nullable: true
   */
  static async deleteMedication(ctx: Context) {
    const { id } = ctx.params;
    const medicationId = parseInt(id, 10);
    if (isNaN(medicationId)) {
      ctx.badRequest('无效的用药记录ID');
      return;
    }

    await MedicationService.deleteMedication(medicationId);
    ctx.success(null, '用药记录删除成功');
  }
}
