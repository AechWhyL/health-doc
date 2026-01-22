import Router from '@koa/router';
import { ConsultationController } from '../controllers/consultation.controller';
import {
  createConsultationQuestionSchema,
  queryConsultationQuestionSchema,
  idParamSchema,
  createConsultationMessageSchema,
  queryConsultationMessageSchema
} from '../dto/requests/consultation.dto';
import { validateBody, validateParams, validateQuery } from '../middlewares/validation.middleware';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = new Router({
  prefix: '/api/v1/consultation'
});

/**
 * @swagger
 * /api/v1/consultation/questions:
 *   post:
 *     summary: 创建咨询问题
 *     description: 创建一个新的咨询问题
 *     tags: [咨询管理]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
*             required:
 *               - title
 *               - creator_type
 *               - target_staff_id
 *             properties:
 *               title:
 *                 type: string
 *                 description: 标题
 *               description:
 *                 type: string
 *                 description: 描述
 *               creator_type:
 *                 type: string
 *                 enum: [ELDER, FAMILY, STAFF]
 *                 description: 创建人类型
 *               creator_id:
 *                 type: integer
 *                 description: 创建人ID（可选，由后端从认证信息自动填充）
 *               target_staff_id:
 *                 type: integer
 *                 description: 目标医护人员ID
 *               category:
 *                 type: string
 *                 description: 分类
 *               priority:
 *                 type: string
 *                 enum: [NORMAL, URGENT]
 *                 default: NORMAL
 *                 description: 优先级
 *               is_anonymous:
 *                 type: boolean
 *                 description: 是否匿名
 *     responses:
 *       200:
 *         description: 创建成功
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/SuccessResponse'
 *                 - type: object
 *                   properties:
 *                     data:
 *                       $ref: '#/components/schemas/ConsultationQuestionResponse'
 */
router.post(
  '/questions',
  authMiddleware,
  validateBody(createConsultationQuestionSchema),
  ConsultationController.createQuestion
);

/**
 * @swagger
 * /api/v1/consultation/questions:
 *   get:
 *     summary: 获取咨询问题列表
 *     description: 分页获取咨询问题列表
 *     tags: [咨询管理]
 *     security:
 *       - bearerAuth: []
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
 *         name: status
 *         schema:
 *           type: string
 *           enum: [PENDING, IN_PROGRESS, RESOLVED, CLOSED]
 *         description: 状态
 *       - in: query
 *         name: creator_id
 *         schema:
 *           type: integer
 *         description: 创建人ID
 *       - in: query
 *         name: target_staff_id
  *         schema:
  *           type: integer
  *         description: 目标医护人员ID
 *       - in: query
 *         name: user_id
 *         schema:
 *           type: integer
 *         description: 用户ID（匹配创建人或目标医护，用于查看"我的咨询"）
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *         description: 分类
 *       - in: query
 *         name: orderBy
 *         schema:
 *           type: string
 *         description: 排序字段
 *     responses:
 *       200:
 *         description: 获取成功
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/PaginatedResponse'
 *                 - type: object
 *                   properties:
 *                     data:
 *                       type: object
 *                       properties:
 *                         items:
 *                           type: array
 *                           items:
 *                             $ref: '#/components/schemas/ConsultationQuestionResponse'
 */
router.get(
  '/questions',
  authMiddleware,
  validateQuery(queryConsultationQuestionSchema),
  ConsultationController.getQuestionList
);

/**
 * @swagger
 * /api/v1/consultation/questions/{id}:
 *   get:
 *     summary: 获取咨询问题详情
 *     description: 根据ID获取咨询问题详情
 *     tags: [咨询管理]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: 问题ID
 *     responses:
 *       200:
 *         description: 获取成功
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/SuccessResponse'
 *                 - type: object
 *                   properties:
 *                     data:
 *                       $ref: '#/components/schemas/ConsultationQuestionResponse'
 */
router.get(
  '/questions/:id',
  authMiddleware,
  validateParams(idParamSchema),
  ConsultationController.getQuestionById
);

/**
 * @swagger
 * /api/v1/consultation/questions/{id}/messages:
 *   post:
 *     summary: 发送咨询消息
 *     description: 向指定咨询问题发送消息
 *     tags: [咨询管理]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: 问题ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - sender_type
 *               - content_type
 *             properties:
 *               sender_type:
 *                 type: string
 *                 enum: [ELDER, FAMILY, STAFF, SYSTEM]
 *                 description: 发送方类型
 *               sender_id:
 *                 type: integer
 *                 description: 发送方ID
 *               role_display_name:
 *                 type: string
 *                 description: 角色展示名称
 *               content_type:
 *                 type: string
 *                 enum: [TEXT, IMAGE, AUDIO, SYSTEM]
 *                 description: 内容类型
 *               content_text:
 *                 type: string
 *                 description: 文本内容
 *               attachments:
 *                 type: array
 *                 items:
 *                   type: object
 *                   required:
 *                     - url
 *                   properties:
 *                     url:
 *                       type: string
 *                       description: 附件URL
 *                     thumbnail_url:
 *                       type: string
 *                       description: 缩略图URL
 *                     duration:
 *                       type: integer
 *                       description: 时长
 *                     size:
 *                       type: integer
 *                       description: 大小
 *     responses:
 *       200:
 *         description: 发送成功
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/SuccessResponse'
 *                 - type: object
 *                   properties:
 *                     data:
 *                       $ref: '#/components/schemas/ConsultationMessageResponse'
 */
router.post(
  '/questions/:id/messages',
  authMiddleware,
  validateParams(idParamSchema),
  validateBody(createConsultationMessageSchema),
  ConsultationController.createMessage
);

/**
 * @swagger
 * /api/v1/consultation/questions/{id}/messages:
 *   get:
 *     summary: 获取咨询消息列表
 *     description: 分页获取咨询问题的消息列表
 *     tags: [咨询管理]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: 问题ID
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
 *           default: 20
 *         description: 每页数量
 *     responses:
 *       200:
 *         description: 获取成功
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/PaginatedResponse'
 *                 - type: object
 *                   properties:
 *                     data:
 *                       type: object
 *                       properties:
 *                         items:
 *                           type: array
 *                           items:
 *                             $ref: '#/components/schemas/ConsultationMessageResponse'
 */
router.get(
  '/questions/:id/messages',
  authMiddleware,
  validateParams(idParamSchema),
  validateQuery(queryConsultationMessageSchema),
  ConsultationController.getMessageList
);

export default router;

