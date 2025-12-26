import { Context } from 'koa';
import { RoleService } from '../services/role.service';
import { CreateRoleRequest, UpdateRoleRequest } from '../dto/requests/role.dto';

export class RoleController {
  static async createRole(ctx: Context) {
    const data: CreateRoleRequest = ctx.request.body;
    const result = await RoleService.createRole(data);
    ctx.success(result, '角色创建成功');
  }

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
