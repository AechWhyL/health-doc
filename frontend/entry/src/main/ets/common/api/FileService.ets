import axios, { FormData, AxiosResponse, AxiosRequestConfig } from '@ohos/axios';
import fs from '@ohos.file.fs';
import { BASEURL } from './httpEnum';
import { preferenceUtils } from '../preferenceUtils';
import { Context } from '@kit.AbilityKit';
import { ApiResponse } from '../../models/DTO/types';

const TAG = '[FileService]';

interface UploadFileResult {
  url: string;
  filename?: string;
  mimetype?: string;
  size?: number;
}

interface UploadResponseData {
  files: UploadFileResult[];
}

export class FileService {
  
  static async uploadImage(context: Context, fileUri: string): Promise<string> {
    let srcFile: fs.File | null = null;
    let destFile: fs.File | null = null;
    try {
      // 1. 将文件拷贝到缓存目录，确保 axios 可以通过 internal:// 协议访问
      // 获取文件名 (简单的生成一个)
      const filename = `upload_${Date.now()}.jpg`;
      const cacheDir = context.cacheDir;
      const internalPath = `${cacheDir}/${filename}`;
      
      // 打开源文件 (Picker 返回的 URI)
      srcFile = fs.openSync(fileUri, fs.OpenMode.READ_ONLY);
      // 打开/创建目标文件
      destFile = fs.openSync(internalPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      
      // 拷贝文件内容
      fs.copyFileSync(srcFile.fd, destFile.fd);
      
      // 关闭文件流 (将在 finally 中确保关闭)
      
      // 2. 构造 FormData
      const formData = new FormData();
      // 使用 internal://cache/ 协议指向缓存目录下的文件
      const internalUri = `internal://cache/${filename}`;
      formData.append('file', internalUri); 

      // 3. 获取 Token
      const token = await preferenceUtils().get(context, 'token_store', 'token') as string;

      // 4. 发送上传请求
      const config: AxiosRequestConfig = {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'multipart/form-data',
        },
        context: context, // 必须传递 context 以解析 internal:// 协议
      };

      const res: AxiosResponse<ApiResponse<UploadResponseData>> = await axios.post(
        `${BASEURL.baseUrl}/api/v1/files/upload`, 
        formData, 
        config
      );

      // 5. 处理响应
      if (res.status === 200 && res.data && res.data.code === 200) {
        // 后端返回结构: { data: { files: [ { url: '...' } ] } }
        const data: UploadResponseData = res.data.data;
        const files: UploadFileResult[] = data.files;
        
        if (files && files.length > 0) {
          let url: string = files[0].url;
          // 如果返回的是相对路径，拼接 BaseURL
          if (url.startsWith('/')) {
            url = `${BASEURL.baseUrl}${url}`;
          }
          return url;
        }
      }
      
      throw new Error(res.data?.message || '上传失败');

    } catch (err) {
      console.error(TAG, 'Upload exception', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    } finally {
      // 确保文件关闭
      if (srcFile) {
        try {
          fs.closeSync(srcFile.fd);
        } catch (e) {
          console.error(TAG, 'Close srcFile failed', e);
        }
      }
      if (destFile) {
        try {
          fs.closeSync(destFile.fd);
        } catch (e) {
          console.error(TAG, 'Close destFile failed', e);
        }
      }
    }
  }
}
