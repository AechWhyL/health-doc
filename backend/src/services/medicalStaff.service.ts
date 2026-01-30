import { MedicalStaffBasicInfo, MedicalStaffRepository } from '../repositories/medicalStaff.repository';
import { UpsertMedicalStaffInfoRequest } from '../dto/requests/medicalStaff.dto';

export class MedicalStaffService {
  static async upsertForUser(
    userId: number,
    data: UpsertMedicalStaffInfoRequest
  ): Promise<MedicalStaffBasicInfo> {
    const existing = await MedicalStaffRepository.findByUserId(userId);

    if (!existing) {
      const birthDateValue =
        data.birth_date && data.birth_date.trim() !== ''
          ? data.birth_date.split('T')[0]
          : null;
      const jobTitleValue =
        data.job_title && data.job_title.trim() !== '' ? data.job_title : null;
      const goodAtTagsValue =
        data.good_at_tags && data.good_at_tags.trim() !== ''
          ? data.good_at_tags
          : null;
      const enableOnline =
        data.enable_online_service !== undefined
          ? data.enable_online_service
          : false;

      await MedicalStaffRepository.create({
        user_id: userId,
        gender: data.gender,
        birth_date: birthDateValue,
        role_type: data.role_type,
        job_title: jobTitleValue,
        good_at_tags: goodAtTagsValue,
        enable_online_service: enableOnline
      });
    } else {
      const updateData: any = {};
      if (data.gender !== undefined) updateData.gender = data.gender;
      if (data.role_type !== undefined) updateData.role_type = data.role_type;

      if (data.birth_date !== undefined) {
        updateData.birth_date =
          data.birth_date && data.birth_date.trim() !== ''
            ? data.birth_date.split('T')[0]
            : null;
      }

      if (data.job_title !== undefined) {
        updateData.job_title =
          data.job_title && data.job_title.trim() !== ''
            ? data.job_title
            : null;
      }

      if (data.good_at_tags !== undefined) {
        updateData.good_at_tags =
          data.good_at_tags && data.good_at_tags.trim() !== ''
            ? data.good_at_tags
            : null;
      }

      if (data.enable_online_service !== undefined) {
        updateData.enable_online_service = data.enable_online_service;
      }

      if (Object.keys(updateData).length > 0) {
        await MedicalStaffRepository.updateByUserId(userId, updateData);
      }
    }

    if (data.real_name) {
      // Lazy import to avoid circular dependency if possible, or usually UserService imports Repository
      // But here we are in Service, so let's import UserRepository at top level if not present, but wait,
      // MedicalStaffService doesn't import UserRepository yet.
      // Let's check imports first.
      const { UserRepository } = require('../repositories/user.repository');
      await UserRepository.update(userId, { real_name: data.real_name });
    }

    const updated = await MedicalStaffRepository.findByUserId(userId);
    if (!updated) {
      throw new Error('更新医护人员信息失败');
    }

    return updated;
  }

  static async getOnlineStaff(
    page: number = 1,
    pageSize: number = 10,
    filters?: { goodAtTags?: string; phone?: string }
  ) {
    return await MedicalStaffRepository.findOnlineStaff(page, pageSize, filters);
  }
}

