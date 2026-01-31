import { PaginationQuery } from "./DTO/types"

export interface CreatorSummary {
  name: string;
  phone?: string;
}

export interface ConsultationQuestion {
  id: number;
  title: string;
  status: 'PENDING' | 'IN_PROGRESS' | 'RESOLVED' | 'CLOSED';
  priority: 'NORMAL' | 'URGENT';
  creator_type: 'ELDER' | 'FAMILY' | 'STAFF';
  creator_id: number;
  target_staff_id: number;
  created_at: string;
  updated_at: string;
  last_message_at?: string;
  description?:string;
  unread_count?: number;
  creator_summary?: CreatorSummary;
  creator_info?: UserInfo;
  target_staff?: MedicalStaffInfo;
}

export interface UserInfo {
  id: number;
  username: string;
  email: string | null;
  phone: string | null;
  real_name: string | null;
  avatar: string | null;
  gender?: number;
  birth_date?: string | null;
}

export interface MedicalStaffInfo extends UserInfo {
  role_type: string;
  job_title: string | null;
  good_at_tags: string | null;
  enable_online_service: boolean;
}

type ConsultationStatus = 'SENDING' | 'SENT' | 'FAILED'

export interface ConsultationMessage {
  id: number;
  question_id: number;
  sender_type: 'STAFF' | 'ELDER' | 'FAMILY' | 'SYSTEM';
  sender_id: number;
  role_display_name: string;
  content_type: 'TEXT' | 'IMAGE' | 'AUDIO';
  content_text: string;
  attachments?: MessageAttachment[];
  sent_at: string;
  status: ConsultationStatus;
}

export interface MessageAttachment {
  url: string;
  thumbnail_url?: string;
  duration?: number;
  size?: number;
}

export interface CreateMessageDto {
  question_id: number;
  sender_type: string;
  sender_id: number;
  role_display_name: string;
  content_type: 'TEXT';
  content_text: string;
}

export interface QueryConsultationQuestionRequest extends PaginationQuery {
  status?: ConsultationStatus;
  creator_id?: number;
  target_staff_id?: number;
  category?: string;
  orderBy?: string;
}