export type NotificationStatus = 'UNREAD' | 'READ';

export interface UserNotificationRecord {
  id?: number;
  user_id: number;
  biz_type: string;
  biz_id: number;
  title: string;
  content: string;
  status: NotificationStatus;
  created_at?: string;
  read_at?: string | null;
}

