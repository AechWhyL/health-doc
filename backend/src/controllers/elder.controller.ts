import { Context } from 'koa';
import { ElderService } from '../services/elder.service';
import { CreateElderRequest, UpdateElderRequest, QueryElderRequest } from '../dto/requests/elder.dto';

export class ElderController {
  /**
   * @swagger
   * /api/v1/elder-health/elder:
   *   post:
   *     summary: 创建老人基本信息
   *     description: 创建新的老人基本信息记录
   *     tags: [老人健康档案]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - name
   *               - gender
   *               - birth_date
   *               - phone
   *               - id_card
   *               - emergency_contact
   *             properties:
   *               name:
   *                 type: string
   *                 description: 老人姓名
   *                 example: 张三
   *               gender:
   *                 type: integer
   *                 description: 性别（0：女，1：男）
   *                 example: 1
   *               birth_date:
   *                 type: string
   *                 format: date
   *                 description: 出生日期
   *                 example: 1950-01-01
   *               phone:
   *                 type: string
   *                 description: 联系电话
   *                 example: 13800138000
   *               id_card:
   *                 type: string
   *                 description: 身份证号
   *                 example: 110101195001011234
   *               emergency_contact:
   *                 type: string
   *                 description: 紧急联系人
   *                 example: 李四
   *               address:
   *                 type: string
   *                 description: 家庭住址
   *                 example: 北京市朝阳区
   *               height:
   *                 type: number
   *                 description: 身高（厘米）
   *                 example: 170
   *               weight:
   *                 type: number
   *                 description: 体重（公斤）
   *                 example: 65
   *               blood_type:
   *                 type: string
   *                 description: 血型
   *                 example: A
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
   *                   example: 老人信息创建成功
   *                 data:
   *                   $ref: '#/components/schemas/ElderResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async createElder(ctx: Context) {
    const data: CreateElderRequest = ctx.request.body;
    const result = await ElderService.createElder(data);
    ctx.success(result, '老人信息创建成功');
  }

  /**
   * @swagger
   * /api/v1/elder-health/elder/{id}:
   *   get:
   *     summary: 查询老人基本信息
   *     description: 根据ID查询老人基本信息
   *     tags: [老人健康档案]
   *     parameters:
   *       - in: path
   *         name: id
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
   *                   $ref: '#/components/schemas/ElderResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 老人信息不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getElderById(ctx: Context) {
    const { id } = ctx.params;
    const elderId = parseInt(id, 10);
    if (isNaN(elderId)) {
      ctx.badRequest('无效的老人ID');
      return;
    }
    const result = await ElderService.getElderById(elderId);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/elder-health/elder/list:
   *   get:
   *     summary: 查询老人信息列表
   *     description: 分页查询老人信息列表，支持按姓名和身份证号搜索
   *     tags: [老人健康档案]
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
   *         name: name
   *         required: false
   *         schema:
   *           type: string
   *         description: 老人姓名（模糊搜索）
   *       - in: query
   *         name: id_card
   *         required: false
   *         schema:
   *           type: string
   *         description: 身份证号（模糊搜索）
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
   *                         $ref: '#/components/schemas/ElderResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async getElderList(ctx: Context) {
    const { page = 1, pageSize = 10, name, id_card } = ctx.query as any;
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

    const { items, total } = await ElderService.getElderList(pageNum, pageSizeNum, name, id_card);
    
    ctx.paginate(items, pageNum, pageSizeNum, total);
  }

  /**
   * @swagger
   * /api/v1/elder-health/elder/{id}:
   *   put:
   *     summary: 更新老人基本信息
   *     description: 根据ID更新老人基本信息
   *     tags: [老人健康档案]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 老人ID
   *         example: 1
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             properties:
   *               name:
   *                 type: string
   *                 description: 老人姓名
   *               gender:
   *                 type: integer
   *                 description: 性别（0：女，1：男）
   *               birth_date:
   *                 type: string
   *                 format: date
   *                 description: 出生日期
   *               phone:
   *                 type: string
   *                 description: 联系电话
   *               id_card:
   *                 type: string
   *                 description: 身份证号
   *               emergency_contact:
   *                 type: string
   *                 description: 紧急联系人
   *               address:
   *                 type: string
   *                 description: 家庭住址
   *               height:
   *                 type: number
   *                 description: 身高（厘米）
   *               weight:
   *                 type: number
   *                 description: 体重（公斤）
   *               blood_type:
   *                 type: string
   *                 description: 血型
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
   *                   example: 老人信息更新成功
   *                 data:
   *                   $ref: '#/components/schemas/ElderResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 老人信息不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updateElder(ctx: Context) {
    const { id } = ctx.params;
    const elderId = parseInt(id, 10);
    if (isNaN(elderId)) {
      ctx.badRequest('无效的老人ID');
      return;
    }

    const data: UpdateElderRequest = ctx.request.body;
    const result = await ElderService.updateElder(elderId, data);
    ctx.success(result, '老人信息更新成功');
  }

  /**
   * @swagger
   * /api/v1/elder-health/elder/{id}:
   *   delete:
   *     summary: 删除老人基本信息
   *     description: 根据ID删除老人基本信息
   *     tags: [老人健康档案]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 老人ID
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
   *                   example: 老人信息删除成功
   *                 data:
   *                   type: null
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 老人信息不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async deleteElder(ctx: Context) {
    const { id } = ctx.params;
    const elderId = parseInt(id, 10);
    if (isNaN(elderId)) {
      ctx.badRequest('无效的老人ID');
      return;
    }

    await ElderService.deleteElder(elderId);
    ctx.success(null, '老人信息删除成功');
  }
}
