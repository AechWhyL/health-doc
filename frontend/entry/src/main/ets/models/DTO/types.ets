export interface PaginationQuery {
  page: number;
  pageSize: number;
}

export interface PaginationMeta {
  currentPage: number;
  pageSize: number;
  totalItems: number;
  totalPages: number;
}

export interface PaginationResponse<T> {
  items: T[];
  meta: PaginationMeta;
}

export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
  timestamp: number;
  requestId: string;
}