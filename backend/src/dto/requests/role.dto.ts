export interface CreateRoleRequest {
  role_code: string;
  role_name: string;
  description?: string;
}

export interface UpdateRoleRequest {
  role_name?: string;
  description?: string;
}

export interface QueryRoleRequest {
  page: number;
  pageSize: number;
  role_code?: string;
  role_name?: string;
  orderBy?: string;
}

export interface RoleResponse {
  id: number;
  role_code: string;
  role_name: string;
  description: string | null;
  created_at: string;
  updated_at: string;
}

export interface RoleWithUsersResponse extends RoleResponse {
  user_count: number;
}
