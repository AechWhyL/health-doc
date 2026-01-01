---
alwaysApply: false
description: 
---
# 技术栈规范 (Technical Stack Standards)

## 前端工程技术栈 (Frontend Technical Stack)

### 已确认技术栈 (Confirmed Technologies)

| 分类 | 技术 | 说明 |
|------|------|------|
| 平台 | 鸿蒙 (HarmonyOS) | 分布式操作系统 |
| 语言 | ArkTS | 鸿蒙生态专用开发语言 |
| UI框架 | ArkUI | 鸿蒙原生UI框架 |
| 开发工具 | DevEco Studio | 鸿蒙应用开发IDE |

## 后端工程技术栈 (Backend Technical Stack)

### 已确认技术栈 (Confirmed Technologies)

| 分类 | 技术 | 说明 |
|------|------|------|
| 运行时 | Node.js | JavaScript 运行环境 |
| 包管理工具 | pnpm | 快速、节省空间的包管理工具 |
| 语言 | TypeScript | TypeScript 编程语言 |
| REST框架 | Koa.js | Web 框架 |
| 数据库 | MySQL | 关系型数据库 |
| 测试框架 | Vitest | 单元测试框架 |
| ORM框架 | Prisma | 类型安全的 ORM，支持数据库迁移 |
| API文档 | swagger-jsdoc | OpenAPI 规范生成 |
| API文档 | swagger-ui-koa | Swagger UI for Koa |
| 身份验证 | jsonwebtoken | JWT token 生成与验证 |
| 身份验证 | bcryptjs | 密码加密 |
| 身份验证 | koa-jwt | Koa JWT 中间件 |
| 数据验证 | joi | 对象模式验证 |

### 推荐技术栈清单 (Recommended Technology Stack)

#### 1. 数据访问层 (Data Access Layer)
| 技术 | 说明 |
|------|------|
| mysql2 | MySQL 数据库驱动 |

#### 2. 身份验证与授权 (Authentication & Authorization)
| 技术 | 说明 |
|------|------|
| (已确认使用 JWT 方案) | - |

#### 3. 数据验证 (Data Validation)
| 技术 | 说明 |
|------|------|
| Yup | 与React表单库深度集成 |
| Zod | TypeScript原生类型安全验证 |
| express-validator | Express专用验证中间件 |
| validator.js | 字符串验证工具库 |

#### 4. 中间件 (Middleware)
| 技术 | 说明 |
|------|------|
| koa-bodyparser | 请求体解析 |
| koa-router | 路由管理 |
| koa-cors | 跨域资源共享 |
| koa-helmet | 安全头设置 |
| koa-logger | 请求日志 |

#### 5. 配置管理 (Configuration)
| 技术 | 说明 |
|------|------|
| dotenv | 环境变量管理 |

#### 6. 日志系统 (Logging)
| 技术 | 说明 |
|------|------|
| winston | 多级别日志记录 |

#### 7. 缓存系统 (Caching)
| 技术 | 说明 |
|------|------|
| redis | Redis 客户端 |
| node-cache | 内存缓存 |

#### 8. API 文档 (API Documentation)
| 技术 | 说明 |
|------|------|
| (已确认使用 Swagger 方案) | - |

#### 9. 开发工具 (Development Tools)
| 技术 | 说明 |
|------|------|
| typescript | TypeScript 编译器 |
| ts-node | TypeScript 运行时 |
| nodemon | 开发时自动重启 |
| concurrently | 并行运行多个脚本 |
| eslint | 代码质量检查 |
| prettier | 代码格式化 |

#### 10. 部署与容器化 (Deployment & Containerization)
| 技术 | 说明 |
|------|------|
| Docker | 容器化部署 |
| PM2 | Node.js 进程管理 |
| docker-compose | 多容器编排 |

### 技术栈决策标准 (Technology Selection Criteria)

1. **成熟度**: 优先选择社区活跃、维护良好的库
2. **类型安全**: 优先选择提供 TypeScript 支持的库
3. **性能**: 考虑运行时性能和开发体验
4. **生态系统**: 选择与现有技术栈兼容性好的方案
5. **学习曲线**: 考虑团队的学习成本

### 技术栈演进 (Technology Evolution)
- 若需要新增技术栈或者库依赖时，务必优先选择仍在活跃维护的方案
- 每季度review技术栈使用情况
- 根据项目需求和新技术发展调整技术栈
- 保持技术栈的现代化和最佳实践