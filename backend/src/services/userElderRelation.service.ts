import { ElderUserRelationRepository } from '../repositories/elderUserRelation.repository';
import { ElderRepository } from '../repositories/elder.repository';
import { DailyHealthMeasurementRepository } from '../repositories/dailyHealthMeasurement.repository';
import { ElderBasicInfo } from '../types/healthRecord';
import {
  CreateUserElderRelationRequest,
  QueryUserEldersRequest,
  UserElderRelationItemResponse,
  UserElderWithHealthResponse,
  HealthSummary
} from '../dto/requests/user.dto';
import { ElderResponse } from '../dto/requests/elder.dto';
import { bpLevel, glucoseFpgLevel } from './ruleEngine.service';

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
        user_id: item.elder_user_id,
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
        elder_user_id: item.elder_user_id,
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

  static async getUserEldersWithHealth(
    userId: number,
    query: QueryUserEldersRequest
  ): Promise<{ items: UserElderWithHealthResponse[]; total: number; abnormal_count: number }> {
    // First get the elder list
    const { items: elderRelations, total } = await this.getUserElders(userId, query);

    let abnormalCount = 0;
    const itemsWithHealth: UserElderWithHealthResponse[] = [];

    // For each elder, fetch their latest health data
    for (const relation of elderRelations) {
      let healthSummary: HealthSummary | undefined = undefined;

      try {
        // Get the latest health measurement (page 1, pageSize 1)
        // Use elder_user_id (User ID) to query health data, as the daily_health_measurement table references users.id
        if (relation.elder_user_id) {
          const { items: healthRecords } = await DailyHealthMeasurementRepository.findAll(
            1, 1, relation.elder_user_id
          );

          if (healthRecords.length > 0) {
            const latest = healthRecords[0];
            healthSummary = {};

            // Blood pressure
            if (latest.sbp !== undefined && latest.sbp !== null &&
              latest.dbp !== undefined && latest.dbp !== null) {
              healthSummary.latest_bp = `${latest.sbp}/${latest.dbp}`;
              healthSummary.bp_level = bpLevel(latest.sbp, latest.dbp) || undefined;
              if (healthSummary.bp_level && healthSummary.bp_level !== 'NORMAL') {
                abnormalCount++;
              }
            }

            // Fasting blood glucose
            if (latest.fpg !== undefined && latest.fpg !== null) {
              healthSummary.latest_fpg = Number(latest.fpg).toFixed(1);
              healthSummary.fpg_level = glucoseFpgLevel(latest.fpg) || undefined;
              if (healthSummary.fpg_level && healthSummary.fpg_level !== 'NORMAL') {
                abnormalCount++;
              }
            }
          }
        }
      } catch (error) {
        console.error(`Failed to load health data for elder ${relation.elder_id}:`, error);
      }

      itemsWithHealth.push({
        ...relation,
        health_summary: healthSummary
      });
    }

    return {
      items: itemsWithHealth,
      total,
      abnormal_count: abnormalCount
    };
  }

  static async addUserElderRelation(
    userId: number,
    data: CreateUserElderRelationRequest
  ): Promise<UserElderRelationItemResponse> {
    // The elder_id in request is actually the USER ID of the elder (as agreed in plan)
    const elderUserId = data.elder_id;

    const elder = await ElderRepository.findByUserId(elderUserId);
    if (!elder) {
      const error = new Error('该老人尚未绑定账号，无法关联');
      error.name = 'NotFoundError';
      throw error;
    }

    const exists = await ElderUserRelationRepository.findByUserAndElderUser(userId, elderUserId);
    if (exists) {
      const error = new Error('该老人已存在关联关系');
      error.name = 'ValidationError';
      throw error;
    }

    const insertId = await ElderUserRelationRepository.create({
      user_id: userId,
      elder_id: elderUserId, // Store the Elder's USER ID
      relation_name: data.relation_name ?? null,
      remark: data.remark ?? null
    });

    const elderResponse = this.toElderResponse(elder);

    return {
      relation_id: insertId,
      elder_id: elderResponse.id,
      elder_user_id: elder.user_id ?? null,
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
      user_id: elder.user_id || null,
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


