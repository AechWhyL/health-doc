export type ConsultationCreatorType = 'ELDER' | 'FAMILY' | 'STAFF';

export type ConsultationStatus = 'PENDING' | 'IN_PROGRESS' | 'RESOLVED' | 'CLOSED';

export type ConsultationPriority = 'NORMAL' | 'URGENT';

export type ConsultationSenderType = 'ELDER' | 'FAMILY' | 'STAFF' | 'SYSTEM';

export type ConsultationContentType = 'TEXT' | 'IMAGE' | 'AUDIO' | 'SYSTEM';

export interface ConsultationQuestionRecord {
  id?: number;
  code: string;
  title: string;
  description?: string | null;
  creator_type: ConsultationCreatorType;
  creator_id: number;
  target_staff_id: number;
  category?: string | null;
  status: ConsultationStatus;
  priority: ConsultationPriority;
  is_anonymous?: boolean;
  created_at?: string;
  updated_at?: string;
  resolved_at?: string | null;
  closed_at?: string | null;
}

export interface ConsultationMessageRecord {
  id?: number;
  question_id: number;
  sender_type: ConsultationSenderType;
  sender_id?: number | null;
  role_display_name?: string | null;
  content_type: ConsultationContentType;
  content_text?: string | null;
  sent_at: string;
  status: 'SENT' | 'DELIVERED' | 'READ' | 'FAILED';
  is_visible_to_patient?: boolean;
  created_at?: string;
}

export interface ConsultationAttachmentRecord {
  id?: number;
  message_id: number;
  url: string;
  thumbnail_url?: string | null;
  duration?: number | null;
  size?: number | null;
  created_at?: string;
}

