# 项目规则索引 (Project Rules Index)

本文件作为项目所有Cursor Rules的中心索引和路由器，定义了项目的整体规范和各专项规则的分类指引。

## 核心原则 (Core Principles)

### 任务管理 (Task Management)
- **任务规划**: 每开始一个开发任务前，必须使用todo工具规划详细的任务清单
- **状态跟踪**: 实时更新任务状态，确保任务完成度透明化
- **复杂度评估**: 对于复杂任务（3+步骤），必须创建完整的todo list

### 代码规范 (Code Standards)
- **技术栈遵循**: 所有代码编写必须严格遵循 `rules/tech.mdc` 中定义的项目技术栈规范
- **质量保证**: 编写代码后必须进行必要的linting检查和修复
- **文档同步**: 代码变更时及时更新相关文档

### 项目结构 (Project Structure)
- **文件组织**: 遵循项目约定的目录结构和文件命名规范
- **模块化设计**: 保持代码的模块化和可维护性

#### 目录结构规范 (Directory Structure Standards)
- **后端目录**: 项目的后端部分存放于项目根目录的 `backend` 文件夹中
  - 路径: `c:\Users\29339\projects\health-doc\backend`
  - 包含所有后端相关代码、配置和依赖
- **前端目录**: 项目的移动应用前端使用鸿蒙ArkTS开发，相关代码存放于项目根目录的 `frontend` 文件夹中
  - 路径: `c:\Users\29339\projects\health-doc\frontend`
- **文档目录**: 项目文档存放于 `ai-docs` 文件夹中
  - 路径: `c:\Users\29339\projects\health-doc\ai-docs`

## 专项规则指引 (Specialized Rules Guide)

### 技术规范 (Technical Specifications)
- **路径**: `rules/tech.mdc`
- **内容**: 项目技术栈、框架版本、开发工具配置
- **适用范围**: 所有代码编写和架构设计任务

### 代码风格 (Code Style)
- **路径**: `rules/style.mdc`
- **内容**: 代码格式化、命名约定、注释规范
- **适用范围**: 所有代码文件

### 文档规范 (Documentation Standards)
- **路径**: `rules/docs.mdc`
- **内容**: README编写、API文档、代码注释规范
- **适用范围**: 文档编写和维护任务

### 测试规范 (Testing Standards)
- **路径**: `rules/testing.mdc`
- **内容**: 单元测试、集成测试、测试覆盖率要求
- **适用范围**: 测试代码编写和测试相关任务

### ai生成的项目文档
- **路径**: `ai-docs/`
- **内容**: 项目的AI生成文档，包括但不限于项目架构、功能介绍、使用说明等
- **适用范围**: 所有项目成员

## 工作流程 (Workflow)

### 任务开始前 (Before Starting Tasks)
1. 分析任务复杂度
2. 创建详细的todo list（如果任务足够复杂）
3. 确认所需的技术规范

### 任务执行中 (During Task Execution)
1. 遵循相应的专项规则
2. 保持代码质量标准
3. 及时更新任务状态

### 任务完成后 (After Task Completion)
1. 进行必要的代码检查
2. 更新相关文档
3. 验证任务完成度

## 规则优先级 (Rule Priority)

1. **安全规则**: 最高优先级，涉及代码安全、数据保护等
2. **核心规范**: 技术栈规范、代码质量标准
3. **专项规则**: 各模块的具体实施细则
4. **风格偏好**: 最低优先级，可根据实际情况调整

## 更新维护 (Maintenance)

- 本索引文件应随着项目发展和规则完善而及时更新
- 新增专项规则时，必须在本文件中添加相应条目
- 定期review现有规则的有效性和适用性