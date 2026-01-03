import { UserRepository, User, UserWithRoles } from '../repositories/user.repository';
import { RoleRepository, Role } from '../repositories/role.repository';
import { CreateUserRequest, UpdateUserRequest, UserResponse, UserWithRoleResponse, ChangePasswordRequest, LoginRequest, LoginResponse } from '../dto/requests/user.dto';
import * as bcrypt from 'bcryptjs';
import * as jwt from 'jsonwebtoken';
import { ValidationError, NotFoundError, ForbiddenError } from '../utils/errors';
import { Database } from '../config/database';
import { RoleCode } from '../config/rbac.config';

export class UserService {
  private static readonly SALT_ROUNDS = 10;
  private static readonly JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
  private static readonly JWT_EXPIRES_IN = '7d';

  static async createUser(data: CreateUserRequest): Promise<UserWithRoleResponse> {
    const existingUser = await UserRepository.findByUsername(data.username);
    if (existingUser) {
      throw new ValidationError('用户名已存在');
    }

    if (data.email) {
      const existingEmail = await UserRepository.findByEmail(data.email);
      if (existingEmail) {
        throw new ValidationError('邮箱已被使用');
      }
    }

    if (data.phone) {
      const existingPhone = await UserRepository.findByPhone(data.phone);
      if (existingPhone) {
        throw new ValidationError('手机号已被使用');
      }
    }

    const hashedPassword = await bcrypt.hash(data.password, this.SALT_ROUNDS);

    const connection = await Database.beginTransaction();

    try {
      const userData: Omit<User, 'id' | 'created_at' | 'updated_at'> = {
        username: data.username,
        password: hashedPassword,
        email: data.email || null,
        phone: data.phone || null,
        real_name: data.real_name || null,
        avatar: data.avatar || null,
        status: data.status || 'active',
        is_verified: data.is_verified ?? false,
        last_login_at: null,
        last_login_ip: null
      };

      const insertUserSql = `
        INSERT INTO users (username, password, email, phone, real_name, avatar, status, is_verified, last_login_at, last_login_ip)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `;
      const userParams = [
        userData.username,
        userData.password,
        userData.email,
        userData.phone,
        userData.real_name,
        userData.avatar,
        userData.status,
        userData.is_verified,
        userData.last_login_at,
        userData.last_login_ip
      ];

      const [userResult] = await connection.execute(insertUserSql, userParams);
      const insertId = (userResult as any).insertId as number;

      const roleCode: RoleCode = (data.role_code as RoleCode) || RoleCode.ELDER;
      const role = await RoleRepository.findByRoleCode(roleCode);

      if (!role) {
        throw new Error('指定角色不存在，请先初始化角色数据');
      }

      const checkRoleSql = 'SELECT id FROM user_roles WHERE user_id = ? AND role_id = ?';
      const [checkRows] = await connection.execute(checkRoleSql, [insertId, role.id]);
      const exists = Array.isArray(checkRows) && (checkRows as any[]).length > 0;

      if (!exists) {
        const insertUserRoleSql = 'INSERT INTO user_roles (user_id, role_id) VALUES (?, ?)';
        await connection.execute(insertUserRoleSql, [insertId, role.id]);
      }

      if (roleCode === RoleCode.ELDER) {
        const elderName = data.real_name && data.real_name.trim() !== '' ? data.real_name : data.username;
        const elderPhone = data.phone && data.phone.trim() !== '' ? data.phone : data.username;

        const insertElderSql = `
          INSERT INTO elder_basic_info (name, gender, birth_date, phone, address, emergency_contact, height, weight, blood_type)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;
        const elderParams = [
          elderName,
          1,
          '1970-01-01',
          elderPhone,
          null,
          '',
          null,
          null,
          null
        ];

        await connection.execute(insertElderSql, elderParams);
      }

      await Database.commitTransaction(connection);

      const user = await UserRepository.findByIdWithRoles(insertId);

      if (!user) {
        throw new Error('创建用户失败');
      }

      return this.toResponseWithRoles(user);
    } catch (error) {
      await Database.rollbackTransaction(connection);
      throw error;
    }
  }

  static async getUserById(id: number): Promise<UserWithRoleResponse> {
    const user = await UserRepository.findByIdWithRoles(id);
    if (!user) {
      throw new NotFoundError('用户不存在');
    }
    return this.toResponseWithRoles(user);
  }

  static async getUserList(
    page: number,
    pageSize: number,
    username?: string,
    email?: string,
    phone?: string,
    realName?: string,
    status?: 'active' | 'inactive' | 'locked'
  ): Promise<{ items: UserResponse[]; total: number }> {
    let where = '1=1';
    const params: any[] = [];

    if (username) {
      where += ' AND username LIKE ?';
      params.push(`%${username}%`);
    }
    if (email) {
      where += ' AND email LIKE ?';
      params.push(`%${email}%`);
    }
    if (phone) {
      where += ' AND phone LIKE ?';
      params.push(`%${phone}%`);
    }
    if (realName) {
      where += ' AND real_name LIKE ?';
      params.push(`%${realName}%`);
    }
    if (status) {
      where += ' AND status = ?';
      params.push(status);
    }

    const { items, total } = await UserRepository.findAll(page, pageSize, where, params);
    return {
      items: items.map(item => this.toResponse(item)),
      total
    };
  }

  static async updateUser(id: number, data: UpdateUserRequest): Promise<UserResponse> {
    const existingUser = await UserRepository.findById(id);
    if (!existingUser) {
      throw new NotFoundError('用户不存在');
    }

    if (data.email && data.email !== existingUser.email) {
      const existingEmail = await UserRepository.findByEmail(data.email);
      if (existingEmail) {
        throw new ValidationError('邮箱已被使用');
      }
    }

    if (data.phone && data.phone !== existingUser.phone) {
      const existingPhone = await UserRepository.findByPhone(data.phone);
      if (existingPhone) {
        throw new ValidationError('手机号已被使用');
      }
    }

    const updateData: Partial<Omit<User, 'id' | 'created_at' | 'updated_at'>> = {};
    if (data.password !== undefined) {
      updateData.password = await bcrypt.hash(data.password, this.SALT_ROUNDS);
    }
    if (data.email !== undefined) updateData.email = data.email;
    if (data.phone !== undefined) updateData.phone = data.phone;
    if (data.real_name !== undefined) updateData.real_name = data.real_name;
    if (data.avatar !== undefined) updateData.avatar = data.avatar;
    if (data.status !== undefined) updateData.status = data.status;
    if (data.is_verified !== undefined) updateData.is_verified = data.is_verified;

    const success = await UserRepository.update(id, updateData);
    if (!success) {
      throw new Error('更新用户失败');
    }

    const user = await UserRepository.findById(id);
    if (!user) {
      throw new Error('获取更新后的用户信息失败');
    }

    return this.toResponse(user);
  }

  static async deleteUser(id: number): Promise<boolean> {
    const user = await UserRepository.findById(id);
    if (!user) {
      throw new NotFoundError('用户不存在');
    }

    const success = await UserRepository.delete(id);
    if (!success) {
      throw new Error('删除用户失败');
    }

    return true;
  }

  static async login(data: LoginRequest, ip: string): Promise<LoginResponse> {
    const user = await UserRepository.findByUsername(data.username);
    if (!user) {
      throw new Error('用户名或密码错误');
    }

    if (user.status !== 'active') {
      throw new ForbiddenError('账户已被禁用或锁定');
    }

    const isPasswordValid = await bcrypt.compare(data.password, user.password);
    if (!isPasswordValid) {
      throw new Error('用户名或密码错误');
    }

    await UserRepository.updateLastLogin(user.id, ip);

    const userWithRoles = await UserRepository.findByIdWithRoles(user.id);
    if (!userWithRoles) {
      throw new Error('获取用户信息失败');
    }

    const token = this.generateToken(userWithRoles);

    return {
      token,
      user: this.toResponseWithRoles(userWithRoles)
    };
  }

  static async changePassword(userId: number, data: ChangePasswordRequest): Promise<boolean> {
    const user = await UserRepository.findById(userId);
    if (!user) {
      throw new NotFoundError('用户不存在');
    }

    const isPasswordValid = await bcrypt.compare(data.old_password, user.password);
    if (!isPasswordValid) {
      throw new Error('原密码错误');
    }

    const hashedPassword = await bcrypt.hash(data.new_password, this.SALT_ROUNDS);
    const success = await UserRepository.update(userId, { password: hashedPassword });

    if (!success) {
      throw new Error('修改密码失败');
    }

    return true;
  }

  static async getUserRoles(userId: number): Promise<Role[]> {
    return await RoleRepository.findByUserId(userId);
  }

  private static generateToken(user: UserWithRoles): string {
    const payload = {
      userId: user.id,
      username: user.username,
      roles: user.roles.map(role => role.role_code)
    };

    return jwt.sign(payload, this.JWT_SECRET, {
      expiresIn: this.JWT_EXPIRES_IN
    } as jwt.SignOptions);
  }

  private static toResponse(user: User): UserResponse {
    return {
      id: user.id,
      username: user.username,
      email: user.email,
      phone: user.phone,
      real_name: user.real_name,
      avatar: user.avatar,
      status: user.status,
      is_verified: user.is_verified,
      last_login_at: user.last_login_at,
      last_login_ip: user.last_login_ip,
      created_at: user.created_at,
      updated_at: user.updated_at
    };
  }

  private static toResponseWithRoles(user: UserWithRoles): UserWithRoleResponse {
    return {
      ...this.toResponse(user),
      roles: user.roles.map(role => ({
        id: role.id,
        role_code: role.role_code,
        role_name: role.role_name,
        description: role.description
      }))
    };
  }
}
