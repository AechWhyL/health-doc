export interface CreateAllergyRequest {
  elder_id: number;
  allergy_item: string;
  allergy_desc?: string;
}

export interface UpdateAllergyRequest {
  allergy_item?: string;
  allergy_desc?: string;
}

import { PaginationQuery } from './common.dto';

export interface QueryAllergyRequest extends PaginationQuery {
  elder_id?: number;
  allergy_item?: string;
  orderBy?: string;
}

export interface AllergyResponse {
  id: number;
  elder_id: number;
  allergy_item: string;
  allergy_desc: string | null;
  created_at: string;
  updated_at: string;
}
