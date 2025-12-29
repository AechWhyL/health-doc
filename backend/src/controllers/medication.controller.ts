import { Context } from 'koa';
import { MedicationService } from '../services/medication.service';
import { CreateMedicationRequest, UpdateMedicationRequest, QueryMedicationRequest, createMedicationSchema, updateMedicationSchema, queryMedicationSchema, idParamSchema, elderIdParamSchema } from '../dto/requests/medication.dto';

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
   *               - start_date
   *             properties:
   *               elder_id:
   *                 type: integer
   *                 description: 老人ID
   *                 example: 1
   *               drug_name:
   *                 type: string
   *                 minLength: 1
   *                 maxLength: 100
   *                 description: 药品名称
   *                 example: 阿司匹林
   *               dosage:
   *                 type: string
   *                 maxLength: 50
   *                 description: 用药剂量
   *                 example: 100mg
   *               frequency:
   *                 type: string
   *                 maxLength: 50
   *                 description: 用药频次
   *                 example: 每日一次
   *               start_date:
   *                 type: string
   *                 format: date
   *                 description: 开始用药日期
   *                 example: 2024-01-01
   *               end_date:
   *                 type: string
   *                 format: date
   *                 description: 结束用药日期
   *                 example: 2024-12-31
   *               notes:
   *                 type: string
   *                 maxLength: 500
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
   *                   $ref: '#/components/schemas/MedicationResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async createMedication(ctx: Context) {
    const data: CreateMedicationRequest = ctx.state.validatedData || ctx.request.body;
    const result = await MedicationService.createMedication(data);
    ctx.success(result, '用药记录创建成功');
  }

  /**
   * @swagger
   * /api/v1/elder-health/medication/{id}:
   *   get:
   *     summary: 查询用药记录
   *     description: 根据ID查询用药记录
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
   *                   example: success
   *                 data:
   *                   $ref: '#/components/schemas/MedicationResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 用药记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getMedicationById(ctx: Context) {
    const { id } = ctx.state.validatedData || ctx.params;
    const result = await MedicationService.getMedicationById(id);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/elder-health/medication/list:
   *   get:
   *     summary: 查询用药记录列表
   *     description: 分页查询用药记录列表，支持按老人ID、药品名称和日期范围搜索
   *     tags: [用药记录管理]
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
   *         name: drug_name
   *         required: false
   *         schema:
   *           type: string
   *           maxLength: 100
   *         description: 药品名称（模糊搜索）
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
   *                         $ref: '#/components/schemas/MedicationResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async getMedicationList(ctx: Context) {
    const data: QueryMedicationRequest = ctx.state.validatedData || ctx.query;
    const { page, pageSize, elder_id, drug_name, start_date, end_date } = data;

    const { items, total } = await MedicationService.getMedicationList(
      page,
      pageSize,
      elder_id,
      drug_name,
      start_date,
      end_date
    );
    
    ctx.paginate(items, page, pageSize, total);
  }

  /**
   * @swagger
   * /api/v1/elder-health/elder/{elder_id}/medications:
   *   get:
   *     summary: 查询老人的所有用药记录
   *     description: 根据老人ID查询该老人的所有用药记录
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
   *                   example: success
   *                 data:
   *                   type: array
   *                   items:
   *                     $ref: '#/components/schemas/MedicationResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async getMedicationsByElderId(ctx: Context) {
    const { elder_id } = ctx.state.validatedData || ctx.params;
    const result = await MedicationService.getMedicationsByElderId(elder_id);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/elder-health/medication/{id}:
   *   put:
   *     summary: 更新用药记录
   *     description: 根据ID更新用药记录
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
   *                 minLength: 1
   *                 maxLength: 100
   *                 description: 药品名称
   *               dosage:
   *                 type: string
   *                 maxLength: 50
   *                 description: 用药剂量
   *               frequency:
   *                 type: string
   *                 maxLength: 50
   *                 description: 用药频次
   *               start_date:
   *                 type: string
   *                 format: date
   *                 description: 开始用药日期
   *               end_date:
   *                 type: string
   *                 format: date
   *                 description: 结束用药日期
   *               notes:
   *                 type: string
   *                 maxLength: 500
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
   *                   example: 用药记录更新成功
   *                 data:
   *                   $ref: '#/components/schemas/MedicationResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 用药记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updateMedication(ctx: Context) {
    const { id } = ctx.state.validatedData || ctx.params;
    const data: UpdateMedicationRequest = ctx.state.validatedData || ctx.request.body;
    const result = await MedicationService.updateMedication(id, data);
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
   *                   type: null
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 用药记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async deleteMedication(ctx: Context) {
    const { id } = ctx.state.validatedData || ctx.params;
    await MedicationService.deleteMedication(id);
    ctx.success(null, '用药记录删除成功');
  }
}
