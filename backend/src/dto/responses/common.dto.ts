export interface PaginationResponse<T> {
  total: number;
  pages: number;
  current: number;
  size: number;
  records: T[];
}
