import { Context, Next } from 'koa';
import crypto from 'crypto';

// 统一响应接口定义
interface ApiResponse<T = any> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
  requestId?: string;
}

// 分页响应接口定义
interface PaginationMeta {
  currentPage: number;
  pageSize: number;
  totalItems: number;
  totalPages: number;
}

interface PaginationResponse<T = any> {
  items: T[];
  meta: PaginationMeta;
}

// 统一API响应格式中间件
export const responseFormatter = async (ctx: Context, next: Next): Promise<void> => {
  // 生成请求ID
  ctx.requestId = crypto.randomUUID().toString();

  // 成功响应方法
  ctx.success = <T = any>(data?: T, message: string = '请求成功', code: number = 200): void => {
    const response: ApiResponse<T> = {
      code,
      message,
      data,
      timestamp: Date.now(),
      requestId: ctx.requestId
    };
    ctx.status = code;
    ctx.body = response;
  };

  // 分页响应方法
  ctx.paginate = <T = any>(
    items: T[],
    currentPage: number,
    pageSize: number,
    totalItems: number,
    message: string = '请求成功'
  ): void => {
    const totalPages = Math.ceil(totalItems / pageSize);
    const paginationData: PaginationResponse<T> = {
      items,
      meta: {
        currentPage,
        pageSize,
        totalItems,
        totalPages
      }
    };
    ctx.success(paginationData, message);
  };

  // 错误响应方法
  ctx.error = (message: string, code: number = 500, error?: any): void => {
    const response: ApiResponse = {
      code,
      message,
      timestamp: Date.now(),
      requestId: ctx.requestId
    };
    
    // 在开发环境下返回详细错误信息
    if (process.env.NODE_ENV === 'development' && error) {
      (response as any).error = error;
    }
    
    ctx.status = code;
    ctx.body = response;
  };

  // 404错误处理
  ctx.notFound = (message: string = '资源不存在'): void => {
    ctx.error(message, 404);
  };

  // 401错误处理
  ctx.unauthorized = (message: string = '未授权访问'): void => {
    ctx.error(message, 401);
  };

  // 403错误处理
  ctx.forbidden = (message: string = '禁止访问'): void => {
    ctx.error(message, 403);
  };

  // 400错误处理
  ctx.badRequest = (message: string = '请求参数错误'): void => {
    ctx.error(message, 400);
  };

  // 500错误处理
  ctx.serverError = (message: string = '服务器内部错误'): void => {
    ctx.error(message, 500);
  };

  try {
    await next();
    
    // 如果没有设置响应体，默认返回200成功
    if (!ctx.body && ctx.status >= 200 && ctx.status < 300) {
      ctx.success(undefined, '请求成功', ctx.status);
    }
  } catch (error: any) {
    // 统一处理异常
    console.error('API Error:', error);
    
    // 根据错误类型设置不同的状态码
    if (error.name === 'ValidationError') {
      ctx.badRequest(error.message);
    } else if (error.name === 'UnauthorizedError') {
      ctx.unauthorized(error.message);
    } else if (error.name === 'ForbiddenError') {
      ctx.forbidden(error.message);
    } else if (error.name === 'NotFoundError') {
      ctx.notFound(error.message);
    } else {
      ctx.serverError(process.env.NODE_ENV === 'development' ? error.message : '服务器内部错误');
    }
  }
};

// 扩展Koa Context类型声明
declare module 'koa' {
  interface Context {
    success: <T = any>(data?: T, message?: string, code?: number) => void;
    paginate: <T = any>(items: T[], currentPage: number, pageSize: number, totalItems: number, message?: string) => void;
    error: (message: string, code?: number, error?: any) => void;
    notFound: (message?: string) => void;
    unauthorized: (message?: string) => void;
    forbidden: (message?: string) => void;
    badRequest: (message?: string) => void;
    serverError: (message?: string) => void;
    requestId?: string;
  }
}
