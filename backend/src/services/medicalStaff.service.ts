import { MedicalStaffBasicInfo, MedicalStaffRepository } from '../repositories/medicalStaff.repository';
import { UpsertMedicalStaffInfoRequest } from '../dto/requests/medicalStaff.dto';

export class MedicalStaffService {
  static async upsertForUser(
    userId: number,
    data: UpsertMedicalStaffInfoRequest
  ): Promise<MedicalStaffBasicInfo> {
    const existing = await MedicalStaffRepository.findByUserId(userId);

    const birthDateValue =
      data.birth_date && data.birth_date.trim() !== '' ? data.birth_date : null;
    const jobTitleValue =
      data.job_title && data.job_title.trim() !== '' ? data.job_title : null;
    const goodAtTagsValue =
      data.good_at_tags && data.good_at_tags.trim() !== '' ? data.good_at_tags : null;
    const enableOnline =
      data.enable_online_service !== undefined ? data.enable_online_service : false;

    if (!existing) {
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
      await MedicalStaffRepository.updateByUserId(userId, {
        gender: data.gender,
        birth_date: birthDateValue,
        role_type: data.role_type,
        job_title: jobTitleValue,
        good_at_tags: goodAtTagsValue,
        enable_online_service: enableOnline
      });
    }

    const updated = await MedicalStaffRepository.findByUserId(userId);
    if (!updated) {
      throw new Error('更新医护人员信息失败');
    }

    return updated;
  }
}

