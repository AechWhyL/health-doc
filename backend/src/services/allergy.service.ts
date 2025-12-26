import { AllergyRepository } from '../repositories/allergy.repository';
import { AllergyRecord } from '../types/healthRecord';
import { CreateAllergyRequest, UpdateAllergyRequest, AllergyResponse } from '../dto/requests/allergy.dto';

export class AllergyService {
  static async createAllergy(data: CreateAllergyRequest): Promise<AllergyResponse> {
    const allergyData: Omit<AllergyRecord, 'id' | 'created_at' | 'updated_at'> = {
      elder_id: data.elder_id,
      allergy_item: data.allergy_item,
      allergy_desc: data.allergy_desc
    };

    const insertId = await AllergyRepository.create(allergyData);
    const allergy = await AllergyRepository.findById(insertId);

    if (!allergy) {
      throw new Error('创建过敏史记录失败');
    }

    return this.toResponse(allergy);
  }

  static async getAllergyById(id: number): Promise<AllergyResponse> {
    const allergy = await AllergyRepository.findById(id);
    if (!allergy) {
      throw new Error('过敏史记录不存在');
    }
    return this.toResponse(allergy);
  }

  static async getAllergyList(page: number, pageSize: number, elderId?: number, allergyItem?: string): Promise<{ items: AllergyResponse[]; total: number }> {
    let where = '1=1';
    const params: any[] = [];

    if (elderId) {
      where += ' AND elder_id = ?';
      params.push(elderId);
    }
    if (allergyItem) {
      where += ' AND allergy_item LIKE ?';
      params.push(`%${allergyItem}%`);
    }

    const { items, total } = await AllergyRepository.findAll(page, pageSize, where, params);
    return {
      items: items.map(item => this.toResponse(item)),
      total
    };
  }

  static async getAllergiesByElderId(elderId: number): Promise<AllergyResponse[]> {
    const allergies = await AllergyRepository.findByElderId(elderId);
    return allergies.map(item => this.toResponse(item));
  }

  static async updateAllergy(id: number, data: UpdateAllergyRequest): Promise<AllergyResponse> {
    const existingAllergy = await AllergyRepository.findById(id);
    if (!existingAllergy) {
      throw new Error('过敏史记录不存在');
    }

    const updateData: Partial<Omit<AllergyRecord, 'id' | 'elder_id' | 'created_at' | 'updated_at'>> = {};
    if (data.allergy_item !== undefined) updateData.allergy_item = data.allergy_item;
    if (data.allergy_desc !== undefined) updateData.allergy_desc = data.allergy_desc;

    const success = await AllergyRepository.update(id, updateData);
    if (!success) {
      throw new Error('更新过敏史记录失败');
    }

    const allergy = await AllergyRepository.findById(id);
    if (!allergy) {
      throw new Error('获取更新后的过敏史记录失败');
    }

    return this.toResponse(allergy);
  }

  static async deleteAllergy(id: number): Promise<boolean> {
    const allergy = await AllergyRepository.findById(id);
    if (!allergy) {
      throw new Error('过敏史记录不存在');
    }

    const success = await AllergyRepository.delete(id);
    if (!success) {
      throw new Error('删除过敏史记录失败');
    }

    return true;
  }

  private static toResponse(allergy: AllergyRecord): AllergyResponse {
    return {
      id: allergy.id!,
      elder_id: allergy.elder_id,
      allergy_item: allergy.allergy_item,
      allergy_desc: allergy.allergy_desc || null,
      created_at: allergy.created_at || '',
      updated_at: allergy.updated_at || ''
    };
  }
}
