---
alwaysApply: false
description: 
---
## 后端返回数据统一格式规范 (Backend Response Data Format Standards)

### 统一响应格式 (Unified Response Format)
所有后端API接口必须遵循统一的响应数据格式，包含以下字段：

#### 标准响应结构 (Standard Response Structure)
```json
{
  "code": number,        // 状态码：200表示成功，其他表示错误
  "message": string,     // 响应消息
  "data": object|null,   // 响应数据，成功时返回数据对象，失败时为null
  "timestamp": string    // 可选：响应时间戳，格式为ISO 8601字符串
}
```

### 成功响应格式 (Success Response Format)
```json
{
  "code": 200,
  "message": "success",
  "data": {
    // 具体业务数据，根据接口需求返回相应的数据结构
    // 分页数据时包含：total, pages, current, size, records等字段
  }
}
```

#### 分页数据示例 (Pagination Data Example)
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 5,          // 总记录数
    "pages": 1,          // 总页数
    "current": 1,        // 当前页码
    "size": 20,          // 每页大小
    "records": []        // 数据记录数组
  }
}
```

### 错误响应格式 (Error Response Format)
```json
{
  "code": number,       // 错误状态码，如：400, 401, 403, 404, 500等
  "message": string,    // 错误描述信息
  "data": null,         // 错误时data字段必须为null
  "timestamp": string   // 错误发生时间戳
}
```

### 实现要求 (Implementation Requirements)
1. **统一性**: 所有API接口必须严格遵循此格式
2. **状态码规范**: 使用HTTP标准状态码，业务错误使用4xx，系统错误使用5xx
3. **消息国际化**: message字段支持多语言，根据请求头Accept-Language返回相应语言
4. **时间戳格式**: timestamp字段使用ISO 8601格式，如："2024-01-01T00:00:00Z"
5. **数据类型**: 确保data字段的数据类型与接口文档一致
6. **错误处理**: 异常情况下也要返回统一格式，不得返回未经处理的错误信息

---

## 后端API代码编写规范 (Backend API Code Standards)

### 分层架构规范 (Layered Architecture Standards)

#### 分层原则 (Layering Principles)
严格遵循分层解耦的架构设计，每一层只负责自己的职责，禁止跨层调用：

1. **控制器层 (Controller Layer)** - `backend/src/controllers/`
   - 职责：接收HTTP请求，参数验证，调用服务层，返回响应
   - 禁止：直接操作数据库、编写业务逻辑、直接返回数据库查询结果
   - 规范：
     - 每个控制器类只负责一个业务模块
     - 使用依赖注入获取服务层实例
     - 只处理请求/响应的转换，不包含业务逻辑
     - 统一异常处理和日志记录

2. **服务层 (Service Layer)** - `backend/src/services/`
   - 职责：实现业务逻辑，事务管理，调用数据访问层
   - 禁止：直接处理HTTP请求、直接返回数据库查询结果
   - 规范：
     - 每个服务类只负责一个业务领域
     - 方法命名清晰表达业务意图（如：createOrder, processPayment）
     - 复杂业务逻辑必须封装在服务层
     - 使用事务保证数据一致性

3. **数据访问层 (Repository/Model Layer)** - `backend/src/repositories/` 或 `backend/src/models/`
   - 职责：数据库操作，数据查询，数据持久化
   - 禁止：包含业务逻辑、直接返回HTTP响应
   - 规范：
     - 每个Repository类只负责一个数据表的操作
     - 提供基础的CRUD方法
     - 复杂查询封装在Repository层
     - 使用参数化查询防止SQL注入

4. **DTO层 (Data Transfer Object)** - `backend/src/dto/`
   - 职责：定义请求和响应的数据结构
   - 规范：
     - 每个DTO类对应一个API接口的请求或响应
     - 使用TypeScript接口或类定义
     - 包含数据验证规则
     - 区分Request DTO和Response DTO

#### 目录结构示例 (Directory Structure Example)
```
backend/src/
├── controllers/          # 控制器层
│   └── userController.ts
├── services/            # 服务层
│   └── userService.ts
├── repositories/        # 数据访问层
│   └── userRepository.ts
├── dto/                 # 数据传输对象
│   ├── requests/        # 请求DTO
│   │   └── createUser.dto.ts
│   └── responses/       # 响应DTO
│       └── userResponse.dto.ts
└── types/               # 类型定义
    └── user.ts
```

### TypeScript类型安全规范 (TypeScript Type Safety Standards)

#### 事务规范
当业务逻辑设计多个数据库操作时，必须使用事务确保数据一致性。

#### 类型定义规范 (Type Definition Standards)
1. **严格类型检查**
   - 启用 `strict: true` 在 tsconfig.json
   - 禁止使用 `any` 类型，使用 `unknown` 代替
   - 所有函数参数和返回值必须明确类型
   - 使用类型断言时必须进行类型守卫

2. **接口定义规范**
   ```typescript
   // 好的做法
   interface CreateUserRequest {
     name: string;
     email: string;
     age?: number;  // 可选属性
   }

   // 避免的做法
   interface User {
     [key: string]: any;  // 避免使用索引签名
   }
   ```

3. **泛型使用规范**
   - 合理使用泛型提高代码复用性
   - 泛型参数命名使用大写字母（T, U, V等）
   - 为泛型添加约束

4. **类型守卫和断言**
   ```typescript
   // 类型守卫
   function isString(value: unknown): value is string {
     return typeof value === 'string';
   }

   // 类型断言
   const user = response.data as User;
   ```

#### 禁止事项 (Prohibited Practices)
- 禁止使用 `@ts-ignore` 和 `@ts-nocheck`
- 禁止使用 `any` 类型（除非特殊场景并有注释说明）
- 禁止隐式 `any` 类型
- 禁止类型断言后不进行类型检查

### DTO数据类型规范 (DTO Data Type Standards)

#### DTO设计原则 (DTO Design Principles)
1. **请求DTO (Request DTO)**
   - 定义API接收的请求数据结构
   - 包含数据验证规则
   - 使用装饰器或类验证器进行验证
   - 示例：
   ```typescript
   export interface CreateElderRequest {
     name: string;
     gender: number;
     birth_date: string;
     phone: string;
     id_card: string;
     emergency_contact: string;
     address?: string;
     height?: number;
     weight?: number;
     blood_type?: string;
   }
   ```

2. **响应DTO (Response DTO)**
   - 定义API返回的响应数据结构
   - 不应暴露敏感信息（如密码、token等）
   - 可以包含计算字段或格式化后的数据
   - 示例：
   ```typescript
   export interface ElderResponse {
     id: number;
     name: string;
     gender: number;
     age: number;  // 计算字段
     phone: string;
     // 不包含敏感信息
   }
   ```

3. **查询DTO (Query DTO)**
   - 定义查询参数的数据结构
   - 包含分页参数
   - 包含筛选和排序参数
   - 示例：
   ```typescript
   export interface QueryElderRequest {
     page: number;
     pageSize: number;
     name?: string;
     id_card?: string;
     orderBy?: string;
   }
   ```

#### DTO验证规范 (DTO Validation Standards)
- 所有DTO必须包含验证规则
- 使用验证库（如 class-validator, yup 等）
- 验证规则包括：必填、类型、格式、长度、范围等
- 验证失败时返回清晰的错误信息

### API文档规范 (API Documentation Standards)

#### Swagger/OpenAPI规范 (Swagger/OpenAPI Standards)
1. **文档完整性**
   - 每个API接口必须包含完整的Swagger文档
   - 文档必须包含：描述、参数、响应、示例
   - 使用中文编写文档说明

2. **文档注解规范**
   ```typescript
   /**
    * @swagger
    * /api/v1/elder-health/elder:
    *   post:
    *     summary: 创建老人基本信息
    *     description: 创建新的老人基本信息记录
    *     tags: [老人健康档案]
    *     requestBody:
    *       required: true
    *       content:
    *         application/json:
    *           schema:
    *             $ref: '#/components/schemas/CreateElderRequest'
    *     responses:
    *       200:
    *         description: 创建成功
    *         content:
    *           application/json:
    *             schema:
    *               $ref: '#/components/schemas/ElderResponse'
    *       400:
    *         description: 请求参数错误
    */
   ```

3. **文档维护**
   - API变更时必须同步更新文档
   - 定期检查文档与实际代码的一致性
   - 废弃的API必须标注为deprecated

#### 文档内容要求 (Documentation Content Requirements)
- 接口描述清晰，说明接口用途
- 参数说明完整，包括类型、是否必填、示例值
- 响应示例真实可运行
- 错误码说明详细
- 包含业务场景说明

### 代码命名规范 (Code Naming Standards)

#### 通用命名规则 (General Naming Rules)
1. **文件命名**
   - 使用小驼峰命名法：`userController.ts`
   - 组件文件使用大驼峰：`UserService.ts`
   - 测试文件添加 `.test.ts` 或 `.spec.ts` 后缀

2. **变量和函数命名**
   - 使用小驼峰命名法：`userName`, `getUserById`
   - 布尔值使用 `is`, `has`, `should` 前缀：`isActive`, `hasPermission`
   - 私有变量使用 `_` 前缀：`_privateField`

3. **类和接口命名**
   - 使用大驼峰命名法：`UserService`, `IUserRepository`
   - 接口可以使用 `I` 前缀（可选）
   - 类型别名使用大驼峰：`UserType`, `ResponseData`

4. **常量命名**
   - 使用全大写下划线分隔：`MAX_RETRY_COUNT`, `API_BASE_URL`
   - 常量必须使用 `const` 声明

### 错误处理规范 (Error Handling Standards)

#### 错误分类 (Error Classification)
1. **业务错误 (Business Errors)**
   - 使用自定义错误类
   - 错误码范围：4000-4999
   - 示例：`ValidationError`, `NotFoundError`

2. **系统错误 (System Errors)**
   - 使用系统错误类
   - 错误码范围：5000-5999
   - 示例：`DatabaseError`, `ExternalServiceError`

#### 错误处理原则 (Error Handling Principles)
- 所有异步操作必须包含错误处理
- 错误信息不应暴露系统内部细节
- 记录完整的错误日志（堆栈信息）
- 向客户端返回友好的错误信息
- 使用全局错误处理器统一处理异常

### 日志规范 (Logging Standards)

#### 日志级别 (Log Levels)
- **ERROR**: 系统错误、异常情况
- **WARN**: 警告信息、潜在问题
- **INFO**: 关键业务操作、重要状态变更
- **DEBUG**: 调试信息、详细执行流程

#### 日志内容规范 (Log Content Standards)
- 记录关键业务操作（如：创建订单、支付成功）
- 记录异常信息（包含堆栈）
- 记录接口请求和响应（生产环境可关闭）
- 使用结构化日志格式（JSON）

### 安全规范 (Security Standards)

#### 输入验证 (Input Validation)
- 所有用户输入必须验证
- 验证数据类型、格式、长度、范围
- 使用白名单验证，避免黑名单



