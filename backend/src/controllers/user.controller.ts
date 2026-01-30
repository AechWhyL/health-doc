import { Context } from 'koa';
import { UserService } from '../services/user.service';
import {
  CreateUserRequest,
  UpdateUserRequest,
  ChangePasswordRequest,
  QueryUserEldersRequest,
  createUserSchema,
  updateUserSchema,
  queryUserSchema,
  loginSchema,
  changePasswordSchema,
  idParamSchema,
  queryUserEldersSchema,
  createUserElderRelationSchema,
  userElderRelationIdParamSchema
} from '../dto/requests/user.dto';
import { UpsertMedicalStaffInfoRequest } from '../dto/requests/medicalStaff.dto';
import { MedicalStaffService } from '../services/medicalStaff.service';
import { UserElderRelationService } from '../services/userElderRelation.service';
import { RoleCode } from '../config/rbac.config';

export class UserController {
  /**
   * @swagger
   * /api/v1/users:
   *   post:
   *     summary: 创建用户
   *     description: 创建新用户
   *     tags: [用户管理]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - username
   *               - password
   *             properties:
   *               username:
   *                 type: string
   *                 minLength: 3
   *                 maxLength: 30
   *                 pattern: '^[a-zA-Z0-9]+$'
   *                 description: 用户名
   *                 example: testuser
   *               password:
   *                 type: string
   *                 minLength: 6
   *                 maxLength: 100
   *                 description: 密码
   *                 example: password123
   *               email:
   *                 type: string
   *                 format: email
   *                 description: 邮箱
   *                 example: test@example.com
   *               phone:
   *                 type: string
   *                 pattern: '^1[3-9]\d{9}$'
   *                 description: 联系电话
   *                 example: 13800138000
   *               real_name:
   *                 type: string
   *                 maxLength: 50
   *                 description: 真实姓名
   *                 example: 张三
   *               avatar:
   *                 type: string
   *                 format: uri
   *                 description: 头像URL
   *                 example: https://example.com/avatar.jpg
   *               status:
   *                 type: string
   *                 enum: [active, inactive, locked]
   *                 description: 状态（active-正常，inactive-未激活，locked-锁定）
   *                 example: active
   *               is_verified:
   *                 type: boolean
   *                 description: 是否验证
   *                 example: true
   *               role_code:
   *                 type: string
   *                 enum: [admin, medical_staff, family, elder]
   *                 description: 用户角色编码
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
   *                   example: 用户创建成功
   *                 data:
   *                   $ref: '#/components/schemas/UserWithRoleResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async createUser(ctx: Context) {
    const data: CreateUserRequest = ctx.state.validatedData || ctx.request.body;
    const result = await UserService.createUser(data);
    ctx.success(result, '用户创建成功');
  }

  /**
   * @swagger
   * /api/v1/users/{id}:
   *   get:
   *     summary: 查询用户
   *     description: 根据ID查询用户信息
   *     tags: [用户管理]
   *     parameters:
   *       - in: path
   *         name: id
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
   *                   $ref: '#/components/schemas/UserWithRoleResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 用户不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getUserById(ctx: Context) {
    const { id } = ctx.state.validatedParams || ctx.params;
    const result = await UserService.getUserById(id);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/users:
   *   get:
   *     summary: 查询用户列表
   *     description: 分页查询用户列表，支持按用户名、邮箱、电话、真实姓名和状态搜索
   *     tags: [用户管理]
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
   *         name: username
   *         required: false
   *         schema:
   *           type: string
   *           maxLength: 30
   *         description: 用户名
   *       - in: query
   *         name: email
   *         required: false
   *         schema:
   *           type: string
   *           format: email
   *         description: 邮箱
   *       - in: query
   *         name: phone
   *         required: false
   *         schema:
   *           type: string
   *           pattern: '^1[3-9]\d{9}$'
   *         description: 联系电话
   *       - in: query
   *         name: real_name
   *         required: false
   *         schema:
   *           type: string
   *           maxLength: 50
   *         description: 真实姓名
   *       - in: query
   *         name: status
   *         required: false
   *         schema:
   *           type: string
   *           enum: [active, inactive, locked]
   *         description: 状态（active-正常，inactive-未激活，locked-锁定）
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
   *                         $ref: '#/components/schemas/UserResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async getUserList(ctx: Context) {
    const data = ctx.state.validatedData || ctx.query;
    const { page, pageSize, username, email, phone, real_name, status } = data;

    const { items, total } = await UserService.getUserList(
      page,
      pageSize,
      username,
      email,
      phone,
      real_name,
      status
    );

    ctx.paginate(items, page, pageSize, total);
  }

  /**
   * @swagger
   * /api/v1/users/{id}:
   *   put:
   *     summary: 更新用户
   *     description: 根据ID更新用户信息
   *     tags: [用户管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 用户ID
   *         example: 1
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             properties:
   *               password:
   *                 type: string
   *                 minLength: 6
   *                 maxLength: 100
   *                 description: 密码
   *               email:
   *                 type: string
   *                 format: email
   *                 description: 邮箱
   *               phone:
   *                 type: string
   *                 pattern: '^1[3-9]\d{9}$'
   *                 description: 联系电话
   *               real_name:
   *                 type: string
   *                 maxLength: 50
   *                 description: 真实姓名
   *               avatar:
   *                 type: string
   *                 format: uri
   *                 description: 头像URL
   *               status:
   *                 type: string
   *                 enum: [active, inactive, locked]
   *                 description: 状态（active-正常，inactive-未激活，locked-锁定）
   *               is_verified:
   *                 type: boolean
   *                 description: 是否验证
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
   *                   example: 用户更新成功
   *                 data:
   *                   $ref: '#/components/schemas/UserResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 用户不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updateUser(ctx: Context) {
    const { id } = ctx.state.validatedParams || ctx.params;
    const data: UpdateUserRequest = ctx.state.validatedData || ctx.request.body;
    const result = await UserService.updateUser(id, data);
    ctx.success(result, '用户更新成功');
  }

  /**
   * @swagger
   * /api/v1/users/{id}:
   *   delete:
   *     summary: 删除用户
   *     description: 根据ID删除用户
   *     tags: [用户管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 用户ID
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
   *                   example: 用户删除成功
   *                 data:
   *                   type: null
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 用户不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async deleteUser(ctx: Context) {
    const { id } = ctx.state.validatedParams || ctx.params;
    const result = await UserService.deleteUser(id);
    ctx.success(null, '用户删除成功');
  }

  /**
   * @swagger
   * /api/v1/users/login:
   *   post:
   *     summary: 用户登录
   *     description: 用户登录获取访问令牌
   *     tags: [用户管理]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - username
   *               - password
   *             properties:
   *               username:
   *                 type: string
   *                 description: 用户名
   *                 example: testuser
   *               password:
   *                 type: string
   *                 description: 密码
   *                 example: password123
   *     responses:
   *       200:
   *         description: 登录成功
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
   *                   example: 登录成功
   *                 data:
   *                   type: object
   *                   properties:
   *                     token:
   *                       type: string
   *                       description: 访问令牌
   *                     user:
   *                       $ref: '#/components/schemas/UserWithRoleResponse'
   *       400:
   *         description: 请求参数错误
   *       401:
   *         description: 用户名或密码错误
   *       500:
   *         description: 服务器内部错误
   */
  static async login(ctx: Context) {
    const data = ctx.state.validatedData || ctx.request.body;
    const { username, password } = data;
    const ip = ctx.ip || ctx.request.ip || '127.0.0.1';

    const result = await UserService.login({ username, password }, ip);
    ctx.success(result, '登录成功');
  }

  /**
   * @swagger
   * /api/v1/users/change-password:
   *   post:
   *     summary: 修改密码
   *     description: 修改当前登录用户的密码
   *     tags: [用户管理]
   *     security:
   *       - bearerAuth: []
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - old_password
   *               - new_password
   *             properties:
   *               old_password:
   *                 type: string
   *                 minLength: 6
   *                 maxLength: 100
   *                 description: 旧密码
   *                 example: oldpassword123
   *               new_password:
   *                 type: string
   *                 minLength: 6
   *                 maxLength: 100
   *                 description: 新密码
   *                 example: newpassword123
   *     responses:
   *       200:
   *         description: 修改成功
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
   *                   example: 密码修改成功
   *                 data:
   *                   type: null
   *       400:
   *         description: 请求参数错误或旧密码不正确
   *       401:
   *         description: 未授权
   *       500:
   *         description: 服务器内部错误
  */
  static async changePassword(ctx: Context) {
    const { userId } = ctx.state.user!;
    const data: ChangePasswordRequest = ctx.state.validatedData || ctx.request.body;
    await UserService.changePassword(userId, data);
    ctx.success(null, '密码修改成功');
  }

  /**
   * @swagger
   * /api/v1/users/me:
   *   get:
   *     summary: 获取当前用户信息
   *     description: 获取当前登录用户的详细信息
   *     tags: [用户管理]
   *     security:
   *       - bearerAuth: []
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
   *                   $ref: '#/components/schemas/UserResponse'
   *       401:
   *         description: 未授权
   *       500:
   *         description: 服务器内部错误
  */
  static async getCurrentUser(ctx: Context) {
    const { userId } = ctx.state.user!;
    const result = await UserService.getUserById(userId);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/users/me/medical-staff:
   *   post:
   *     summary: 编辑当前医护人员详情
   *     description: 编辑当前登录医护人员的详细信息
   *     tags: [用户管理]
   *     security:
   *       - bearerAuth: []
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - gender
   *               - role_type
   *             properties:
   *               real_name:
   *                 type: string
   *                 maxLength: 50
   *                 description: 真实姓名
   *               gender:
   *                 type: integer
   *                 enum: [0, 1, 2]
   *                 description: 性别（0-男，1-女，2-其他）
   *               birth_date:
   *                 type: string
   *                 format: date
   *                 description: 出生日期
   *               role_type:
   *                 type: string
   *                 description: 医护类型（如doctor、nurse、therapist）
   *               job_title:
   *                 type: string
   *                 description: 职称
   *               good_at_tags:
   *                 type: string
   *                 description: 擅长领域标签（逗号分隔）
   *               enable_online_service:
   *                 type: boolean
   *                 description: 是否可在咨询功能中被搜索
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
   *                   example: 医护人员信息更新成功
   *                 data:
   *                   $ref: '#/components/schemas/MedicalStaffInfoResponse'
   *       401:
   *         description: 未授权
   *       403:
   *         description: 当前用户角色不是医护人员
   *       500:
   *         description: 服务器内部错误
   */
  static async updateMyMedicalStaffInfo(ctx: Context) {
    const userState = ctx.state.user;
    if (!userState) {
      ctx.unauthorized('未授权');
      return;
    }

    const roles = (userState.roles || []).map(r => r.toLowerCase());
    const hasMedicalRole = roles.includes(RoleCode.MEDICAL_STAFF);
    if (!hasMedicalRole) {
      ctx.forbidden('当前用户角色不是医护人员');
      return;
    }

    const data: UpsertMedicalStaffInfoRequest =
      ctx.state.validatedData || ctx.request.body;
    const result = await MedicalStaffService.upsertForUser(userState.userId, data);
    ctx.success(result, '医护人员信息更新成功');
  }

  /**
   * @swagger
   * /api/v1/users/me/elders:
   *   get:
   *     summary: 获取当前用户关联的老人列表
   *     description: 分页获取当前登录用户关联的老人列表，可按老人姓名搜索
   *     tags: [用户管理]
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
   *         name: elder_name
   *         required: false
   *         schema:
   *           type: string
   *           maxLength: 50
   *         description: 老人姓名（模糊匹配）
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
   *                         type: object
   *                         properties:
   *                           relation_id:
   *                             type: integer
   *                             description: 关联关系ID
   *                           elder_id:
   *                             type: integer
   *                             description: 老人ID
   *                           relation_name:
   *                             type: string
   *                             nullable: true
   *                             description: 与老人的关系名称
   *                           remark:
   *                             type: string
   *                             nullable: true
   *                             description: 备注
   *                           elder:
   *                             $ref: '#/components/schemas/ElderResponse'
   *                           elder_info:
   *                             $ref: '#/components/schemas/ElderResponse'
   *       401:
   *         description: 未授权
   *       403:
   *         description: 当前用户角色不允许关联老人
   *       500:
   *         description: 服务器内部错误
   */
  static async getMyElders(ctx: Context) {
    const userState = ctx.state.user;
    console.log(userState)
    if (!userState) {
      ctx.unauthorized('未授权');
      return;
    }

    const roles = (userState.roles || []).map(r => r.toLowerCase());
    const hasAllowedRole =
      roles.includes(RoleCode.FAMILY) || roles.includes(RoleCode.MEDICAL_STAFF);
    if (!hasAllowedRole) {
      ctx.forbidden('当前用户角色不允许关联老人');
      return;
    }

    const data = (ctx.state.validatedQuery || ctx.state.validatedData || ctx.query) as QueryUserEldersRequest;
    const { page, pageSize, elder_name } = data;

    const { items, total } = await UserElderRelationService.getUserElders(userState.userId, {
      page,
      pageSize,
      elder_name
    });

    ctx.paginate(items, page, pageSize, total);
  }

  /**
   * @swagger
   * /api/v1/users/me/elders-with-stats:
   *   get:
   *     summary: 获取当前用户关联的老人列表（含档案统计）
   *     description: 一次性获取老人列表及其档案统计
   *     tags: [用户管理]
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
   *           default: 50
   *         description: 每页大小
   *       - in: query
   *         name: elder_name
   *         required: false
   *         schema:
   *           type: string
   *           maxLength: 50
   *         description: 老人姓名（模糊匹配）
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
   *                         $ref: '#/components/schemas/UserElderWithArchiveStatsResponse'
   *       401:
   *         description: 未授权
   *       403:
   *         description: 当前用户角色不允许关联老人
   *       500:
   *         description: 服务器内部错误
   */
  static async getMyEldersWithArchiveStats(ctx: Context) {
    const userState = ctx.state.user;
    if (!userState) {
      ctx.unauthorized('未授权');
      return;
    }

    const roles = (userState.roles || []).map(r => r.toLowerCase());
    const hasAllowedRole =
      roles.includes(RoleCode.FAMILY) || roles.includes(RoleCode.MEDICAL_STAFF);
    if (!hasAllowedRole) {
      ctx.forbidden('当前用户角色不允许关联老人');
      return;
    }

    const data = (ctx.state.validatedQuery || ctx.state.validatedData || ctx.query) as QueryUserEldersRequest;
    const { page, pageSize, elder_name } = data;

    const { items, total } = await UserElderRelationService.getUserEldersWithArchiveStats(userState.userId, {
      page,
      pageSize,
      elder_name
    });

    ctx.paginate(items, page, pageSize, total);
  }

  /**
   * @swagger
   * /api/v1/users/me/elders-with-health:
   *   get:
   *     summary: 获取当前用户关联的老人列表（含健康数据摘要）
   *     description: 一次性获取老人列表及其最新健康数据摘要（血压、血糖及判断结果）
   *     tags: [用户管理]
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
   *           default: 50
   *         description: 每页大小
   *       - in: query
   *         name: elder_name
   *         required: false
   *         schema:
   *           type: string
   *           maxLength: 50
   *         description: 老人姓名（模糊匹配）
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
   *                     abnormal_count:
   *                       type: integer
   *                       description: 异常指标数量
   *                     records:
   *                       type: array
   *                       items:
   *                         type: object
   *                         properties:
   *                           relation_id:
   *                             type: integer
   *                           elder_id:
   *                             type: integer
   *                           elder:
   *                             $ref: '#/components/schemas/ElderResponse'
   *                           health_summary:
   *                             type: object
   *                             properties:
   *                               latest_bp:
   *                                 type: string
   *                                 description: 最新血压（如 "120/80"）
   *                               latest_fpg:
   *                                 type: string
   *                                 description: 最新空腹血糖
   *                               bp_level:
   *                                 type: string
   *                                 description: 血压判断（NORMAL/MILD/MODERATE/SEVERE）
   *                               fpg_level:
   *                                 type: string
   *                                 description: 血糖判断（NORMAL/MILD/MODERATE/SEVERE）
   *       401:
   *         description: 未授权
   *       403:
   *         description: 当前用户角色不允许关联老人
   *       500:
   *         description: 服务器内部错误
   */
  static async getMyEldersWithHealth(ctx: Context) {
    const userState = ctx.state.user;
    if (!userState) {
      ctx.unauthorized('未授权');
      return;
    }

    const roles = (userState.roles || []).map(r => r.toLowerCase());
    const hasAllowedRole =
      roles.includes(RoleCode.FAMILY) || roles.includes(RoleCode.MEDICAL_STAFF);
    if (!hasAllowedRole) {
      ctx.forbidden('当前用户角色不允许关联老人');
      return;
    }

    const data = (ctx.state.validatedQuery || ctx.state.validatedData || ctx.query) as QueryUserEldersRequest;
    const page = data.page || 1;
    const pageSize = data.pageSize || 50;

    const { items, total, abnormal_count } = await UserElderRelationService.getUserEldersWithHealth(userState.userId, {
      page,
      pageSize,
      elder_name: data.elder_name
    });

    ctx.success({
      total,
      pages: Math.ceil(total / pageSize),
      current: page,
      size: pageSize,
      abnormal_count,
      records: items
    });
  }

  /**
   * @swagger
   * /api/v1/users/me/elders:
   *   post:
   *     summary: 关联老人
   *     description: 为当前登录用户新增与某位老人的关联关系
   *     tags: [用户管理]
   *     security:
   *       - bearerAuth: []
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - elder_id
   *             properties:
   *               elder_id:
   *                 type: integer
   *                 description: 要关联的老人ID
   *               relation_name:
   *                 type: string
   *                 maxLength: 50
   *                 description: 与老人的关系名称（如父亲、母亲等）
   *               remark:
   *                 type: string
   *                 maxLength: 200
   *                 description: 备注
   *     responses:
   *       200:
   *         description: 关联成功
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
   *                   example: 关联老人成功
   *                 data:
   *                   type: object
   *                   properties:
   *                     relation_id:
   *                       type: integer
   *                       description: 关联关系ID
   *                     elder_id:
   *                       type: integer
   *                       description: 老人ID
   *                     relation_name:
   *                       type: string
   *                       nullable: true
   *                       description: 与老人的关系名称
   *                     remark:
   *                       type: string
   *                       nullable: true
   *                       description: 备注
   *                     elder:
   *                       $ref: '#/components/schemas/ElderResponse'
   *                     elder_info:
   *                       $ref: '#/components/schemas/ElderResponse'
   *       400:
   *         description: 请求参数错误或关联关系已存在
   *       401:
   *         description: 未授权
   *       403:
   *         description: 当前用户角色不允许关联老人
   *       404:
   *         description: 老人信息不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async addMyElder(ctx: Context) {
    const userState = ctx.state.user;
    if (!userState) {
      ctx.unauthorized('未授权');
      return;
    }

    const roles = (userState.roles || []).map(r => r.toLowerCase());
    const hasAllowedRole =
      roles.includes(RoleCode.FAMILY) || roles.includes(RoleCode.MEDICAL_STAFF);
    if (!hasAllowedRole) {
      ctx.forbidden('当前用户角色不允许关联老人');
      return;
    }

    const data = ctx.state.validatedData || ctx.request.body;
    const result = await UserElderRelationService.addUserElderRelation(userState.userId, data);
    ctx.success(result, '关联老人成功');
  }

  /**
   * @swagger
   * /api/v1/users/me/elders/{relationId}:
   *   delete:
   *     summary: 取消关联老人
   *     description: 取消当前登录用户与某位老人的关联关系
   *     tags: [用户管理]
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - in: path
   *         name: relationId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 关联关系ID
   *         example: 1
   *     responses:
   *       200:
   *         description: 取消关联成功
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
   *                   example: 取消关联成功
   *                 data:
   *                   type: null
   *       400:
   *         description: 请求参数错误或关联ID无效
   *       401:
   *         description: 未授权
   *       403:
   *         description: 当前用户角色不允许关联老人
   *       404:
   *         description: 关联关系不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async deleteMyElder(ctx: Context) {
    const userState = ctx.state.user;
    if (!userState) {
      ctx.unauthorized('未授权');
      return;
    }

    const params = ctx.state.validatedData || ctx.params;
    const relationId = Number(params.relationId);
    if (Number.isNaN(relationId)) {
      ctx.badRequest('关联ID无效');
      return;
    }

    await UserElderRelationService.removeUserElderRelation(userState.userId, relationId);
    ctx.success(null, '取消关联成功');
  }

  /**
   * @swagger
   * /api/v1/users/{id}/roles:
   *   get:
   *     summary: 查询用户角色
   *     description: 查询指定用户的角色列表
   *     tags: [用户管理]
   *     parameters:
   *       - in: path
   *         name: id
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
   *                   type: array
   *                   items:
   *                     $ref: '#/components/schemas/RoleResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async getUserRoles(ctx: Context) {
    const { id } = ctx.state.validatedData || ctx.params;
    const result = await UserService.getUserRoles(id);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/users/online-medical-staff:
   *   get:
   *     summary: 获取在线医护人员列表
   *     description: 获取开通在线服务的医护人员列表，用于咨询功能选择目标医护人员
   *     tags: [用户管理]
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
   *     responses:
   *       200:
   *         description: 查询成功
   *       401:
   *         description: 未授权
   *       500:
   *         description: 服务器内部错误
   */
  static async getOnlineMedicalStaff(ctx: Context) {
    const data = ctx.query || {};
    const page = parseInt(data.page as string) || 1;
    const pageSize = parseInt(data.pageSize as string) || 10;
    const goodAtTags = data.goodAtTags as string || undefined;
    const phone = data.phone as string || undefined;

    const { items, total } = await MedicalStaffService.getOnlineStaff(page, pageSize, { goodAtTags, phone });
    ctx.paginate(items, page, pageSize, total);
  }
}
