// 环境变量配置示例文件
// 复制此文件为 env.ts 并根据实际环境修改配置

export const envConfig = {
  // 服务器配置
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: parseInt(process.env.PORT || '3000', 10),

  // 数据库配置 (MySQL)
  DATABASE_URL: process.env.DATABASE_URL || 'mysql://username:password@localhost:3306/health_doc_db',

  // JWT配置
  JWT_SECRET: process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-this-in-production',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '7d',

  // Redis配置 (可选)
  REDIS_URL: process.env.REDIS_URL || 'redis://localhost:6379',

  // 日志配置
  LOG_LEVEL: process.env.LOG_LEVEL || 'info',
};

// 必需的环境变量列表
export const requiredEnvVars = [
  'DATABASE_URL',
  'JWT_SECRET'
];



