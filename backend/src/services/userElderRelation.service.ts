import { ElderUserRelationRepository } from '../repositories/elderUserRelation.repository';
import { ElderRepository } from '../repositories/elder.repository';
import { ElderBasicInfo } from '../types/healthRecord';
import {
  CreateUserElderRelationRequest,
  QueryUserEldersRequest,
  UserElderRelationItemResponse
} from '../dto/requests/user.dto';
import { ElderResponse } from '../dto/requests/elder.dto';

export class UserElderRelationService {
  static async getUserElders(
    userId: number,
    query: QueryUserEldersRequest
  ): Promise<{ items: UserElderRelationItemResponse[]; total: number }> {
    const page = query.page || 1;
    const pageSize = query.pageSize || 10;
    const elderName = query.elder_name;

    const { items, total } = await ElderUserRelationRepository.findByUserIdWithElder(
      userId,
      page,
      pageSize,
      elderName
    );

    const resultItems = items.map((item) => {
      const elderBasic: ElderBasicInfo = {
        id: item.elder_id,
        name: item.elder_name,
        gender: item.elder_gender,
        birth_date: item.elder_birth_date,
        phone: item.elder_phone,
        address: item.elder_address || undefined,
        emergency_contact: item.elder_emergency_contact,
        height: item.elder_height === null ? undefined : item.elder_height,
        weight: item.elder_weight === null ? undefined : item.elder_weight,
        blood_type: item.elder_blood_type || undefined,
        created_at: item.elder_created_at,
        updated_at: item.elder_updated_at
      };

      const elder = this.toElderResponse(elderBasic);

      return {
        relation_id: item.relation_id,
        elder_id: elder.id,
        relation_name: item.relation_name,
        remark: item.remark,
        elder,
        elder_info: elder
      };
    });

    return {
      items: resultItems,
      total
    };
  }

  static async addUserElderRelation(
    userId: number,
    data: CreateUserElderRelationRequest
  ): Promise<UserElderRelationItemResponse> {
    const elder = await ElderRepository.findById(data.elder_id);
    if (!elder) {
      const error = new Error('老人信息不存在');
      error.name = 'NotFoundError';
      throw error;
    }

    const exists = await ElderUserRelationRepository.findByUserAndElder(userId, data.elder_id);
    if (exists) {
      const error = new Error('该老人已存在关联关系');
      error.name = 'ValidationError';
      throw error;
    }

    const insertId = await ElderUserRelationRepository.create({
      user_id: userId,
      elder_id: data.elder_id,
      relation_name: data.relation_name ?? null,
      remark: data.remark ?? null
    });

    const elderResponse = this.toElderResponse(elder);

    return {
      relation_id: insertId,
      elder_id: elderResponse.id,
      relation_name: data.relation_name ?? null,
      remark: data.remark ?? null,
      elder: elderResponse,
      elder_info: elderResponse
    };
  }

  static async removeUserElderRelation(userId: number, relationId: number): Promise<void> {
    const success = await ElderUserRelationRepository.deleteByIdAndUserId(relationId, userId);
    if (!success) {
      const error = new Error('关联关系不存在');
      error.name = 'NotFoundError';
      throw error;
    }
  }

  private static toElderResponse(elder: ElderBasicInfo): ElderResponse {
    const birthDate = new Date(elder.birth_date);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }

    return {
      id: elder.id || 0,
      name: elder.name,
      gender: elder.gender,
      birth_date: elder.birth_date,
      phone: elder.phone,
      address: elder.address || null,
      emergency_contact: elder.emergency_contact,
      height: elder.height ?? null,
      weight: elder.weight ?? null,
      blood_type: elder.blood_type ?? null,
      age,
      created_at: elder.created_at || '',
      updated_at: elder.updated_at || ''
    };
  }
}

