import http from '@ohos.net.http';

// 定义请求方法类型
export type RequestMethod = 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';

// 定义请求头类
export class HttpHeaders {
  private headers: Array<HeaderEntry> = [];
  
  /**
   * 设置请求头
   * @param key 键名
   * @param value 键值
   */
  set(key: string, value: string): void {
    // 检查是否已存在该key，如果存在则更新，否则添加新项
    for (let i = 0; i < this.headers.length; i++) {
      if (this.headers[i].key === key) {
        this.headers[i].value = value;
        return;
      }
    }
    // 添加新的请求头
    this.headers.push(new HeaderEntry(key, value));
  }
  
  /**
   * 获取请求头
   * @param key 键名
   * @returns 键值
   */
  get(key: string): string | undefined {
    for (let i = 0; i < this.headers.length; i++) {
      if (this.headers[i].key === key) {
        return this.headers[i].value;
      }
    }
    return undefined;
  }
  
  /**
   * 检查是否存在指定请求头
   * @param key 键名
   * @returns 是否存在
   */
  has(key: string): boolean {
    for (let i = 0; i < this.headers.length; i++) {
      if (this.headers[i].key === key) {
        return true;
      }
    }
    return false;
  }
  
  /**
   * 删除指定请求头
   * @param key 键名
   * @returns 是否删除成功
   */
  delete(key: string): boolean {
    for (let i = 0; i < this.headers.length; i++) {
      if (this.headers[i].key === key) {
        this.headers.splice(i, 1);
        return true;
      }
    }
    return false;
  }
  
  /**
   * 获取所有请求头
   * @returns 所有请求头的键值对数组
   */
  entries(): Array<[string, string]> {
    const result: Array<[string, string]> = [];
    for (let i = 0; i < this.headers.length; i++) {
      result.push([this.headers[i].key, this.headers[i].value]);
    }
    return result;
  }
  
  /**
   * 清空所有请求头
   */
  clear(): void {
    this.headers = [];
  }
  
  /**
   * 转换为适合传递给http.request的对象格式
   * @returns 请求头对象
   */
  toObject(): HeaderObject {
    const result: HeaderObject = new HeaderObject();
    for (let i = 0; i < this.headers.length; i++) {
      const entry = this.headers[i];
      result.addProperty(entry.key, entry.value);
    }
    return result;
  }
}

// 请求头条目类
class HeaderEntry {
  public key: string;
  public value: string;
  
  constructor(key: string, value: string) {
    this.key = key;
    this.value = value;
  }
}

// 请求头对象类
class HeaderObject {
  private properties: Array<HeaderEntry> = [];
  
  /**
   * 添加属性
   * @param key 属性名
   * @param value 属性值
   */
  addProperty(key: string, value: string): void {
    // 检查是否已存在该key，如果存在则更新，否则添加新项
    for (let i = 0; i < this.properties.length; i++) {
      if (this.properties[i].key === key) {
        this.properties[i].value = value;
        return;
      }
    }
    // 添加新属性
    this.properties.push(new HeaderEntry(key, value));
  }
  
  /**
   * 获取属性
   * @param key 属性名
   * @returns 属性值
   */
  getProperty(key: string): string | undefined {
    for (let i = 0; i < this.properties.length; i++) {
      if (this.properties[i].key === key) {
        return this.properties[i].value;
      }
    }
    return undefined;
  }
}

// 定义请求配置接口
export interface HttpRequestConfig {
  method?: RequestMethod;
  headers?: HttpHeaders;
  data?: Object;
  timeout?: number;
  retryCount?: number;
}

// 定义GET请求配置接口（不包含method）
export interface GetRequestConfig {
  headers?: HttpHeaders;
  timeout?: number;
  retryCount?: number;
}

// 定义带data的请求配置接口（不包含method）
export interface DataRequestConfig {
  headers?: HttpHeaders;
  data?: Object;
  timeout?: number;
  retryCount?: number;
}

// 定义响应数据接口
export interface HttpResponse<T> {
  data: T;
  statusCode: number;
  headers: HttpHeaders;
}

// 定义错误信息接口
export interface HttpError {
  message: string;
  statusCode?: number;
  data?: Object;
}

/**
 * 网络请求工具类
 * 封装鸿蒙原生http请求，提供便捷的GET、POST等方法
 */
class HttpUtil {
  private static instance: HttpUtil = new HttpUtil();
  private baseUrl: string = '';
  private defaultHeaders: HttpHeaders = new HttpHeaders();
  
  private constructor() {
    // 设置默认Content-Type
    this.defaultHeaders.set('Content-Type', 'application/json');
  }

  /**
   * 获取单例实例
   */
  static getInstance(): HttpUtil {
    return HttpUtil.instance;
  }

  /**
   * 设置基础URL
   * @param url 基础URL
   */
  setBaseUrl(url: string): void {
    this.baseUrl = url;
  }

  /**
   * 设置默认请求头
   * @param headers 默认请求头
   */
  setDefaultHeaders(headers: HttpHeaders): void {
    // 合并请求头
    const entries = headers.entries();
    for (let i = 0; i < entries.length; i++) {
      const entry = entries[i];
      const key = entry[0];
      const value = entry[1];
      this.defaultHeaders.set(key, value);
    }
  }

  /**
   * 添加单个默认请求头
   * @param key 头名称
   * @param value 头值
   */
  addDefaultHeader(key: string, value: string): void {
    this.defaultHeaders.set(key, value);
  }

  /**
   * 移除默认请求头
   * @param key 头名称
   */
  removeDefaultHeader(key: string): void {
    this.defaultHeaders.delete(key);
  }

  /**
   * 通用请求方法
   * @param url 请求URL
   * @param config 请求配置
   */
  async request<T extends Object>(url: string, config?: HttpRequestConfig): Promise<HttpResponse<T>> {
    // 构建完整URL
    const fullUrl = this.baseUrl + url;
    
    // 合并请求头
    const headers: HttpHeaders = new HttpHeaders();
    
    // 先复制默认请求头
    const defaultEntries = this.defaultHeaders.entries();
    for (let i = 0; i < defaultEntries.length; i++) {
      const entry = defaultEntries[i];
      const key = entry[0];
      const value = entry[1];
      headers.set(key, value);
    }
    
    // 再复制自定义请求头（覆盖默认值）
    if (config?.headers) {
      const customEntries = config.headers.entries();
      for (let i = 0; i < customEntries.length; i++) {
        const entry = customEntries[i];
        const key = entry[0];
        const value = entry[1];
        headers.set(key, value);
      }
    }

    // 转换请求方法
    let httpMethod: http.RequestMethod;
    const method = config && config.method ? config.method : 'GET';
    switch (method) {
      case 'GET':
        httpMethod = http.RequestMethod.GET;
        break;
      case 'POST':
        httpMethod = http.RequestMethod.POST;
        break;
      case 'PUT':
        httpMethod = http.RequestMethod.PUT;
        break;
      case 'DELETE':
        httpMethod = http.RequestMethod.DELETE;
        break;
        break;
      default:
        httpMethod = http.RequestMethod.GET;
    }

    // 构建请求选项
    const requestOptions: http.HttpRequestOptions = {
      method: httpMethod,
      header: headers.toObject(),
      connectTimeout: (config && config.timeout) ? config.timeout : 60000,
      readTimeout: (config && config.timeout) ? config.timeout : 60000
    };

    // 添加请求数据
    if (config && config.data) {
      requestOptions.extraData = JSON.stringify(config.data);
    }

    // 获取重试次数
    const retryCount = (config && config.retryCount) ? config.retryCount : 0;

    // 创建HTTP实例
    const httpRequest = http.createHttp();

    try {
      // 执行请求（带重试机制）
      for (let i = 0; i <= retryCount; i++) {
        try {
          const response = await httpRequest.request(fullUrl, requestOptions);
          
          // 处理响应
          const responseData: HttpResponse<T> = {
            data: this.parseResponseData(response.result as string) as T,
            statusCode: response.responseCode,
            headers: this.convertToHttpHeaders(response.header as Object)
          };

          // 检查响应状态码
          if (response.responseCode >= 200 && response.responseCode < 300) {
            return responseData;
          } else {
            // 最后一次重试失败，抛出错误
            if (i === retryCount) {
              throw new Error(this.createHttpError(
                `HTTP request failed with status: ${response.responseCode}`,
                response.responseCode,
                responseData.data
              ).message);
            }
            // 否则继续重试
          }
        } catch (error) {
          // 最后一次重试失败，抛出错误
          if (i === retryCount) {
            if (error instanceof Error) {
              throw error;
            } else {
              throw new Error('Unknown network error');
            }
          }
          // 否则继续重试，等待一段时间
          await this.delay(1000 * (i + 1));
        }
      }

      // 理论上不会执行到这里
      throw new Error('Max retry count reached');
    } finally {
      // 销毁HTTP实例，释放资源
      httpRequest.destroy();
    }
  }

  /**
   * GET请求
   * @param url 请求URL
   * @param config 请求配置
   */
  async get<T extends Object>(url: string, config?: GetRequestConfig): Promise<HttpResponse<T>> {
    return this.request<T>(url, {
      headers: config ? config.headers : undefined,
      timeout: config ? config.timeout : undefined,
      retryCount: config ? config.retryCount : undefined,
      method: 'GET'
    });
  }

  /**
   * POST请求
   * @param url 请求URL
   * @param data 请求数据
   * @param config 请求配置
   */
  async post<T extends Object>(url: string, data?: Object, config?: DataRequestConfig): Promise<HttpResponse<T>> {
    return this.request<T>(url, {
      headers: config ? config.headers : undefined,
      timeout: config ? config.timeout : undefined,
      retryCount: config ? config.retryCount : undefined,
      method: 'POST',
      data
    });
  }

  /**
   * PUT请求
   * @param url 请求URL
   * @param data 请求数据
   * @param config 请求配置
   */
  async put<T extends Object>(url: string, data?: Object, config?: DataRequestConfig): Promise<HttpResponse<T>> {
    return this.request<T>(url, {
      headers: config ? config.headers : undefined,
      timeout: config ? config.timeout : undefined,
      retryCount: config ? config.retryCount : undefined,
      method: 'PUT',
      data
    });
  }

  /**
   * DELETE请求
   * @param url 请求URL
   * @param config 请求配置
   */
  async delete<T extends Object>(url: string, config?: GetRequestConfig): Promise<HttpResponse<T>> {
    return this.request<T>(url, {
      headers: config ? config.headers : undefined,
      timeout: config ? config.timeout : undefined,
      retryCount: config ? config.retryCount : undefined,
      method: 'DELETE'
    });
  }

  /**
   * PATCH请求
   * @param url 请求URL
   * @param data 请求数据
   * @param config 请求配置
   */
  async patch<T extends Object>(url: string, data?: Object, config?: DataRequestConfig): Promise<HttpResponse<T>> {
    return this.request<T>(url, {
      headers: config ? config.headers : undefined,
      timeout: config ? config.timeout : undefined,
      retryCount: config ? config.retryCount : undefined,
      method: 'PATCH',
      data
    });
  }

  /**
   * 解析响应数据
   * @param data 响应数据
   */
  private parseResponseData(data: string): string | Object {
    try {
      return JSON.parse(data);
    } catch {
      return data;
    }
  }

  /**
   * 创建HTTP错误对象
   * @param message 错误信息
   * @param statusCode 状态码
   * @param data 响应数据
   */
  private createHttpError(message: string, statusCode?: number, data?: Object): HttpError {
    return {
      message,
      statusCode,
      data
    };
  }

  /**
   * 延迟函数
   * @param ms 延迟毫秒数
   */
  private delay(ms: number): Promise<void> {
    return new Promise<void>((resolve) => {
      setTimeout(() => resolve(), ms);
    });
  }
  
  /**
   * 将对象转换为HttpHeaders
   * @param headerObj 请求头对象
   * @returns HttpHeaders实例
   */
  private convertToHttpHeaders(headerObj: Object): HttpHeaders {
    const headers = new HttpHeaders();
    return headers;
  }
}

// 导出单例实例
export default HttpUtil.getInstance();
