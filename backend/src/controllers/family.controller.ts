import { Context } from 'koa';
import { FamilyService } from '../services/family.service';
import { CreateFamilyRequest, UpdateFamilyRequest, QueryFamilyRequest } from '../dto/requests/family.dto';

export class FamilyController {
    /**
     * @swagger
     * /api/v1/family/profile:
     *   post:
     *     summary: 创建家属信息
     *     description: 创建新的家属基本信息
     *     tags: [家属信息管理]
     *     security:
     *       - bearerAuth: []
     *     requestBody:
     *       required: true
     *       content:
     *         application/json:
     *           schema:
     *             type: object
     *             required:
     *               - user_id
     *               - name
     *             properties:
     *               user_id:
     *                 type: integer
     *                 description: 用户ID
     *                 example: 1
     *               name:
     *                 type: string
     *                 minLength: 1
     *                 maxLength: 50
     *                 description: 姓名
     *                 example: 张三
     *               gender:
     *                 type: integer
     *                 enum: [0, 1, 2]
     *                 description: 性别（0-未知，1-男，2-女）
     *                 example: 1
     *               phone:
     *                 type: string
     *                 pattern: '^1[3-9]\d{9}$'
     *                 description: 联系电话
     *                 example: 13800138000
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
     *                   example: 家属信息创建成功
     *                 data:
     *                   $ref: '#/components/schemas/FamilyResponse'
     *       400:
     *         description: 请求参数错误
     *       500:
     *         description: 服务器内部错误
     */
    static async createFamily(ctx: Context) {
        const data: CreateFamilyRequest = ctx.state.validatedData || ctx.request.body;
        const result = await FamilyService.createFamily(data);
        ctx.success(result, '家属信息创建成功');
    }

    /**
     * @swagger
     * /api/v1/family/profile/{id}:
     *   get:
     *     summary: 查询家属信息
     *     description: 根据ID查询家属信息
     *     tags: [家属信息管理]
     *     security:
     *       - bearerAuth: []
     *     parameters:
     *       - in: path
     *         name: id
     *         required: true
     *         schema:
     *           type: integer
     *         description: 家属信息ID
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
     *                   $ref: '#/components/schemas/FamilyResponse'
     *       404:
     *         description: 家属信息不存在
     *       500:
     *         description: 服务器内部错误
     */
    static async getFamilyById(ctx: Context) {
        const { id } = ctx.state.validatedData || ctx.params;
        const result = await FamilyService.getFamilyById(id);
        ctx.success(result);
    }

    /**
     * @swagger
     * /api/v1/family/profile/user/{user_id}:
     *   get:
     *     summary: 根据用户ID查询家属信息
     *     description: 根据用户ID查询家属信息
     *     tags: [家属信息管理]
     *     security:
     *       - bearerAuth: []
     *     parameters:
     *       - in: path
     *         name: user_id
     *         required: true
     *         schema:
     *           type: integer
     *         description: 用户ID
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
     *                   $ref: '#/components/schemas/FamilyResponse'
     *       404:
     *         description: 家属信息不存在
     *       500:
     *         description: 服务器内部错误
     */
    static async getFamilyByUserId(ctx: Context) {
        const { user_id } = ctx.state.validatedData || ctx.params;
        const result = await FamilyService.getFamilyByUserId(user_id);
        if (!result) {
            ctx.fail('家属信息不存在', 404);
            return;
        }
        ctx.success(result);
    }

    /**
     * @swagger
     * /api/v1/family/profile/list:
     *   get:
     *     summary: 查询家属信息列表
     *     description: 分页查询家属信息列表
     *     tags: [家属信息管理]
     *     security:
     *       - bearerAuth: []
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
     *           maxLength: 50
     *         description: 姓名（模糊搜索）
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
     *                     pages:
     *                       type: integer
     *                     current:
     *                       type: integer
     *                     size:
     *                       type: integer
     *                     records:
     *                       type: array
     *                       items:
     *                         $ref: '#/components/schemas/FamilyResponse'
     *       500:
     *         description: 服务器内部错误
     */
    static async getFamilyList(ctx: Context) {
        const data: QueryFamilyRequest = ctx.state.validatedData || ctx.query;
        const { page, pageSize, name } = data;

        const { items, total } = await FamilyService.getFamilyList(page, pageSize, name);

        ctx.paginate(items, page, pageSize, total);
    }

    /**
     * @swagger
     * /api/v1/family/profile/{id}:
     *   put:
     *     summary: 更新家属信息
     *     description: 根据ID更新家属信息
     *     tags: [家属信息管理]
     *     security:
     *       - bearerAuth: []
     *     parameters:
     *       - in: path
     *         name: id
     *         required: true
     *         schema:
     *           type: integer
     *         description: 家属信息ID
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
     *                 minLength: 1
     *                 maxLength: 50
     *                 description: 姓名
     *               gender:
     *                 type: integer
     *                 enum: [0, 1, 2]
     *                 description: 性别（0-未知，1-男，2-女）
     *               phone:
     *                 type: string
     *                 pattern: '^1[3-9]\d{9}$'
     *                 description: 联系电话
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
     *                   example: 家属信息更新成功
     *                 data:
     *                   $ref: '#/components/schemas/FamilyResponse'
     *       404:
     *         description: 家属信息不存在
     *       500:
     *         description: 服务器内部错误
     */
    static async updateFamily(ctx: Context) {
        const { id } = ctx.state.validatedData || ctx.params;
        const data: UpdateFamilyRequest = ctx.state.validatedData || ctx.request.body;
        const result = await FamilyService.updateFamily(id, data);
        ctx.success(result, '家属信息更新成功');
    }

    /**
     * @swagger
     * /api/v1/family/profile/{id}:
     *   delete:
     *     summary: 删除家属信息
     *     description: 根据ID删除家属信息
     *     tags: [家属信息管理]
     *     security:
     *       - bearerAuth: []
     *     parameters:
     *       - in: path
     *         name: id
     *         required: true
     *         schema:
     *           type: integer
     *         description: 家属信息ID
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
     *                   example: 家属信息删除成功
     *                 data:
     *                   type: null
     *       404:
     *         description: 家属信息不存在
     *       500:
     *         description: 服务器内部错误
     */
    static async deleteFamily(ctx: Context) {
        const { id } = ctx.state.validatedData || ctx.params;
        await FamilyService.deleteFamily(id);
        ctx.success(null, '家属信息删除成功');
    }
}

/**
 * @swagger
 * components:
 *   schemas:
 *     FamilyResponse:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *           description: 家属信息ID
 *         user_id:
 *           type: integer
 *           description: 用户ID
 *         name:
 *           type: string
 *           description: 姓名
 *         gender:
 *           type: integer
 *           description: 性别（0-未知，1-男，2-女）
 *         phone:
 *           type: string
 *           nullable: true
 *           description: 联系电话
 *         created_at:
 *           type: string
 *           format: date-time
 *           description: 创建时间
 *         updated_at:
 *           type: string
 *           format: date-time
 *           description: 更新时间
 */
