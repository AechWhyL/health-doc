import { Context } from 'koa';
import { AllergyService } from '../services/allergy.service';
import { CreateAllergyRequest, UpdateAllergyRequest, QueryAllergyRequest } from '../dto/requests/allergy.dto';

export class AllergyController {
  /**
   * @swagger
   * /api/v1/elder-health/allergy:
   *   post:
   *     summary: 创建过敏史记录
   *     description: 创建新的过敏史记录
   *     tags: [过敏史管理]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - elder_id
   *               - allergy_item
   *             properties:
   *               elder_id:
   *                 type: integer
   *                 description: 老人ID
   *                 example: 1
   *               allergy_item:
   *                 type: string
   *                 description: 过敏物品名称
   *                 example: 青霉素
   *               allergy_desc:
   *                 type: string
   *                 description: 过敏相关描述
   *                 example: 服用后出现皮疹、呼吸困难等症状
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
   *                   example: 过敏史记录创建成功
   *                 data:
   *                   $ref: '#/components/schemas/AllergyResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async createAllergy(ctx: Context) {
    const data: CreateAllergyRequest = ctx.request.body;
    const result = await AllergyService.createAllergy(data);
    ctx.success(result, '过敏史记录创建成功');
  }

  /**
   * @swagger
   * /api/v1/elder-health/allergy/{id}:
   *   get:
   *     summary: 查询过敏史记录
   *     description: 根据ID查询过敏史记录
   *     tags: [过敏史管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 过敏史ID
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
   *                   $ref: '#/components/schemas/AllergyResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 过敏史记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getAllergyById(ctx: Context) {
    const { id } = ctx.params;
    const allergyId = parseInt(id, 10);
    if (isNaN(allergyId)) {
      ctx.badRequest('无效的过敏史ID');
      return;
    }
    const result = await AllergyService.getAllergyById(allergyId);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/elder-health/allergy/list:
   *   get:
   *     summary: 查询过敏史记录列表
   *     description: 分页查询过敏史记录列表，支持按老人ID和过敏物品名称搜索
   *     tags: [过敏史管理]
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
   *         name: allergy_item
   *         required: false
   *         schema:
   *           type: string
   *         description: 过敏物品名称（模糊搜索）
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
   *                         $ref: '#/components/schemas/AllergyResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async getAllergyList(ctx: Context) {
    const { page = 1, pageSize = 10, elder_id, allergy_item } = ctx.query as unknown as QueryAllergyRequest;
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

    const { items, total } = await AllergyService.getAllergyList(pageNum, pageSizeNum, elderIdNum, allergy_item);
    
    ctx.paginate(items, pageNum, pageSizeNum, total);
  }

  /**
   * @swagger
   * /api/v1/elder-health/elder/{elder_id}/allergies:
   *   get:
   *     summary: 查询老人的所有过敏史记录
   *     description: 根据老人ID查询该老人的所有过敏史记录
   *     tags: [过敏史管理]
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
   *                     $ref: '#/components/schemas/AllergyResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async getAllergiesByElderId(ctx: Context) {
    const { elder_id } = ctx.params;
    const elderId = parseInt(elder_id, 10);
    if (isNaN(elderId)) {
      ctx.badRequest('无效的老人ID');
      return;
    }

    const result = await AllergyService.getAllergiesByElderId(elderId);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/elder-health/allergy/{id}:
   *   put:
   *     summary: 更新过敏史记录
   *     description: 根据ID更新过敏史记录
   *     tags: [过敏史管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 过敏史ID
   *         example: 1
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             properties:
   *               allergy_item:
   *                 type: string
   *                 description: 过敏物品名称
   *               allergy_desc:
   *                 type: string
   *                 description: 过敏相关描述
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
   *                   example: 过敏史记录更新成功
   *                 data:
   *                   $ref: '#/components/schemas/AllergyResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 过敏史记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updateAllergy(ctx: Context) {
    const { id } = ctx.params;
    const allergyId = parseInt(id, 10);
    if (isNaN(allergyId)) {
      ctx.badRequest('无效的过敏史ID');
      return;
    }

    const data: UpdateAllergyRequest = ctx.request.body;
    const result = await AllergyService.updateAllergy(allergyId, data);
    ctx.success(result, '过敏史记录更新成功');
  }

  /**
   * @swagger
   * /api/v1/elder-health/allergy/{id}:
   *   delete:
   *     summary: 删除过敏史记录
   *     description: 根据ID删除过敏史记录
   *     tags: [过敏史管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 过敏史ID
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
   *                   example: 过敏史记录删除成功
   *                 data:
   *                   type: null
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 过敏史记录不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async deleteAllergy(ctx: Context) {
    const { id } = ctx.params;
    const allergyId = parseInt(id, 10);
    if (isNaN(allergyId)) {
      ctx.badRequest('无效的过敏史ID');
      return;
    }

    await AllergyService.deleteAllergy(allergyId);
    ctx.success(null, '过敏史记录删除成功');
  }
}
