import { Context } from 'koa';
import { InterventionPlanItemService } from '../services/interventionPlanItem.service';
import {
  CreatePlanItemRequest,
  UpdatePlanItemRequest,
  QueryPlanItemRequest,
  CreatePlanItemScheduleRequest,
  UpdatePlanItemScheduleRequest,
  QueryPlanTaskInstanceRequest,
  CreateTaskInstancesRequest,
  UpdateTaskInstanceStatusRequest
} from '../dto/requests/interventionPlanItem.dto';

export class InterventionPlanItemController {
  /**
   * @swagger
   * /api/v1/intervention/plans/{planId}/items:
   *   post:
   *     summary: 为干预计划新增计划项
   *     description: 为指定干预计划新增用药或康复训练计划项
   *     tags: [健康干预计划项管理]
   *     parameters:
   *       - in: path
   *         name: planId
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
   *               - itemType
   *               - name
   *               - startDate
   *             properties:
   *               itemType:
   *                 type: string
   *                 description: 计划项类型
   *                 enum: [MEDICATION, REHAB]
   *                 example: MEDICATION
   *               name:
   *                 type: string
   *                 description: 计划项名称
   *                 example: 晨起服用降压药
   *               description:
   *                 type: string
   *                 description: 计划项说明
   *                 example: 每天早上7点早餐前服用
   *               startDate:
   *                 type: string
   *                 format: date
   *                 description: 计划项开始日期
   *                 example: 2025-01-01
   *               endDate:
   *                 type: string
   *                 format: date
   *                 description: 计划项结束日期
   *                 example: 2025-03-31
   *               medicationDetail:
   *                 type: object
   *                 description: 用药计划项详情（itemType 为 MEDICATION 时必填）
   *                 properties:
   *                   drug_name:
   *                     type: string
   *                     description: 药品名称
   *                     example: 氨氯地平片
   *                   dosage:
   *                     type: string
   *                     description: 剂量
   *                     example: 5mg
   *                   frequency_type:
   *                     type: string
   *                     description: 用药频次描述
   *                     example: 每日一次
   *                   instructions:
   *                     type: string
   *                     description: 用药指示
   *                     example: 饭前半小时服用
   *               rehabDetail:
   *                 type: object
   *                 description: 康复训练计划项详情（itemType 为 REHAB 时必填）
   *                 properties:
   *                   exercise_name:
   *                     type: string
   *                     description: 训练名称
   *                     example: 快走训练
   *                   exercise_type:
   *                     type: string
   *                     description: 训练类型
   *                     example: 有氧运动
   *                   guide_resource_url:
   *                     type: string
   *                     format: uri
   *                     description: 训练指导资源地址
   *                     example: https://example.com/rehab/walk
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
   *                   example: 计划项创建成功
   *                 data:
   *                   $ref: '#/components/schemas/PlanItemResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 干预计划不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async createPlanItem(ctx: Context): Promise<void> {
    const { planId } = ctx.state.validatedData || ctx.params;
    const data: CreatePlanItemRequest = ctx.state.validatedData || ctx.request.body;
    const result = await InterventionPlanItemService.createPlanItem(Number(planId), data);
    ctx.success(result, '计划项创建成功');
  }

  /**
   * @swagger
   * /api/v1/intervention/plans/{planId}/items:
   *   get:
   *     summary: 查询干预计划下的计划项列表
   *     description: 按干预计划ID查询用药和康复计划项列表
   *     tags: [健康干预计划项管理]
   *     parameters:
   *       - in: path
   *         name: planId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 干预计划ID
   *         example: 1
   *       - in: query
   *         name: status
   *         required: false
   *         schema:
   *           type: string
   *           enum: [ACTIVE, PAUSED, STOPPED]
   *         description: 计划项状态筛选
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
   *                     $ref: '#/components/schemas/PlanItemResponse'
   *       404:
   *         description: 干预计划不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getPlanItemsByPlanId(ctx: Context): Promise<void> {
    const { planId } = ctx.state.validatedData || ctx.params;
    const query: QueryPlanItemRequest = ctx.state.validatedData || ctx.query;
    const result = await InterventionPlanItemService.getPlanItemsByPlanId(Number(planId), query);
    ctx.success(result, 'success');
  }

  /**
   * @swagger
   * /api/v1/intervention/items/{itemId}:
   *   get:
   *     summary: 获取干预计划项详情
   *     description: 根据计划项ID获取用药或康复计划项详情
   *     tags: [健康干预计划项管理]
   *     parameters:
   *       - in: path
   *         name: itemId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 计划项ID
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
   *                   $ref: '#/components/schemas/PlanItemResponse'
   *       404:
   *         description: 计划项不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getPlanItemById(ctx: Context): Promise<void> {
    const { itemId } = ctx.state.validatedData || ctx.params;
    const result = await InterventionPlanItemService.getPlanItemById(Number(itemId));
    ctx.success(result, 'success');
  }

  /**
   * @swagger
   * /api/v1/intervention/items/{itemId}:
   *   put:
   *     summary: 更新干预计划项
   *     description: 根据计划项ID更新基础信息和明细信息
   *     tags: [健康干预计划项管理]
   *     parameters:
   *       - in: path
   *         name: itemId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 计划项ID
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
   *                 description: 计划项名称
   *               description:
   *                 type: string
   *                 description: 计划项说明
   *               startDate:
   *                 type: string
   *                 format: date
   *                 description: 计划项开始日期
   *               endDate:
   *                 type: string
   *                 format: date
   *                 description: 计划项结束日期
   *               medicationDetail:
   *                 type: object
   *                 description: 用药计划项详情
   *                 properties:
   *                   drug_name:
   *                     type: string
   *                     description: 药品名称
   *                   dosage:
   *                     type: string
   *                     description: 剂量
   *                   frequency_type:
   *                     type: string
   *                     description: 用药频次描述
   *                   instructions:
   *                     type: string
   *                     description: 用药指示
   *               rehabDetail:
   *                 type: object
   *                 description: 康复训练计划项详情
   *                 properties:
   *                   exercise_name:
   *                     type: string
   *                     description: 训练名称
   *                   exercise_type:
   *                     type: string
   *                     description: 训练类型
   *                   guide_resource_url:
   *                     type: string
   *                     format: uri
   *                     description: 训练指导资源地址
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
   *                   example: 计划项更新成功
   *                 data:
   *                   $ref: '#/components/schemas/PlanItemResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 计划项不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updatePlanItem(ctx: Context): Promise<void> {
    const { itemId } = ctx.state.validatedData || ctx.params;
    const data: UpdatePlanItemRequest = ctx.state.validatedData || ctx.request.body;
    const result = await InterventionPlanItemService.updatePlanItem(Number(itemId), data);
    ctx.success(result, '计划项更新成功');
  }

  /**
   * @swagger
   * /api/v1/intervention/items/{itemId}/status:
   *   patch:
   *     summary: 更新干预计划项状态
   *     description: 根据计划项ID更新状态
   *     tags: [健康干预计划项管理]
   *     parameters:
   *       - in: path
   *         name: itemId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 计划项ID
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
   *                 enum: [ACTIVE, PAUSED, STOPPED]
   *                 description: 计划项状态
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
   *                   example: 计划项状态更新成功
   *                 data:
   *                   $ref: '#/components/schemas/PlanItemResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 计划项不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updatePlanItemStatus(ctx: Context): Promise<void> {
    const { itemId } = ctx.state.validatedData || ctx.params;
    const data = ctx.state.validatedData || ctx.request.body;
    const result = await InterventionPlanItemService.updatePlanItemStatus(Number(itemId), data.status);
    ctx.success(result, '计划项状态更新成功');
  }

  /**
   * @swagger
   * /api/v1/intervention/items/{itemId}:
   *   delete:
   *     summary: 删除干预计划项
   *     description: 根据计划项ID删除对应的计划项及其明细
   *     tags: [健康干预计划项管理]
   *     parameters:
   *       - in: path
   *         name: itemId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 计划项ID
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
   *                   example: 计划项删除成功
   *                 data:
   *                   type: null
   *       404:
   *         description: 计划项不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async deletePlanItem(ctx: Context): Promise<void> {
    const { itemId } = ctx.state.validatedData || ctx.params;
    await InterventionPlanItemService.deletePlanItem(Number(itemId));
    ctx.success(null, '计划项删除成功');
  }

  /**
   * @swagger
   * /api/v1/intervention/items/{itemId}/schedules:
   *   post:
   *     summary: 为干预计划项创建日程
   *     description: 为指定干预计划项创建执行日程规则（一次性、每天或每周）
   *     tags: [健康干预计划项管理]
   *     parameters:
   *       - in: path
   *         name: itemId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 计划项ID
   *         example: 1
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - scheduleType
   *               - startDate
   *               - timesOfDay
   *             properties:
   *               scheduleType:
   *                 type: string
   *                 description: 日程类型
   *                 enum: [ONCE, DAILY, WEEKLY]
   *                 example: DAILY
   *               startDate:
   *                 type: string
   *                 format: date
   *                 description: 日程开始日期
   *                 example: 2025-01-01
   *               endDate:
   *                 type: string
   *                 format: date
   *                 description: 日程结束日期
   *                 example: 2025-03-31
   *               timesOfDay:
   *                 type: array
   *                 description: 每日执行时间点(HH:mm)
   *                 items:
   *                   type: string
   *                   example: "08:00"
   *               weekdays:
   *                 type: array
   *                 description: 每周执行的星期列表(1-7，1表示周一)
   *                 items:
   *                   type: integer
   *                   minimum: 1
   *                   maximum: 7
   *                 example: [1,3,5]
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
   *                   example: 计划项日程创建成功
   *                 data:
   *                   $ref: '#/components/schemas/PlanItemScheduleResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 计划项不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async createPlanItemSchedule(ctx: Context): Promise<void> {
    const { itemId } = ctx.state.validatedData || ctx.params;
    const data: CreatePlanItemScheduleRequest =
      ctx.state.validatedData || ctx.request.body;
    const result = await InterventionPlanItemService.createPlanItemSchedule(
      Number(itemId),
      data
    );
    ctx.success(result, '计划项日程创建成功');
  }

  /**
   * @swagger
   * /api/v1/intervention/items/{itemId}/schedules:
   *   get:
   *     summary: 查询干预计划项的日程列表
   *     description: 根据计划项ID查询配置的全部日程规则
   *     tags: [健康干预计划项管理]
   *     parameters:
   *       - in: path
   *         name: itemId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 计划项ID
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
   *                     $ref: '#/components/schemas/PlanItemScheduleResponse'
   *       404:
   *         description: 计划项不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getPlanItemSchedules(ctx: Context): Promise<void> {
    const { itemId } = ctx.state.validatedData || ctx.params;
    const result = await InterventionPlanItemService.getPlanItemSchedules(
      Number(itemId)
    );
    ctx.success(result, 'success');
  }

  /**
   * @swagger
   * /api/v1/intervention/schedules/{scheduleId}:
   *   put:
   *     summary: 更新干预计划项日程
   *     description: 根据日程ID更新日程规则
   *     tags: [健康干预计划项管理]
   *     parameters:
   *       - in: path
   *         name: scheduleId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 日程ID
   *         example: 1
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             properties:
   *               scheduleType:
   *                 type: string
   *                 description: 日程类型
   *                 enum: [ONCE, DAILY, WEEKLY]
   *               startDate:
   *                 type: string
   *                 format: date
   *                 description: 日程开始日期
   *               endDate:
   *                 type: string
   *                 format: date
   *                 description: 日程结束日期
   *               timesOfDay:
   *                 type: array
   *                 description: 每日执行时间点(HH:mm)
   *                 items:
   *                   type: string
   *               weekdays:
   *                 type: array
   *                 description: 每周执行的星期列表(1-7)
   *                 items:
   *                   type: integer
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
   *                   example: 计划项日程更新成功
   *                 data:
   *                   $ref: '#/components/schemas/PlanItemScheduleResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 日程不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updatePlanItemSchedule(ctx: Context): Promise<void> {
    const { scheduleId } = ctx.state.validatedData || ctx.params;
    const data: UpdatePlanItemScheduleRequest =
      ctx.state.validatedData || ctx.request.body;
    const result = await InterventionPlanItemService.updatePlanItemSchedule(
      Number(scheduleId),
      data
    );
    ctx.success(result, '计划项日程更新成功');
  }

  /**
   * @swagger
   * /api/v1/intervention/schedules/{scheduleId}:
   *   delete:
   *     summary: 删除干预计划项日程
   *     description: 根据日程ID删除对应的日程规则
   *     tags: [健康干预计划项管理]
   *     parameters:
   *       - in: path
   *         name: scheduleId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 日程ID
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
   *                   example: 计划项日程删除成功
   *                 data:
   *                   type: null
   *       404:
   *         description: 日程不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async deletePlanItemSchedule(ctx: Context): Promise<void> {
    const { scheduleId } = ctx.state.validatedData || ctx.params;
    await InterventionPlanItemService.deletePlanItemSchedule(
      Number(scheduleId)
    );
    ctx.success(null, '计划项日程删除成功');
  }

  /**
   * @swagger
   * /api/v1/intervention/schedules/{scheduleId}/tasks/generate:
   *   post:
   *     summary: 按日程批量生成任务实例
   *     description: 根据日程规则和指定日期范围生成任务实例，可选择覆盖已有任务
   *     tags: [健康干预计划项管理]
   *     parameters:
   *       - in: path
   *         name: scheduleId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 日程ID
   *         example: 1
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - startDate
   *               - endDate
   *             properties:
   *               startDate:
   *                 type: string
   *                 format: date
   *                 description: 任务生成开始日期
   *                 example: 2025-01-01
   *               endDate:
   *                 type: string
   *                 format: date
   *                 description: 任务生成结束日期
   *                 example: 2025-01-31
   *               overrideExisting:
   *                 type: boolean
   *                 description: 是否覆盖日期范围内已有任务
   *                 example: true
   *     responses:
   *       200:
   *         description: 生成成功
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
   *                   example: 任务实例生成成功
   *                 data:
   *                   type: object
   *                   properties:
   *                     createdCount:
   *                       type: integer
   *                       description: 新增任务实例数量
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 日程或计划项不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async generateTaskInstancesForSchedule(ctx: Context): Promise<void> {
    const { scheduleId } = ctx.state.validatedData || ctx.params;
    const data: CreateTaskInstancesRequest =
      ctx.state.validatedData || ctx.request.body;
    const result =
      await InterventionPlanItemService.generateTaskInstancesForSchedule(
        Number(scheduleId),
        data
      );
    ctx.success(result, '任务实例生成成功');
  }

  /**
   * @swagger
   * /api/v1/intervention/items/{itemId}/tasks:
   *   get:
   *     summary: 查询干预计划项的任务实例列表
   *     description: 按计划项ID查询任务实例，可按日期范围和状态筛选
   *     tags: [健康干预计划项管理]
   *     parameters:
   *       - in: path
   *         name: itemId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 计划项ID
   *         example: 1
   *       - in: query
   *         name: startDate
   *         required: false
   *         schema:
   *           type: string
   *           format: date
   *         description: 任务日期起始
   *       - in: query
   *         name: endDate
   *         required: false
   *         schema:
   *           type: string
   *           format: date
   *         description: 任务日期结束
   *       - in: query
   *         name: status
   *         required: false
   *         schema:
   *           type: string
   *           enum: [PENDING, COMPLETED, SKIPPED, MISSED]
   *         description: 任务状态筛选
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
   *                     $ref: '#/components/schemas/PlanTaskInstanceResponse'
   *       404:
   *         description: 计划项不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getTaskInstancesByItemId(ctx: Context): Promise<void> {
    const { itemId } = ctx.state.validatedData || ctx.params;
    const query: QueryPlanTaskInstanceRequest =
      ctx.state.validatedData || ctx.query;
    const result = await InterventionPlanItemService.getTaskInstancesByItemId(
      Number(itemId),
      query
    );
    ctx.success(result, 'success');
  }

  /**
   * @swagger
   * /api/v1/intervention/tasks/{taskId}/status:
   *   patch:
   *     summary: 更新任务实例状态
   *     description: 根据任务实例ID更新任务状态，如完成、跳过或标记缺失
   *     tags: [健康干预计划项管理]
   *     parameters:
   *       - in: path
   *         name: taskId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 任务实例ID
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
   *                 enum: [PENDING, COMPLETED, SKIPPED, MISSED]
   *                 description: 任务状态
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
   *                   example: 任务实例状态更新成功
   *                 data:
   *                   $ref: '#/components/schemas/PlanTaskInstanceResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 任务实例不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updateTaskInstanceStatus(ctx: Context): Promise<void> {
    const { taskId } = ctx.state.validatedData || ctx.params;
    const data: UpdateTaskInstanceStatusRequest =
      ctx.state.validatedData || ctx.request.body;
    const result = await InterventionPlanItemService.updateTaskInstanceStatus(
      Number(taskId),
      data
    );
    ctx.success(result, '任务实例状态更新成功');
  }
}
