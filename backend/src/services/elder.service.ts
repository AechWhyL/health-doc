import { ElderRepository } from '../repositories/elder.repository';
import { ElderBasicInfo } from '../types/healthRecord';
import { CreateElderRequest, UpdateElderRequest, ElderResponse } from '../dto/requests/elder.dto';

export class ElderService {
  static async createElder(data: CreateElderRequest): Promise<ElderResponse> {
    const elderData: Omit<ElderBasicInfo, 'id' | 'created_at' | 'updated_at'> = {
      name: data.name,
      gender: data.gender,
      birth_date: data.birth_date,
      phone: data.phone,
      emergency_contact: data.emergency_contact,
      address: data.address,
      height: data.height,
      weight: data.weight,
      blood_type: data.blood_type
    };

    const insertId = await ElderRepository.create(elderData);
    const elder = await ElderRepository.findById(insertId);

    if (!elder) {
      throw new Error('创建老人信息失败');
    }

    return this.toResponse(elder);
  }

  static async getElderById(id: number): Promise<ElderResponse> {
    const elder = await ElderRepository.findById(id);
    if (!elder) {
      throw new Error('老人信息不存在');
    }
    return this.toResponse(elder);
  }

  static async getElderList(page: number, pageSize: number, name?: string, phone?: string): Promise<{ items: ElderResponse[]; total: number }> {
    let where = '1=1';
    const params: any[] = [];

    if (name) {
      where += ' AND name LIKE ?';
      params.push(`%${name}%`);
    }

    if (phone) {
      where += ' AND phone LIKE ?';
      params.push(`%${phone}%`);
    }

    const { items, total } = await ElderRepository.findAll(page, pageSize, where, params);
    return {
      items: items.map(item => this.toResponse(item)),
      total
    };
  }

  static async updateElder(id: number, data: UpdateElderRequest): Promise<ElderResponse> {
    const existingElder = await ElderRepository.findById(id);
    if (!existingElder) {
      throw new Error('老人信息不存在');
    }

    const updateData: Partial<Omit<ElderBasicInfo, 'id' | 'created_at' | 'updated_at'>> = {};
    if (data.name !== undefined) updateData.name = data.name;
    if (data.gender !== undefined) updateData.gender = data.gender;
    if (data.birth_date !== undefined) updateData.birth_date = data.birth_date;
    if (data.phone !== undefined) updateData.phone = data.phone;
    if (data.address !== undefined) updateData.address = data.address;
    if (data.emergency_contact !== undefined) updateData.emergency_contact = data.emergency_contact;
    if (data.height !== undefined) updateData.height = data.height;
    if (data.weight !== undefined) updateData.weight = data.weight;
    if (data.blood_type !== undefined) updateData.blood_type = data.blood_type;

    const success = await ElderRepository.update(id, updateData);
    if (!success) {
      throw new Error('更新老人信息失败');
    }

    const elder = await ElderRepository.findById(id);
    if (!elder) {
      throw new Error('获取更新后的老人信息失败');
    }

    return this.toResponse(elder);
  }

  static async deleteElder(id: number): Promise<boolean> {
    const elder = await ElderRepository.findById(id);
    if (!elder) {
      throw new Error('老人信息不存在');
    }

    const success = await ElderRepository.delete(id);
    if (!success) {
      throw new Error('删除老人信息失败');
    }

    return true;
  }

  private static toResponse(elder: ElderBasicInfo): ElderResponse {
    const birthDate = new Date(elder.birth_date);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }

    return {
      id: elder.id!,
      name: elder.name,
      gender: elder.gender,
      birth_date: elder.birth_date,
      phone: elder.phone,
      address: elder.address || null,
      emergency_contact: elder.emergency_contact,
      height: elder.height || null,
      weight: elder.weight || null,
      blood_type: elder.blood_type || null,
      age,
      created_at: elder.created_at || '',
      updated_at: elder.updated_at || ''
    };
  }
}
