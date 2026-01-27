import { Context } from 'koa';
import { InterventionPlanService } from '../services/interventionPlan.service';
import {
  CreateInterventionPlanRequest,
  UpdateInterventionPlanRequest,
  QueryInterventionPlanRequest,
  InterventionPlanStatusUpdateRequest
} from '../dto/requests/interventionPlan.dto';

export class InterventionPlanController {
  /**
   * @swagger
   * /api/v1/intervention/plans:
   *   post:
   *     summary: 创建健康干预计划
   *     description: 为某个老人创建健康干预计划
   *     tags: [健康干预计划管理]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - elderUserId
   *               - title
   *               - startDate
   *               - createdByUserId
   *             properties:
   *               elderUserId:
   *                 type: integer
   *                 description: 老人对应的用户ID
   *                 example: 1001
   *               title:
   *                 type: string
   *                 description: 计划标题
   *                 example: 2025年1月血压管理干预计划
   *               description:
   *                 type: string
   *                 description: 计划整体说明
   *                 example: 针对高血压的阶段性干预方案
   *               startDate:
   *                 type: string
   *                 format: date
   *                 description: 计划开始日期
   *                 example: 2025-01-01
   *               endDate:
   *                 type: string
   *                 format: date
   *                 description: 计划结束日期
   *                 example: 2025-03-31
   *               createdByUserId:
   *                 type: integer
   *                 description: 创建计划的医护人员用户ID
   *                 example: 2001
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
   *                   example: 干预计划创建成功
   *                 data:
   *                   $ref: '#/components/schemas/InterventionPlanResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async createPlan(ctx: Context): Promise<void> {
    const body = ctx.request.body as CreateInterventionPlanRequest;
    const result = await InterventionPlanService.createPlan(body);

    ctx.body = {
      code: 200,
      message: '干预计划创建成功',
      data: result
    };
  }

  /**
   * @swagger
   * /api/v1/intervention/plans/{id}:
   *   get:
   *     summary: 获取健康干预计划详情
   *     description: 根据ID获取干预计划详情
   *     tags: [健康干预计划管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 干预计划ID
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
   *                   $ref: '#/components/schemas/InterventionPlanResponse'
   *       404:
   *         description: 干预计划不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getPlanById(ctx: Context): Promise<void> {
    const id = Number(ctx.params.id);
    const result = await InterventionPlanService.getPlanById(id);

    ctx.body = {
      code: 200,
      message: 'success',
      data: result
    };
  }

  /**
   * @swagger
   * /api/v1/intervention/elders/{elderUserId}/plans:
   *   get:
   *     summary: 查询老人干预计划列表
   *     description: 按老人用户ID分页查询干预计划列表
   *     tags: [健康干预计划管理]
   *     parameters:
   *       - in: path
   *         name: elderUserId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 老人用户ID
   *         example: 1001
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
   *         name: status
   *         required: false
   *         schema:
   *           type: string
   *           enum: [ACTIVE, STOPPED]
   *         description: 计划状态筛选(ACTIVE=进行中, STOPPED=已停止)
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
   *                         $ref: '#/components/schemas/InterventionPlanResponse'
   *       500:
   *         description: 服务器内部错误
   */
  static async getPlansByElderUserId(ctx: Context): Promise<void> {
    const elderUserId = Number(ctx.params.elderUserId);

    const query: QueryInterventionPlanRequest = {
      page: ctx.query.page ? Number(ctx.query.page) : 1,
      pageSize: ctx.query.pageSize ? Number(ctx.query.pageSize) : 10,
      status: (ctx.query.status as any) || undefined,
      orderBy: (ctx.query.orderBy as string) || undefined,
      createdByUserId: ctx.query.createdByUserId ? Number(ctx.query.createdByUserId) : undefined
    };

    const result = await InterventionPlanService.getPlansByElderUserId(elderUserId, query);

    ctx.body = {
      code: 200,
      message: 'success',
      data: result
    };
  }

  /**
   * @swagger
   * /api/v1/intervention/plans/{id}:
   *   put:
   *     summary: 更新健康干预计划
   *     description: 根据ID更新干预计划基础信息
   *     tags: [健康干预计划管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 干预计划ID
   *         example: 1
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             properties:
   *               title:
   *                 type: string
   *                 description: 计划标题
   *               description:
   *                 type: string
   *                 description: 计划说明
   *               startDate:
   *                 type: string
   *                 format: date
   *                 description: 计划开始日期
   *               endDate:
   *                 type: string
   *                 format: date
   *                 description: 计划结束日期
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
   *                   example: 干预计划更新成功
   *                 data:
   *                   $ref: '#/components/schemas/InterventionPlanResponse'
   *       404:
   *         description: 干预计划不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updatePlan(ctx: Context): Promise<void> {
    const id = Number(ctx.params.id);
    const body = ctx.request.body as UpdateInterventionPlanRequest;

    const result = await InterventionPlanService.updatePlan(id, body);

    ctx.body = {
      code: 200,
      message: '干预计划更新成功',
      data: result
    };
  }

  /**
   * @swagger
   * /api/v1/intervention/plans/{id}/status:
   *   patch:
   *     summary: 更新健康干预计划状态
   *     description: 根据ID更新干预计划状态
   *     tags: [健康干预计划管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 干预计划ID
   *         example: 1
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - status
   *             properties:
   *               status:
   *                 type: string
   *                 enum: [ACTIVE, STOPPED]
   *                 description: 计划状态(ACTIVE=进行中, STOPPED=已停止)
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
   *                   example: 干预计划状态更新成功
   *                 data:
   *                   $ref: '#/components/schemas/InterventionPlanResponse'
   *       404:
   *         description: 干预计划不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updatePlanStatus(ctx: Context): Promise<void> {
    const id = Number(ctx.params.id);
    const body = ctx.request.body as InterventionPlanStatusUpdateRequest;

    const result = await InterventionPlanService.updatePlanStatus(id, body.status);

    ctx.body = {
      code: 200,
      message: '干预计划状态更新成功',
      data: result
    };
  }

  /**
   * @swagger
   * /api/v1/intervention/plans/{id}/stop:
   *   post:
   *     summary: 中止健康干预计划
   *     description: 中止指定的干预计划,同时将其下所有计划项和待执行(PENDING)的任务实例状态改为已停止(STOPPED)
   *     tags: [健康干预计划管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 干预计划ID
   *         example: 1
   *     responses:
   *       200:
   *         description: 中止成功
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
   *                   example: 干预计划已成功中止
   *                 data:
   *                   $ref: '#/components/schemas/InterventionPlanResponse'
   *       404:
   *         description: 干预计划不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async stopPlan(ctx: Context): Promise<void> {
    const id = Number(ctx.params.id);
    const result = await InterventionPlanService.stopPlan(id);

    ctx.body = {
      code: 200,
      message: '干预计划已成功中止',
      data: result
    };
  }
}

