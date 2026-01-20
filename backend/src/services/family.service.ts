import { FamilyRepository } from '../repositories/family.repository';
import { FamilyBasicInfo } from '../types/family';
import { CreateFamilyRequest, UpdateFamilyRequest, FamilyResponse } from '../dto/requests/family.dto';

export class FamilyService {
    static async createFamily(data: CreateFamilyRequest): Promise<FamilyResponse> {
        // Check if family info already exists for this user
        const existing = await FamilyRepository.findByUserId(data.user_id);
        if (existing) {
            throw new Error('该用户的家属信息已存在');
        }

        const familyData: Omit<FamilyBasicInfo, 'id' | 'created_at' | 'updated_at'> = {
            user_id: data.user_id,
            name: data.name,
            gender: data.gender ?? 0,
            phone: data.phone
        };

        const insertId = await FamilyRepository.create(familyData);
        const family = await FamilyRepository.findById(insertId);

        if (!family) {
            throw new Error('创建家属信息失败');
        }

        return this.toResponse(family);
    }

    static async getFamilyById(id: number): Promise<FamilyResponse> {
        const family = await FamilyRepository.findById(id);
        if (!family) {
            throw new Error('家属信息不存在');
        }
        return this.toResponse(family);
    }

    static async getFamilyByUserId(userId: number): Promise<FamilyResponse | null> {
        const family = await FamilyRepository.findByUserId(userId);
        if (!family) {
            return null;
        }
        return this.toResponse(family);
    }

    static async getFamilyList(page: number, pageSize: number, name?: string): Promise<{ items: FamilyResponse[]; total: number }> {
        let where = '1=1';
        const params: any[] = [];

        if (name) {
            where += ' AND name LIKE ?';
            params.push(`%${name}%`);
        }

        const { items, total } = await FamilyRepository.findAll(page, pageSize, where, params);
        return {
            items: items.map(item => this.toResponse(item)),
            total
        };
    }

    static async updateFamily(id: number, data: UpdateFamilyRequest): Promise<FamilyResponse> {
        const existingFamily = await FamilyRepository.findById(id);
        if (!existingFamily) {
            throw new Error('家属信息不存在');
        }

        const updateData: Partial<Omit<FamilyBasicInfo, 'id' | 'user_id' | 'created_at' | 'updated_at'>> = {};
        if (data.name !== undefined) updateData.name = data.name;
        if (data.gender !== undefined) updateData.gender = data.gender;
        if (data.phone !== undefined) updateData.phone = data.phone;

        const success = await FamilyRepository.update(id, updateData);
        if (!success && Object.keys(updateData).length > 0) {
            throw new Error('更新家属信息失败');
        }

        const family = await FamilyRepository.findById(id);
        if (!family) {
            throw new Error('获取更新后的家属信息失败');
        }

        return this.toResponse(family);
    }

    static async deleteFamily(id: number): Promise<boolean> {
        const family = await FamilyRepository.findById(id);
        if (!family) {
            throw new Error('家属信息不存在');
        }

        const success = await FamilyRepository.delete(id);
        if (!success) {
            throw new Error('删除家属信息失败');
        }

        return true;
    }

    private static toResponse(family: FamilyBasicInfo): FamilyResponse {
        return {
            id: family.id!,
            user_id: family.user_id,
            name: family.name,
            gender: family.gender ?? 0,
            phone: family.phone || null,
            created_at: family.created_at || '',
            updated_at: family.updated_at || ''
        };
    }
}
