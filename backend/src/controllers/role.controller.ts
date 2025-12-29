import { Context } from 'koa';
import { RoleService } from '../services/role.service';
import { CreateRoleRequest, UpdateRoleRequest } from '../dto/requests/role.dto';

export class RoleController {
  /**
   * @swagger
   * /api/v1/roles:
   *   post:
   *     summary: 创建角色
   *     description: 创建新的角色
   *     tags: [角色管理]
   *     security:
   *       - bearerAuth: []
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - role_code
   *               - role_name
   *             properties:
   *               role_code:
   *                 type: string
   *                 description: 角色编码
   *                 example: ADMIN
   *               role_name:
   *                 type: string
   *                 description: 角色名称
   *                 example: 管理员
   *               description:
   *                 type: string
   *                 description: 角色描述
   *                 example: 系统管理员角色
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
   *                   example: 角色创建成功
   *                 data:
   *                   $ref: '#/components/schemas/RoleResponse'
   *       400:
   *         description: 请求参数错误
   *       401:
   *         description: 未授权
   *       500:
   *         description: 服务器内部错误
   */
  static async createRole(ctx: Context) {
    const data: CreateRoleRequest = ctx.request.body;
    const result = await RoleService.createRole(data);
    ctx.success(result, '角色创建成功');
  }

  /**
   * @swagger
   * /api/v1/roles/{id}:
   *   get:
   *     summary: 查询角色
   *     description: 根据ID查询角色
   *     tags: [角色管理]
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 角色ID
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
   *                   $ref: '#/components/schemas/RoleResponse'
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 角色不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async getRoleById(ctx: Context) {
    const { id } = ctx.params;
    const roleId = parseInt(id, 10);
    if (isNaN(roleId)) {
      ctx.badRequest('无效的角色ID');
      return;
    }
    const result = await RoleService.getRoleById(roleId);
    ctx.success(result);
  }

  /**
   * @swagger
   * /api/v1/roles:
   *   get:
   *     summary: 查询角色列表
   *     description: 分页查询角色列表，支持按角色编码和名称搜索
   *     tags: [角色管理]
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
   *         name: role_code
   *         required: false
   *         schema:
   *           type: string
   *         description: 角色编码
   *       - in: query
   *         name: role_name
   *         required: false
   *         schema:
   *           type: string
   *         description: 角色名称
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
   *                         $ref: '#/components/schemas/RoleResponse'
   *       400:
   *         description: 请求参数错误
   *       500:
   *         description: 服务器内部错误
   */
  static async getRoleList(ctx: Context) {
    const { page = 1, pageSize = 10, role_code, role_name } = ctx.query as any;
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

    const { items, total } = await RoleService.getRoleList(pageNum, pageSizeNum, role_code, role_name);
    
    ctx.paginate(items, pageNum, pageSizeNum, total);
  }

  /**
   * @swagger
   * /api/v1/roles/{id}:
   *   put:
   *     summary: 更新角色
   *     description: 根据ID更新角色
   *     tags: [角色管理]
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 角色ID
   *         example: 1
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             properties:
   *               role_name:
   *                 type: string
   *                 description: 角色名称
   *               description:
   *                 type: string
   *                 description: 角色描述
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
   *                   example: 角色更新成功
   *                 data:
   *                   $ref: '#/components/schemas/RoleResponse'
   *       400:
   *         description: 请求参数错误
   *       401:
   *         description: 未授权
   *       404:
   *         description: 角色不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async updateRole(ctx: Context) {
    const { id } = ctx.params;
    const roleId = parseInt(id, 10);
    if (isNaN(roleId)) {
      ctx.badRequest('无效的角色ID');
      return;
    }

    const data: UpdateRoleRequest = ctx.request.body;
    const result = await RoleService.updateRole(roleId, data);
    ctx.success(result, '角色更新成功');
  }

  /**
   * @swagger
   * /api/v1/roles/{id}:
   *   delete:
   *     summary: 删除角色
   *     description: 根据ID删除角色
   *     tags: [角色管理]
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 角色ID
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
   *                   example: 角色删除成功
   *                 data:
   *                   type: null
   *       400:
   *         description: 请求参数错误
   *       401:
   *         description: 未授权
   *       404:
   *         description: 角色不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async deleteRole(ctx: Context) {
    const { id } = ctx.params;
    const roleId = parseInt(id, 10);
    if (isNaN(roleId)) {
      ctx.badRequest('无效的角色ID');
      return;
    }

    await RoleService.deleteRole(roleId);
    ctx.success(null, '角色删除成功');
  }

  /**
   * @swagger
   * /api/v1/roles/users/{userId}/roles/{roleId}:
   *   post:
   *     summary: 为用户分配角色
   *     description: 为指定用户分配角色
   *     tags: [角色管理]
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - in: path
   *         name: userId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 用户ID
   *         example: 1
   *       - in: path
   *         name: roleId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 角色ID
   *         example: 1
   *     responses:
   *       200:
   *         description: 分配成功
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
   *                   example: 角色分配成功
   *                 data:
   *                   type: null
   *       400:
   *         description: 请求参数错误
   *       401:
   *         description: 未授权
   *       500:
   *         description: 服务器内部错误
   */
  static async assignRoleToUser(ctx: Context) {
    const { userId, roleId } = ctx.params;
    const userIdNum = parseInt(userId, 10);
    const roleIdNum = parseInt(roleId, 10);
    
    if (isNaN(userIdNum) || isNaN(roleIdNum)) {
      ctx.badRequest('无效的用户ID或角色ID');
      return;
    }

    await RoleService.assignRoleToUser(userIdNum, roleIdNum);
    ctx.success(null, '角色分配成功');
  }

  /**
   * @swagger
   * /api/v1/roles/users/{userId}/roles/{roleId}:
   *   delete:
   *     summary: 移除用户角色
   *     description: 移除指定用户的角色
   *     tags: [角色管理]
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - in: path
   *         name: userId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 用户ID
   *         example: 1
   *       - in: path
   *         name: roleId
   *         required: true
   *         schema:
   *           type: integer
   *         description: 角色ID
   *         example: 1
   *     responses:
   *       200:
   *         description: 移除成功
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
   *                   example: 角色移除成功
   *                 data:
   *                   type: null
   *       400:
   *         description: 请求参数错误
   *       401:
   *         description: 未授权
   *       500:
   *         description: 服务器内部错误
   */
  static async removeRoleFromUser(ctx: Context) {
    const { userId, roleId } = ctx.params;
    const userIdNum = parseInt(userId, 10);
    const roleIdNum = parseInt(roleId, 10);
    
    if (isNaN(userIdNum) || isNaN(roleIdNum)) {
      ctx.badRequest('无效的用户ID或角色ID');
      return;
    }

    await RoleService.removeRoleFromUser(userIdNum, roleIdNum);
    ctx.success(null, '角色移除成功');
  }

  /**
   * @swagger
   * /api/v1/roles/users/{id}/roles:
   *   put:
   *     summary: 更新用户角色
   *     description: 更新指定用户的角色列表
   *     tags: [角色管理]
   *     security:
   *       - bearerAuth: []
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
   *             required:
   *               - role_ids
   *             properties:
   *               role_ids:
   *                 type: array
   *                 items:
   *                   type: integer
   *                 description: 角色ID数组
   *                 example: [1, 2, 3]
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
   *                   example: 用户角色更新成功
   *                 data:
   *                   type: null
   *       400:
   *         description: 请求参数错误
   *       401:
   *         description: 未授权
   *       500:
   *         description: 服务器内部错误
   */
  static async updateUserRoles(ctx: Context) {
    const { id } = ctx.params;
    const userId = parseInt(id, 10);
    if (isNaN(userId)) {
      ctx.badRequest('无效的用户ID');
      return;
    }

    const { role_ids } = ctx.request.body;
    if (!Array.isArray(role_ids)) {
      ctx.badRequest('角色ID必须是数组');
      return;
    }

    const roleIds = role_ids.map((id: any) => parseInt(id, 10));
    if (roleIds.some(id => isNaN(id))) {
      ctx.badRequest('角色ID数组包含无效的ID');
      return;
    }

    await RoleService.updateUserRoles(userId, roleIds);
    ctx.success(null, '用户角色更新成功');
  }

  /**
   * @swagger
   * /api/v1/roles/users/{id}/roles:
   *   get:
   *     summary: 查询用户角色
   *     description: 查询指定用户的角色列表
   *     tags: [角色管理]
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
    const { id } = ctx.params;
    const userId = parseInt(id, 10);
    if (isNaN(userId)) {
      ctx.badRequest('无效的用户ID');
      return;
    }

    const result = await RoleService.getUserRoles(userId);
    ctx.success(result);
  }
}
