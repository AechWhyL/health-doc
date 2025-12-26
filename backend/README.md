# Health Document Backend

健康文档管理系统后端

## 环境配置

### 1. 创建环境变量文件

复制示例配置文件并根据需要修改：

```bash
# 从示例文件创建配置文件
cp src/config/env-config-example.ts src/config/env.ts
```

或者创建 `.env` 文件（推荐用于本地开发）：

```bash
# 创建环境变量文件
cp .env.example .env
```

### 2. 配置环境变量

#### 服务器配置
```env
NODE_ENV=development
PORT=3000
```

#### Database Configuration (MySQL)
```env
# Format: mysql://username:password@host:port/database
DATABASE_URL=mysql://root:password@localhost:3306/health_doc_db
```

#### JWT Configuration
```env
# JWT Secret - Use a strong secret key in production
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
# Token expiration time
JWT_EXPIRES_IN=7d
```

#### Redis Configuration (Optional, for caching)
```env
REDIS_URL=redis://localhost:6379
```

#### Logging Configuration
```env
# Log levels: error, warn, info, debug
LOG_LEVEL=info
```

### 3. 环境变量验证

应用启动时会自动验证必需的环境变量：
- `DATABASE_URL` - 数据库连接字符串
- `JWT_SECRET` - JWT签名密钥

缺少任何必需变量将导致应用启动失败。

## 开发环境设置

### 安装依赖
```bash
pnpm install
```

### 数据库初始化
```bash
# 生成 Prisma 客户端
npx prisma generate

# 运行数据库迁移
npx prisma db push
```

### 启动开发服务器
```bash
pnpm run dev
```

### 构建生产版本
```bash
pnpm run build
pnpm start
```

## 可用脚本

- `pnpm run dev` - 启动开发服务器 (支持热重载)
- `pnpm run build` - 编译 TypeScript
- `pnpm start` - 启动生产服务器
- `pnpm test` - 运行测试
- `pnpm run lint` - 代码检查
- `pnpm run format` - 代码格式化

## 项目结构

```
src/
├── config/          # 配置文件
├── controllers/     # 控制器
├── models/          # 数据模型
├── routes/          # 路由定义
├── middleware/      # 中间件
├── services/        # 业务逻辑
├── utils/           # 工具函数
├── types/           # TypeScript类型定义
└── app.ts          # 应用入口
```
