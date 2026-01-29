/**
 * 健康档案相关类型定义
 * 用于医护端和家属端的健康档案功能
 */

// ==================== 基础类型 ====================

/**
 * 健康档案类型
 */
export type HealthRecordType = 'MEDICAL_HISTORY' | 'CHECK_REPORT' | 'MEDICATION' | 'ALLERGY'

/**
 * 附件类型
 */
export interface HealthRecordAttachment {
  type: 'IMAGE' | 'FILE';
  url: string;
  name?: string;
}

// ==================== 档案内容结构 ====================

/**
 * 病史记录内容
 */
export interface MedicalHistoryContent {
  disease_name: string;
  diagnosed_at: string;
  status: 'ONGOING' | 'REMISSION' | 'CURED';
  notes?: string;
  attachments?: HealthRecordAttachment[];
}

/**
 * 检查报告内容
 */
export interface CheckReportContent {
  check_date: string;
  hospital_name: string;
  check_item: string;
  result_summary: 'NORMAL' | 'MILD_ABNORMAL' | 'SIGNIFICANT_ABNORMAL';
  notes?: string;
  attachments?: HealthRecordAttachment[];
}

/**
 * 用药记录内容
 */
export interface MedicationContent {
  drug_name: string[];
  dosage: string;
  frequency: string;
  route: string;
  start_date: string;
  end_date?: string;
  notes?: string;
  prescribing_doctor?: string;
  hospital_name?: string;
  attachments?: HealthRecordAttachment[];
}

/**
 * 过敏记录内容
 */
export interface AllergyContent {
  allergy_item: string;
  reaction_symptoms: string[];
  first_occurrence_date: string;
  last_occurrence_date?: string;
  notes?: string;
  attachments?: HealthRecordAttachment[];
}

/**
 * 档案内容联合类型
 */
export type HealthRecordContent = MedicalHistoryContent | CheckReportContent | MedicationContent | AllergyContent;

// ==================== 档案数据结构 ====================

/**
 * 健康档案项
 */
export interface HealthRecordItem {
  id: number;
  elder_id: number;
  record_type: HealthRecordType;
  record_title: string;
  record_date: string;
  content_structured: HealthRecordContent;
  created_at: string;
  updated_at: string;
  creator_name?: string;
}

// ==================== API 请求/响应类型 ====================

/**
 * 健康档案列表查询参数
 */
export interface HealthRecordListQueryParams {
  page: number;
  pageSize: number;
  elder_id?: number;
  record_type?: HealthRecordType;
  sort_by?: 'created_at' | 'record_date';
  sort_order?: 'asc' | 'desc';
}

/**
 * 健康档案列表分页数据
 */
export interface HealthRecordListPageData {
  items: HealthRecordItem[];
  total: number;
  pages: number;
  current: number;
  size: number;
}

/**
 * 创建健康档案请求体
 */
export interface CreateHealthRecordPayload {
  elder_id: number;
  record_type: HealthRecordType;
  record_title: string;
  record_date: string;
  content_structured: HealthRecordContent;
}

/**
 * 更新健康档案请求体
 */
export interface UpdateHealthRecordPayload {
  record_type: HealthRecordType;
  record_title: string;
  record_date: string;
  content_structured: HealthRecordContent;
}

/**
 * 表单提交数据格式
 */
export interface HealthRecordFormSubmitPayload {
  recordType: HealthRecordType;
  recordTitle: string;
  recordDate: string;
  contentStructured: HealthRecordContent;
}

// ==================== 老人信息类型 ====================

/**
 * 老人基本信息
 */
export interface ElderBasicInfo {
  id: number;
  user_id?: number;
  name: string;
  gender: number;
  birth_date: string;
  phone: string;
  address?: string | null;
  emergency_contact?: string;
  height?: number | null;
  weight?: number | null;
  blood_type?: string | null;
  age: number;
  created_at?: string;
  updated_at?: string;
}

// ==================== 导航参数类型 ====================


/**
 * 添加/编辑健康档案页面参数
 */
export interface AddHealthRecordParams {
  elderId: number;
  elderName: string;
  recordType?: HealthRecordType;
  mode: 'create' | 'edit';
  editRecord?: HealthRecordItem;
}

/**
 * 健康档案详情页面参数
 */
export interface HealthRecordDetailParams {
  recordId: number;
  mode: 'editable' | 'readonly';
  elderName?: string;
}

export type OperationType = 'ADD' | 'MODIFY';

export interface HealthRecordHistory {
  id: number;
  health_record_id: number;
  operator_id: number;
  operator_name?: string;
  operation_type: OperationType;
  snapshot_before?: HealthRecordItem | null;
  snapshot_after: HealthRecordItem;
  created_at: string;
}

export interface HealthRecordHistoryDetailParams {
  history: HealthRecordHistory;
}
