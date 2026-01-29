export interface UserRole {
  id: number;
  role_code: string;
  role_name: string;
  description: string | null;
}

export interface CurrentUser {
  id: number;
  username: string;
  email: string | null;
  phone: string | null;
  real_name: string | null;
  avatar: string | null;
  status: 'active' | 'inactive' | 'locked';
  is_verified: boolean;
  roles: UserRole[];
}