import { RoleRepository, Role } from '../repositories/role.repository';
import { CreateRoleRequest, UpdateRoleRequest, RoleResponse, RoleWithUsersResponse } from '../dto/requests/role.dto';

export class RoleService {
  static async createRole(data: CreateRoleRequest): Promise<RoleResponse> {
    const existingRole = await RoleRepository.findByRoleCode(data.role_code);
    if (existingRole) {
      throw new Error('该角色代码已存在');
    }

    const roleData: Omit<Role, 'id' | 'created_at' | 'updated_at'> = {
      role_code: data.role_code,
      role_name: data.role_name,
      description: data.description || null,
      level: 0
    };

    const insertId = await RoleRepository.create(roleData);
    const role = await RoleRepository.findById(insertId);

    if (!role) {
      throw new Error('创建角色失败');
    }

    return this.toResponse(role);
  }

  static async getRoleById(id: number): Promise<RoleWithUsersResponse> {
    const role = await RoleRepository.findById(id);
    if (!role) {
      throw new Error('角色不存在');
    }

    const userCount = await RoleRepository.getUserCountByRoleId(id);

    return {
      id: role.id,
      role_code: role.role_code,
      role_name: role.role_name,
      description: role.description,
      user_count: userCount,
      created_at: role.created_at,
      updated_at: role.updated_at
    };
  }

  static async getRoleList(page: number, pageSize: number, roleCode?: string, roleName?: string): Promise<{ items: RoleResponse[]; total: number }> {
    let where = '1=1';
    const params: any[] = [];

    if (roleCode) {
      where += ' AND role_code LIKE ?';
      params.push(`%${roleCode}%`);
    }
    if (roleName) {
      where += ' AND role_name LIKE ?';
      params.push(`%${roleName}%`);
    }

    const { items, total } = await RoleRepository.findAll(page, pageSize, where, params);
    return {
      items: items.map(item => this.toResponse(item)),
      total
    };
  }

  static async updateRole(id: number, data: UpdateRoleRequest): Promise<RoleResponse> {
    const existingRole = await RoleRepository.findById(id);
    if (!existingRole) {
      throw new Error('角色不存在');
    }

    const updateData: Partial<Omit<Role, 'id' | 'created_at' | 'updated_at'>> = {};
    if (data.role_name !== undefined) updateData.role_name = data.role_name;
    if (data.description !== undefined) updateData.description = data.description;

    const success = await RoleRepository.update(id, updateData);
    if (!success) {
      throw new Error('更新角色失败');
    }

    const role = await RoleRepository.findById(id);
    if (!role) {
      throw new Error('获取更新后的角色信息失败');
    }

    return this.toResponse(role);
  }

  static async deleteRole(id: number): Promise<boolean> {
    const role = await RoleRepository.findById(id);
    if (!role) {
      throw new Error('角色不存在');
    }

    const userCount = await RoleRepository.getUserCountByRoleId(id);
    if (userCount > 0) {
      throw new Error('该角色下还有用户，无法删除');
    }

    const success = await RoleRepository.delete(id);
    if (!success) {
      throw new Error('删除角色失败');
    }

    return true;
  }

  static async assignRoleToUser(userId: number, roleId: number): Promise<boolean> {
    const role = await RoleRepository.findById(roleId);
    if (!role) {
      throw new Error('角色不存在');
    }

    const success = await RoleRepository.assignRoleToUser(userId, roleId);
    return success;
  }

  static async removeRoleFromUser(userId: number, roleId: number): Promise<boolean> {
    const role = await RoleRepository.findById(roleId);
    if (!role) {
      throw new Error('角色不存在');
    }

    const success = await RoleRepository.removeRoleFromUser(userId, roleId);
    return success;
  }

  static async updateUserRoles(userId: number, roleIds: number[]): Promise<boolean> {
    for (const roleId of roleIds) {
      const role = await RoleRepository.findById(roleId);
      if (!role) {
        throw new Error(`角色ID ${roleId} 不存在`);
      }
    }

    const success = await RoleRepository.updateUserRoles(userId, roleIds);
    return success;
  }

  static async getUserRoles(userId: number): Promise<RoleResponse[]> {
    const roles = await RoleRepository.findByUserId(userId);
    return roles.map(role => this.toResponse(role));
  }

  private static toResponse(role: Role): RoleResponse {
    return {
      id: role.id,
      role_code: role.role_code,
      role_name: role.role_name,
      description: role.description,
      created_at: role.created_at,
      updated_at: role.updated_at
    };
  }
}
