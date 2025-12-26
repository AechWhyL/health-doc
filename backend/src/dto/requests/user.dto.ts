export interface CreateUserRequest {
  username: string;
  password: string;
  email?: string;
  phone?: string;
  real_name?: string;
  avatar?: string;
  status?: 'active' | 'inactive' | 'locked';
  is_verified?: boolean;
}

export interface UpdateUserRequest {
  password?: string;
  email?: string;
  phone?: string;
  real_name?: string;
  avatar?: string;
  status?: 'active' | 'inactive' | 'locked';
  is_verified?: boolean;
}

export interface QueryUserRequest {
  page: number;
  pageSize: number;
  username?: string;
  email?: string;
  phone?: string;
  real_name?: string;
  status?: 'active' | 'inactive' | 'locked';
  orderBy?: string;
}

export interface UserResponse {
  id: number;
  username: string;
  email: string | null;
  phone: string | null;
  real_name: string | null;
  avatar: string | null;
  status: 'active' | 'inactive' | 'locked';
  is_verified: boolean;
  last_login_at: string | null;
  last_login_ip: string | null;
  created_at: string;
  updated_at: string;
}

export interface UserWithRoleResponse extends UserResponse {
  roles: RoleResponse[];
}

export interface RoleResponse {
  id: number;
  role_code: string;
  role_name: string;
  description: string | null;
}

export interface AssignRoleRequest {
  role_ids: number[];
}

export interface ChangePasswordRequest {
  old_password: string;
  new_password: string;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: UserWithRoleResponse;
}
