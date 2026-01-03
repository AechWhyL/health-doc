# 老年人健康档案管理平台 - 角色 → 页面 → 后端接口矩阵

本文件从「角色视角」梳理移动端主要页面，并映射到后端实际/规划中的接口，方便后续做前后端联调与权限设计。

> 说明：  
> - 接口路径优先以当前 `backend/src/routes` 与 `backend/src/controllers` 中已实现的为准  
> - 部分 RBAC 相关接口目前仅在文档中规划，尚未在代码中实现

---

## 一、通用页面（所有角色共享）

| 页面标识 | 页面名称 | 使用角色 | 主要功能 | 主要后端接口 | 实现状态 |
|----------|----------|----------|----------|--------------|----------|
| `pages/Login` | 登录页 | 老人 / 家属 / 医护 | 账号密码登录、获取当前登录用户及其角色 | `POST /api/v1/users/login`（用户登录）<br>`GET /api/v1/users/current`（获取当前用户信息）<br>`GET /api/v1/roles/users/{id}/roles`（获取用户角色列表） | 已实现（用户/角色接口已在代码中存在） |
| `pages/Register` | 注册页 | 老人 / 家属 / 医护 | 新用户注册并选择角色，后续引导补充基础信息 | `POST /api/v1/users`（创建用户）<br>`PUT /api/v1/roles/users/{id}/roles` 或等价接口（为用户分配角色，RBAC 文档中规划） | 用户接口已实现，角色分配为规划中 |

---

## 二、老人端（Elder）角色

老人端主要围绕「查看与维护自身健康档案、查看健康数据与用药信息」展开。

### 1. 老人档案总览与健康记录管理

> 对应当前已经实现的页面：原 `pages/Index`，后续将迁移为 `pages/elder/Index`

| 角色 | 页面标识 | 页面名称 | 主要功能 | 主要后端接口 | 实现状态 |
|------|----------|----------|----------|--------------|----------|
| 老人 | `pages/elder/Index` | 老人档案首页（个人信息 + 健康档案） | - 列出可访问的老人档案（通常是本人）<br>- 查看单个老人的详细基本信息<br>- 查看该老人的所有健康记录列表<br>- 新增 / 编辑 / 删除健康记录 | 老人基本信息：<br>`GET /api/v1/elder-health/elder/list`（分页查询老人列表）<br>`GET /api/v1/elder-health/elder/{id}`（获取老人详情）<br><br>健康记录：<br>`GET /api/v1/elder-health/elder/{elder_id}/health-records`（按老人查询所有记录）<br>`GET /api/v1/elder-health/health-record/{id}`（单条记录详情）<br>`GET /api/v1/elder-health/health-record/list`（分页+条件查询）<br>`POST /api/v1/elder-health/health-record`（创建健康记录）<br>`PUT /api/v1/elder-health/health-record/{id}`（更新健康记录）<br>`DELETE /api/v1/elder-health/health-record/{id}`（删除健康记录） | 已实现（controller 和 routes 已存在） |

### 2. 老人健康数据记录与趋势查看（规划为老人可视化入口）

| 角色 | 页面标识 | 页面名称 | 主要功能 | 主要后端接口 | 实现状态 |
|------|----------|----------|----------|--------------|----------|
| 老人 | `pages/elder/HealthDataDashboard` | 健康数据趋势面板 | - 查看血压/血糖/体重等健康数据的时间序列<br>- 根据时间范围筛选数据<br>- 查看统计指标或趋势分析 | 健康数据记录：<br>`POST /api/v1/health-data/records`（创建健康数据记录）<br>`GET /api/v1/health-data/records`（条件+分页查询记录）<br>`PUT /api/v1/health-data/records/{id}`（更新健康数据记录）<br>`DELETE /api/v1/health-data/records/{id}`（删除记录）<br>`GET /api/v1/health-data/records/stats`（趋势与统计分析） | 健康数据记录 controller 已实现；可视化页面待实现 |

### 3. 老人用药与干预计划（查看为主）

| 角色 | 页面标识 | 页面名称 | 主要功能 | 主要后端接口 | 实现状态 |
|------|----------|----------|----------|--------------|----------|
| 老人 | `pages/elder/MedicationPlan` | 用药记录与计划 | - 查看当前及历史用药记录<br>- 查看医护制定的用药计划 | 用药记录：<br>`POST /api/v1/elder-health/medication`（创建用药记录）<br>`GET /api/v1/elder-health/medication/{id}`（用药记录详情）<br>`GET /api/v1/elder-health/medication/list`（分页查询用药记录）<br>`GET /api/v1/elder-health/medication/elder/{elder_id}`（按老人查询用药记录）<br>`PUT /api/v1/elder-health/medication/{id}`（更新用药记录）<br>`DELETE /api/v1/elder-health/medication/{id}`（删除用药记录） | 后端用药模块已实现；老人端页面待实现 |

---

## 三、家属端（Family）角色

家属端主要关注「查看老人档案、掌握健康动态、配合干预与提醒」。

### 1. 家属首页与老人档案列表

| 角色 | 页面标识 | 页面名称 | 主要功能 | 主要后端接口 | 实现状态 |
|------|----------|----------|----------|--------------|----------|
| 家属 | `pages/family/Index` | 家属首页（关联老人列表） | - 展示当前家属账户下可查看的老人列表<br>- 支持按姓名/身份证号搜索<br>- 选择某位老人进入其档案详情 | 老人基本信息：<br>`GET /api/v1/elder-health/elder/list`（分页查询老人列表）<br>`GET /api/v1/elder-health/elder/{id}`（老人详情）<br><br>后续可结合 RBAC：通过用户角色/授权关系过滤可见老人 | 老人相关接口已实现；家属过滤逻辑需结合 RBAC 实现 |

### 2. 家属查看老人健康档案与健康数据

| 角色 | 页面标识 | 页面名称 | 主要功能 | 主要后端接口 | 实现状态 |
|------|----------|----------|----------|--------------|----------|
| 家属 | `pages/family/ElderDetail` | 老人档案详情（家属视角） | - 查看老人基本信息<br>- 查看健康记录列表与详情<br>- 查看健康数据趋势、用药记录 | 老人档案：<br>`GET /api/v1/elder-health/elder/{id}`<br>健康记录：<br>`GET /api/v1/elder-health/elder/{elder_id}/health-records`<br>`GET /api/v1/elder-health/health-record/{id}`<br>健康数据：<br>`GET /api/v1/health-data/records?elder_id={elder_id}`<br>`GET /api/v1/health-data/records/stats?elder_id={elder_id}`<br>用药记录：<br>`GET /api/v1/elder-health/medication/elder/{elder_id}` | 大部分接口已实现，按老人筛选的健康数据查询在 controller 中已支持 |

### 3. 家属提醒与风险提示（规划）

| 角色 | 页面标识 | 页面名称 | 主要功能 | 主要后端接口 | 实现状态 |
|------|----------|----------|----------|--------------|----------|
| 家属 | `pages/family/AlertCenter` | 健康提醒与风险提示 | - 查看系统自动生成的健康提醒（如血压持续偏高）<br>- 查看医护人员发布的随访/复查提醒 | 规划中接口（健康数据分析与提醒）：<br>可基于 `GET /api/v1/health-data/records/stats` 结果<br>扩展如：`GET /api/v1/health-alerts?elder_id=...`（风险提示列表） | 健康数据统计已实现，提醒类接口规划中 |

---

## 四、医护端（Medical）角色

医护端主要负责「诊断记录、干预计划制定与调整、健康数据录入与审核」。

### 1. 医护首页与老人管理

| 角色 | 页面标识 | 页面名称 | 主要功能 | 主要后端接口 | 实现状态 |
|------|----------|----------|----------|--------------|----------|
| 医护 | `pages/medical/Index` | 医护工作台首页 | - 按条件搜索老人档案<br>- 快速进入老人健康档案、健康数据与用药管理页面 | 老人档案：<br>`GET /api/v1/elder-health/elder/list`（分页+搜索）<br>`GET /api/v1/elder-health/elder/{id}`（详情） | 已实现 |

### 2. 健康记录与诊疗记录维护

| 角色 | 页面标识 | 页面名称 | 主要功能 | 主要后端接口 | 实现状态 |
|------|----------|----------|----------|--------------|----------|
| 医护 | `pages/medical/HealthRecordManage` | 健康记录管理 | - 查看指定老人所有健康记录<br>- 新增诊疗记录/病程记录<br>- 编辑 / 删除历史记录<br>- 按日期/分类筛选记录 | 健康记录：<br>`GET /api/v1/elder-health/health-record/list`（分页+条件）<br>`GET /api/v1/elder-health/elder/{elder_id}/health-records`（按老人）<br>`POST /api/v1/elder-health/health-record`（创建）<br>`PUT /api/v1/elder-health/health-record/{id}`（更新）<br>`DELETE /api/v1/elder-health/health-record/{id}`（删除） | 已实现 |

### 3. 健康数据录入与分析

| 角色 | 页面标识 | 页面名称 | 主要功能 | 主要后端接口 | 实现状态 |
|------|----------|----------|----------|--------------|----------|
| 医护 | `pages/medical/HealthDataInput` | 健康指标录入与分析 | - 为老人录入血压/血糖等健康数据<br>- 查看指定老人某一指标的趋势与统计<br>- 根据分析结果给出干预建议 | 健康数据记录：<br>`POST /api/v1/health-data/records`（创建）<br>`GET /api/v1/health-data/records`（条件+分页查询）<br>`PUT /api/v1/health-data/records/{id}`（更新）<br>`DELETE /api/v1/health-data/records/{id}`（删除）<br>`GET /api/v1/health-data/records/stats`（统计分析） | 已实现（controller/service 已存在），前端页面待实现 |

### 4. 干预与用药计划管理

| 角色 | 页面标识 | 页面名称 | 主要功能 | 主要后端接口 | 实现状态 |
|------|----------|----------|----------|--------------|----------|
| 医护 | `pages/medical/MedicationPlanManage` | 用药计划与执行情况管理 | - 制定/调整老人的用药计划<br>- 查看实际用药执行记录 | 用药记录：<br>`POST /api/v1/elder-health/medication`（新增用药记录/计划）<br>`GET /api/v1/elder-health/medication/elder/{elder_id}`（按老人查看）<br>`PUT /api/v1/elder-health/medication/{id}`（更新）<br>`DELETE /api/v1/elder-health/medication/{id}`（删除） | 已实现，用药计划视图待实现 |

---

## 五、权限与角色绑定相关接口（横切关注点）

这些接口不直接对应某一个具体页面，而是作为所有需要「按角色控制访问」页面的基础能力。

| 功能场景 | 主要接口 | 说明 | 实现状态 |
|----------|----------|------|----------|
| 注册时为新用户分配角色 | `PUT /api/v1/roles/users/{id}/roles` 或等价实现 | 注册成功后根据「老人 / 家属 / 医护」选择，将对应角色写入用户角色关联表 | 角色相关 routes/controller 已存在，具体分配策略需结合 RBAC 文档实现 |
| 登录后根据角色跳转不同首页 | `GET /api/v1/users/current` + `GET /api/v1/roles/users/{id}/roles` | 前端登录成功后获取当前用户及其角色，按照角色决定跳转到 `pages/elder/Index` / `pages/family/Index` / `pages/medical/Index` | 用户/角色基础接口已实现；根据角色选择首页逻辑待实现 |
| 页面访问权限控制（前端） | 依赖用户角色信息 | 前端根据当前用户角色控制菜单展示、页面访问权限 | 前端逻辑待实现 |
| API 访问权限控制（后端） | `authMiddleware` + RBAC 权限检查接口（文档在 `RBAC功能需求文档.md` 中定义） | 后端在敏感接口前增加权限校验，如仅医护角色可写入健康记录、用药记录 | 部分认证中间件已实现，细粒度权限控制按 RBAC 文档规划 |

---

## 六、后续扩展建议

- 在实现新的页面时，优先从本矩阵中选择对应后端接口，避免重复造轮子  
- 若新增接口，请同步更新本文件以及对应模块下的需求文档，保持「角色 → 页面 → 接口」的一致性  
- 建议后续在前端实现基于角色的「首页路由策略」与「菜单配置」，与本矩阵保持一一对应关系

