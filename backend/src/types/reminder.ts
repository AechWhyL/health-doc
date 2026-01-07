export type ReminderChannel = 'IN_APP' | 'SYSTEM_MESSAGE' | 'SMS' | 'PUSH';

export type ReminderStatus = 'PENDING' | 'SENT' | 'CANCELLED' | 'FAILED';

export interface ReminderTaskRecord {
  id?: number;
  biz_type: string;
  biz_id: number;
  target_user_id: number;
  channel: ReminderChannel;
  title: string;
  content: string;
  remind_at: string;
  status: ReminderStatus;
  created_at?: string;
  updated_at?: string;
}

