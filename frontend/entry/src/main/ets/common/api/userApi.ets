import HttpUtil from './HttpUtil';
import { ApiResponse, UserSummary, UserUpdateInfo } from './types';

export async function updateUserInfo(userInfo: UserUpdateInfo): Promise<ApiResponse<UserSummary>> {
  const response = await HttpUtil.put<ApiResponse<UserSummary>>('/user/profile', userInfo);
  return response.data;
}

