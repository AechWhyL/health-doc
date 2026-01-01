# 网络请求封装

本目录包含项目的网络请求封装代码，基于鸿蒙原生的`ohos.net.http`模块实现，提供了类型安全、易用的网络请求接口。

## 目录结构

```
api/
├── HttpUtil.ets       # 基础网络请求工具类
├── ApiService.ets     # 业务API服务封装
└── README.md          # 说明文档
```

## 核心功能

### HttpUtil.ets

- **单例模式**：确保全局只有一个HttpUtil实例
- **类型安全**：完整的TypeScript类型定义
- **请求方法支持**：GET、POST、PUT、DELETE、PATCH
- **请求配置**：支持自定义请求头、超时时间、重试次数
- **响应处理**：统一的响应格式和错误处理
- **重试机制**：可配置的请求重试
- **资源管理**：自动销毁HTTP实例，释放资源

### ApiService.ets

- **业务API封装**：所有业务相关的API请求统一管理
- **认证处理**：自动处理登录令牌的添加和移除
- **数据类型定义**：完整的业务数据类型接口
- **统一响应格式**：标准化的API响应处理

## 使用示例

### 初始化

在应用启动时初始化ApiService：

```typescript
// EntryAbility.ets
import apiService from '../common/api/ApiService';

// 在onCreate方法中初始化
onCreate(want, launchParam) {
  // ApiService会在实例化时自动初始化HttpUtil
}
```

### 在页面中使用

```typescript
// Index.ets
import apiService, { HealthData } from '../common/api/ApiService';

@Entry
@Component
struct Index {
  @State healthDataList: HealthData[] = [];
  @State loading: boolean = false;
  @State error: string = '';

  async aboutToAppear() {
    await this.loadHealthData();
  }

  async loadHealthData() {
    this.loading = true;
    this.error = '';
    
    try {
      const response = await apiService.getHealthDataList();
      this.healthDataList = response.data.list;
    } catch (e) {
      this.error = e instanceof Error ? e.message : '加载失败';
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column({
      space: 16
    }) {
      if (this.loading) {
        Text('加载中...')
          .fontSize(20)
      } else if (this.error) {
        Text(this.error)
          .fontSize(20)
          .fontColor(Color.Red)
      } else {
        List() {
          ForEach(this.healthDataList, (item) => {
            ListItem() {
              Text(`${item.type}: ${item.value} ${item.unit}`)
                .fontSize(18)
                .padding(16)
            }
          })
        }
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
```

## 配置说明

### 权限配置

在`module.json5`中已配置了网络权限：

```json5
"requestPermissions": [
  {
    "name": "ohos.permission.INTERNET",
    "reason": "用于网络请求",
    "usedScene": {
      "ability": ["EntryAbility"],
      "when": "inuse"
    }
  }
]
```

### 基础URL配置

在`ApiService.ets`中可以修改基础URL：

```typescript
HttpUtil.setBaseUrl('http://localhost:3000/api');
```

### 默认请求头配置

可以在`ApiService.ets`中添加或修改默认请求头：

```typescript
HttpUtil.setDefaultHeaders({
  'App-Version': '1.0.0',
  'Platform': 'HarmonyOS'
});
```

## 错误处理

所有网络请求都可能抛出错误，建议在使用时添加try-catch块处理：

```typescript
try {
  const response = await apiService.someApi();
  // 处理成功响应
} catch (error) {
  // 处理错误
  console.error('API请求失败:', error);
}
```

## 类型定义

### 请求配置

```typescript
interface HttpRequestConfig {
  method?: RequestMethod;      // 请求方法
  headers?: Record<string, string>;  // 请求头
  data?: any;                  // 请求数据
  timeout?: number;            // 超时时间（毫秒）
  retryCount?: number;         // 重试次数
}
```

### 响应格式

```typescript
interface HttpResponse<T> {
  data: T;                    // 响应数据
  statusCode: number;         // 状态码
  headers: Record<string, string>;  // 响应头
}
```

### API响应格式

```typescript
interface ApiResponse<T> {
  code: number;               // 业务状态码
  message: string;            // 提示信息
  data: T;                    // 业务数据
}
```

## 最佳实践

1. **统一管理API**：所有API请求都通过ApiService进行，不要直接使用HttpUtil
2. **合理设置超时**：根据业务需求设置合适的超时时间
3. **添加错误处理**：所有网络请求都需要添加try-catch块
4. **使用类型定义**：充分利用TypeScript的类型系统，确保类型安全
5. **资源管理**：不要手动创建Http实例，使用封装好的方法
6. **权限检查**：确保已配置必要的网络权限

## 注意事项

1. 每次请求都会创建新的Http实例，并在请求完成后销毁
2. 对于频繁的请求，建议使用缓存机制减少网络请求
3. 对于大文件上传下载，建议使用专门的文件传输API
4. 确保在`module.json5`中配置了网络权限
5. 在开发环境中，需要确保设备可以访问到API服务器
