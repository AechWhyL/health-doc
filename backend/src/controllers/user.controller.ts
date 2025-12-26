import { Context } from 'koa';
import { UserService } from '../services/user.service';
import { CreateUserRequest, UpdateUserRequest, ChangePasswordRequest } from '../dto/requests/user.dto';

export class UserController {
  static async createUser(ctx: Context) {
    const data: CreateUserRequest = ctx.request.body;
    const result = await UserService.createUser(data);
    ctx.success(result, '用户创建成功');
  }

  static async getUserById(ctx: Context) {
    const { id } = ctx.params;
    const userId = parseInt(id, 10);
    if (isNaN(userId)) {
      ctx.badRequest('无效的用户ID');
      return;
    }
    const result = await UserService.getUserById(userId);
    ctx.success(result);
  }

  static async getUserList(ctx: Context) {
    const { page = 1, pageSize = 10, username, email, phone, real_name, status } = ctx.query as any;
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

    const { items, total } = await UserService.getUserList(
      pageNum, 
      pageSizeNum, 
      username, 
      email, 
      phone, 
      real_name, 
      status
    );
    
    ctx.paginate(items, pageNum, pageSizeNum, total);
  }

  static async updateUser(ctx: Context) {
    const { id } = ctx.params;
    const userId = parseInt(id, 10);
    if (isNaN(userId)) {
      ctx.badRequest('无效的用户ID');
      return;
    }

    const data: UpdateUserRequest = ctx.request.body;
    const result = await UserService.updateUser(userId, data);
    ctx.success(result, '用户更新成功');
  }

  static async deleteUser(ctx: Context) {
    const { id } = ctx.params;
    const userId = parseInt(id, 10);
    if (isNaN(userId)) {
      ctx.badRequest('无效的用户ID');
      return;
    }

    await UserService.deleteUser(userId);
    ctx.success(null, '用户删除成功');
  }

  static async login(ctx: Context) {
    const { username, password } = ctx.request.body;
    const ip = ctx.ip || ctx.request.ip || '127.0.0.1';
    
    if (!username || !password) {
      ctx.badRequest('用户名和密码不能为空');
      return;
    }

    const result = await UserService.login({ username, password }, ip);
    ctx.success(result, '登录成功');
  }

  static async changePassword(ctx: Context) {
    const { id } = ctx.state.user;
    const userId = parseInt(id, 10);
    
    if (isNaN(userId)) {
      ctx.badRequest('无效的用户ID');
      return;
    }

    const data: ChangePasswordRequest = ctx.request.body;
    await UserService.changePassword(userId, data);
    ctx.success(null, '密码修改成功');
  }

  static async getCurrentUser(ctx: Context) {
    const { id } = ctx.state.user;
    const userId = parseInt(id, 10);
    
    if (isNaN(userId)) {
      ctx.badRequest('无效的用户ID');
      return;
    }

    const result = await UserService.getUserById(userId);
    ctx.success(result);
  }

  static async getUserRoles(ctx: Context) {
    const { id } = ctx.params;
    const userId = parseInt(id, 10);
    if (isNaN(userId)) {
      ctx.badRequest('无效的用户ID');
      return;
    }

    const result = await UserService.getUserRoles(userId);
    ctx.success(result);
  }
}
