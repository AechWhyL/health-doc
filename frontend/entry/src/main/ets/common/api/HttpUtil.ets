import http from '@ohos.net.http';

// 定义请求方法类型
export type RequestMethod = 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';

// 定义请求配置接口
export interface HttpRequestConfig {
  method?: RequestMethod;
  headers?: Record<string, string>;
  data?: Object;
  timeout?: number;
  retryCount?: number;
}

// 定义GET请求配置接口（不包含method）
export interface GetRequestConfig {
  headers?: Record<string, string>;
  timeout?: number;
  retryCount?: number;
}

// 定义带data的请求配置接口（不包含method）
export interface DataRequestConfig {
  headers?: Record<string, string>;
  data?: Object;
  timeout?: number;
  retryCount?: number;
}

// 定义响应数据接口
export interface HttpResponse<T> {
  data: T;
  statusCode: number;
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
  private defaultHeaders: Record<string, string> = {};
  private authToken: string | null = null;

  private constructor() {
    // 设置默认Content-Type
    this.defaultHeaders['Content-Type'] = 'application/json';
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

  setAuthToken(token: string): void {
    this.authToken = token;
  }

  clearAuthToken(): void {
    this.authToken = null;
  }

  /**
   * 通用请求方法
   * @param url 请求URL
   * @param config 请求配置
   */
  async request<T extends Object>(url: string, config?: HttpRequestConfig): Promise<HttpResponse<T>> {
    // 构建完整URL
    const fullUrl = this.baseUrl + url;

    const headers: Record<string, string> = {};

    const defaultEntries = Object.keys(this.defaultHeaders)
    for (let i = 0; i < defaultEntries.length; i++) {
      const entry = defaultEntries[i];
      const key = entry[0];
      const value = entry[1];
      headers[key] = value;
    }

    if (config?.headers) {
      const customEntries = Object.keys(config.headers);
      for (let i = 0; i < customEntries.length; i++) {
        const entry = customEntries[i];
        const key = entry[0];
        const value = entry[1];
        headers[key] = value;
      }
    }
    if (this.authToken !== null && this.authToken !== '') {
      console.log(this.authToken)
      headers['Authorization'] = 'Bearer ' + this.authToken;
    }

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
      default:
        httpMethod = http.RequestMethod.GET;
    }

    // 构建请求选项
    const requestOptions: http.HttpRequestOptions = {
      method: httpMethod,
      header: headers,
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
}

// 导出单例实例
export default HttpUtil.getInstance();
