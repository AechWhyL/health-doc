import axios, { AxiosInstance, AxiosResponse, AxiosError, AxiosRequestConfig,InternalAxiosRequestConfig,AxiosHeaders } from '@ohos/axios';
import { ResultEnum, RequestEnum, BASEURL } from './httpEnum';
import { preferenceUtils } from '../preferenceUtils'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UIContext } from '@kit.ArkUI';

let context = getContext(this);

// 定义请求配置接口，支持动态传递 token
interface RequestData<P> {
  url: string;
  contentType?: string;
  token?: string;
  params?: P;
  method: RequestEnum;
  context?:UIContext
}

const instance: AxiosInstance = axios.create({
  baseURL: BASEURL.baseUrl,
  timeout: 12000,
});

export function setBaseUrl(url: string): void {
  instance.defaults.baseURL = url;
}

instance.interceptors.request.use(
  async (config: InternalAxiosRequestConfig) => {
    const token = preferenceUtils().get(context, 'token_store', 'token') as string;
    console.log(token);
    if (token) {
      config.headers.set("authorization",`Bearer ${token}`);
    }
    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  }
);

instance.interceptors.response.use(
  async (response: AxiosResponse) => {
    if (response.status === ResultEnum.SUCCESS) {
      const body: Record<string, Object> = response.data as Record<string, Object>;
      const dataField: Record<string, Object> | null = body.data as Record<string, Object>;
      let token: Object | null = null;
      if (body.token) {
        token = body.token;
      } else if (dataField && dataField.token) {
        token = dataField.token;
      }
      if (token) {
        preferenceUtils().set(context, 'token_store', 'token', String(token));
      }
      return response.data;
    }
    return Promise.reject(response);
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  }
);

export async function httpRequest<T, P>(requestData: RequestData<P>): Promise<T> {
  const headers: Record<string, string> = {};
  if (requestData.contentType) {
    headers['Content-Type'] = requestData.contentType;
  }
  const config: AxiosRequestConfig = {
    url: requestData.url,
    method: requestData.method,
    headers,
  };
  if (requestData.method === RequestEnum.POST || requestData.method === RequestEnum.PUT || requestData.method === RequestEnum.PATCH) {
    config.data = requestData.params;
  } else {
    config.params = requestData.params;
  }
  return instance.request(config);
}
