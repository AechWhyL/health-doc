export interface IUser {
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