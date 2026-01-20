import { Context, Next } from 'koa';
import jwt from 'jsonwebtoken';
import config from '../config/env';
import { UserRepository } from '../repositories/user.repository';
import { RoleCode } from '../config/rbac.config';

interface JwtPayload {
  userId: number;
  username: string;
  roles: string[];
  iat: number;
  exp: number;
}

declare module 'koa' {
  interface DefaultState {
    user?: JwtPayload;
  }
}

export const authMiddleware = async (ctx: Context, next: Next): Promise<void> => {
  try {
    console.log(ctx.headers)
    console.log(ctx.body)
    const authHeader = ctx.headers.authorization;

    if (!authHeader) {
      ctx.unauthorized('缺少认证令牌');
      return;
    }

    const parts = authHeader.split(' ');
    if (parts.length !== 2 || parts[0] !== 'Bearer') {
      ctx.unauthorized('认证令牌格式错误');
      return;
    }

    const token = parts[1];

    try {
      const decoded = jwt.verify(token, config.JWT_SECRET) as JwtPayload;
      ctx.state.user = decoded;
      console.log("authMiddleware:")
      console.log(ctx.state.user)
      await next();
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        ctx.unauthorized('认证令牌已过期');
        return;
      }
      if (error instanceof jwt.JsonWebTokenError) {
        ctx.unauthorized('无效的认证令牌');
        return;
      }
      throw error;
    }
  } catch (error) {
    ctx.serverError('认证过程中发生错误');
  }
};

export const optionalAuthMiddleware = async (ctx: Context, next: Next): Promise<void> => {
  const authHeader = ctx.headers.authorization;

  if (!authHeader) {
    await next();
    return;
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    await next();
    return;
  }

  const token = parts[1];

  try {
    const decoded = jwt.verify(token, config.JWT_SECRET) as JwtPayload;
    ctx.state.user = decoded;
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError || error instanceof jwt.JsonWebTokenError) {
      await next();
      return;
    }
    throw error;
  }

  await next();
};

export const roleAuthMiddleware = (...allowedRoles: string[]) => {
  return async (ctx: Context, next: Next): Promise<void> => {
    if (!ctx.state.user) {
      ctx.unauthorized('用户未认证');
      return;
    }

    const userRoles = ctx.state.user.roles || [];
    const hasRole = allowedRoles.some(role => userRoles.includes(role));

    if (!hasRole) {
      ctx.forbidden('权限不足');
      return;
    }

    await next();
  };
};

export const requireRole = (role: RoleCode) => {
  return roleAuthMiddleware(role);
};

export const requireAnyRole = (...roles: RoleCode[]) => {
  return roleAuthMiddleware(...roles);
};

export const requireAllRoles = (...roles: RoleCode[]) => {
  return async (ctx: Context, next: Next): Promise<void> => {
    if (!ctx.state.user) {
      ctx.unauthorized('用户未认证');
      return;
    }

    const userRoles = ctx.state.user.roles || [];
    const hasAllRoles = roles.every(role => userRoles.includes(role));

    if (!hasAllRoles) {
      ctx.forbidden('权限不足');
      return;
    }

    await next();
  };
};

export const generateToken = (payload: Omit<JwtPayload, 'iat' | 'exp'>): string => {
  return jwt.sign(payload, config.JWT_SECRET, {
    expiresIn: config.JWT_EXPIRES_IN
  } as jwt.SignOptions);
};

export const verifyToken = (token: string): JwtPayload => {
  return jwt.verify(token, config.JWT_SECRET) as JwtPayload;
};

export const refreshUserToken = async (userId: number): Promise<string> => {
  const user = await UserRepository.findByIdWithRoles(userId);
  if (!user) {
    throw new Error('用户不存在');
  }

  const payload: Omit<JwtPayload, 'iat' | 'exp'> = {
    userId: user.id,
    username: user.username,
    roles: user.roles.map(role => role.role_code)
  };

  return generateToken(payload);
};
