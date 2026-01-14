import { Context } from 'koa';
import { validateBody, validateQuery } from '../middlewares/validation.middleware';
import { createPersonalRuleSchema, updatePersonalRuleSchema, queryPersonalRuleSchema, CreatePersonalRuleRequest, UpdatePersonalRuleRequest } from '../dto/requests/personalRule.dto';
import { PersonalHealthRuleService } from '../services/personalHealthRule.service';

export class PersonalRuleController {
  /**
   * @swagger
   * /api/v1/elder-health/personal-rules:
   *   post:
   *     summary: 创建个性化健康规则
   *     description: 为指定老人或所有老人创建基于json-logic-js的个性化健康规则
   *     tags: [个性化健康规则管理]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - name
   *               - level
   *               - logic
   *             properties:
   *               elder_id:
   *                 type: integer
   *                 nullable: true
   *                 description: 适用的老人ID，留空表示对所有老人生效
   *                 example: 1
   *               name:
   *                 type: string
   *                 description: 规则名称
   *                 example: 个性化-严格血压控制
   *               level:
   *                 type: string
   *                 description: 触发时的健康等级
   *                 enum: [NORMAL, MILD, MODERATE, SEVERE]
   *                 example: SEVERE
   *               logic:
   *                 type: object
   *                 description: json-logic 规则表达式
   *                 example:
   *                   ">":
   *                     - { "var": "indicators.avgSbp" }
   *                     - 140
   *               message_template:
   *                 type: string
   *                 description: 提示模板，支持{{avgSbp}}、{{windowDays}}等占位符
   *                 example: 最近{{windowDays}}天收缩压平均值约为{{avgSbp}} mmHg，已超过140
   *               is_active:
   *                 type: boolean
   *                 description: 是否立即启用
   *                 example: true
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
   *                   example: success
   *                 data:
   *                   type: object
   *                   properties:
   *                     id:
   *                       type: string
   *                       description: 规则ID（字符串形式）
   *                     name:
   *                       type: string
   *                       description: 规则名称
   *                     elderId:
   *                       type: integer
   *                       nullable: true
   *                       description: 适用老人ID
   *                     level:
   *                       type: string
   *                       enum: [NORMAL, MILD, MODERATE, SEVERE]
   *                     logic:
   *                       type: object
   *                       description: json-logic 规则内容
   *                     messageTemplate:
   *                       type: string
   *                       nullable: true
   *                       description: 提示模板
   *                     isActive:
   *                       type: boolean
   *                       description: 是否启用
   */
  static async create(ctx: Context) {
    const data: CreatePersonalRuleRequest = ctx.state.validatedData || ctx.request.body;
    const created = await PersonalHealthRuleService.create(data, ctx.state?.user?.userId);
    ctx.success(created);
  }

  /**
   * @swagger
   * /api/v1/elder-health/personal-rules/{id}:
   *   put:
   *     summary: 更新个性化健康规则
   *     description: 根据ID更新个性化规则的名称、等级、逻辑、适用老人等信息
   *     tags: [个性化健康规则管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 规则ID
   *         example: 1
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             properties:
   *               elder_id:
   *                 type: integer
   *                 nullable: true
   *                 description: 适用的老人ID，留空表示对所有老人生效
   *               name:
   *                 type: string
   *                 description: 规则名称
   *               level:
   *                 type: string
   *                 enum: [NORMAL, MILD, MODERATE, SEVERE]
   *                 description: 触发时的健康等级
   *               logic:
   *                 type: object
   *                 description: json-logic 规则表达式
   *               message_template:
   *                 type: string
   *                 nullable: true
   *                 description: 提示模板
   *               is_active:
   *                 type: boolean
   *                 description: 是否启用
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
   *                   example: success
   *                 data:
   *                   type: object
   *       400:
   *         description: 未更新任何字段
   */
  static async update(ctx: Context) {
    const id = Number(ctx.params.id);
    const data: UpdatePersonalRuleRequest = ctx.state.validatedData || ctx.request.body;
    const updated = await PersonalHealthRuleService.update(id, data);
    if (!updated) {
      ctx.fail('未更新任何字段', 400);
      return;
    }
    ctx.success(updated);
  }

  /**
   * @swagger
   * /api/v1/elder-health/personal-rules/{id}:
   *   delete:
   *     summary: 删除个性化健康规则
   *     description: 根据ID删除个性化健康规则
   *     tags: [个性化健康规则管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 规则ID
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
   *                 message:
   *                   type: string
   *                 data:
   *                   type: object
   *                   properties:
   *                     id:
   *                       type: integer
   *                       description: 被删除的规则ID
   *       404:
   *         description: 规则不存在或删除失败
   */
  static async delete(ctx: Context) {
    const id = Number(ctx.params.id);
    const ok = await PersonalHealthRuleService.delete(id);
    if (!ok) {
      ctx.fail('删除失败或记录不存在', 404);
      return;
    }
    ctx.success({ id });
  }

  /**
   * @swagger
   * /api/v1/elder-health/personal-rules:
   *   get:
   *     summary: 查询个性化健康规则列表
   *     description: 分页查询个性化规则列表，可按老人ID过滤
   *     tags: [个性化健康规则管理]
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
   *         description: 每页数量
   *       - in: query
   *         name: elder_id
   *         required: false
   *         schema:
   *           type: integer
   *         description: 过滤指定老人ID的规则
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
   *                     items:
   *                       type: array
   *                       items:
   *                         type: object
   *                         properties:
   *                           id:
   *                             type: string
   *                           name:
   *                             type: string
   *                           elderId:
   *                             type: integer
   *                             nullable: true
   *                           level:
   *                             type: string
   *                           isActive:
   *                             type: boolean
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
  static async list(ctx: Context) {
    const q = ctx.state.validatedData || ctx.query;
    const page = Number(q.page ?? 1);
    const pageSize = Number(q.pageSize ?? 10);
    const elderId = q.elder_id ? Number(q.elder_id) : undefined;
    const { items, total } = await PersonalHealthRuleService.getList(page, pageSize, elderId);
    const pages = Math.ceil(total / pageSize);
    ctx.success({
      items,
      pagination: {
        page,
        pageSize,
        total,
        pages
      }
    });
  }
}
