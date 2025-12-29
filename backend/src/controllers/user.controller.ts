import { Context } from 'koa';
import { UserService } from '../services/user.service';
import { CreateUserRequest, UpdateUserRequest, ChangePasswordRequest, createUserSchema, updateUserSchema, queryUserSchema, loginSchema, changePasswordSchema, idParamSchema } from '../dto/requests/user.dto';

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
   *                   $ref: '#/components/schemas/UserResponse'
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
   *                   $ref: '#/components/schemas/UserResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 用户不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getUserById(ctx: Context) {
    const { id } = ctx.state.validatedData || ctx.params;
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
    const { id } = ctx.state.validatedData || ctx.params;
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
    const { id } = ctx.state.validatedData || ctx.params;
    await UserService.deleteUser(id);
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
    const { id } = ctx.state.user;
    const data: ChangePasswordRequest = ctx.state.validatedData || ctx.request.body;
    await UserService.changePassword(id, data);
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
    const { id } = ctx.state.user;
    const result = await UserService.getUserById(id);
    ctx.success(result);
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
}
