export class AppError extends Error {
  public readonly name: string;
  public readonly statusCode: number;

  constructor(message: string, statusCode: number = 500, name: string = 'AppError') {
    super(message);
    this.name = name;
    this.statusCode = statusCode;
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

export class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 400, 'ValidationError');
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = '未授权访问') {
    super(message, 401, 'UnauthorizedError');
  }
}

export class ForbiddenError extends AppError {
  constructor(message: string = '禁止访问') {
    super(message, 403, 'ForbiddenError');
  }
}

export class NotFoundError extends AppError {
  constructor(message: string = '资源不存在') {
    super(message, 404, 'NotFoundError');
  }
}