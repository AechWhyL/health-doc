import dotenv from 'dotenv';

// 加载环境变量
dotenv.config();

interface EnvConfig {
  // 服务器配置
  NODE_ENV: string;
  PORT: number;

  // 数据库配置
  DATABASE_URL: string;

  // JWT配置
  JWT_SECRET: string;
  JWT_EXPIRES_IN: string;

  // Redis配置 (可选)
  REDIS_URL?: string;

  // 日志配置
  LOG_LEVEL: string;
}

const config: EnvConfig = {
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: parseInt(process.env.PORT || '3000', 10),
  DATABASE_URL: process.env.DATABASE_URL || 'mysql://root:password@localhost:3306/health_doc_db',
  JWT_SECRET: process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-this-in-production',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '7d',
  REDIS_URL: process.env.REDIS_URL,
  LOG_LEVEL: process.env.LOG_LEVEL || 'info',
};

// 验证必需的环境变量
const requiredEnvVars = ['DATABASE_URL', 'JWT_SECRET'];
for (const envVar of requiredEnvVars) {
  if (!config[envVar as keyof EnvConfig]) {
    throw new Error(`Missing required environment variable: ${envVar}`);
  }
}

export default config;
