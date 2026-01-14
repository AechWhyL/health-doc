import { PersonalHealthRuleRepository } from '../repositories/personalHealthRule.repository';
import { PersonalHealthRuleConfig } from '../types/ruleEngine';
import { CreatePersonalRuleRequest, UpdatePersonalRuleRequest } from '../dto/requests/personalRule.dto';

export class PersonalHealthRuleService {
  static async create(data: CreatePersonalRuleRequest, createdByUserId?: number): Promise<PersonalHealthRuleConfig> {
    const insertId = await PersonalHealthRuleRepository.create({
      elderId: data.elder_id ?? undefined,
      name: data.name,
      level: data.level,
      logic: data.logic,
      messageTemplate: data.message_template ?? undefined,
      createdByUserId
    });
    const created = await PersonalHealthRuleRepository.findById(insertId);
    return created!;
  }

  static async update(id: number, data: UpdatePersonalRuleRequest): Promise<PersonalHealthRuleConfig | null> {
    const ok = await PersonalHealthRuleRepository.update(id, {
      elderId: data.elder_id ?? undefined,
      name: data.name,
      level: data.level,
      logic: data.logic,
      messageTemplate: data.message_template ?? undefined,
      isActive: data.is_active
    });
    if (!ok) {
      return null;
    }
    return await PersonalHealthRuleRepository.findById(id);
  }

  static async delete(id: number): Promise<boolean> {
    return await PersonalHealthRuleRepository.delete(id);
  }

  static async getList(page: number, pageSize: number, elderId?: number): Promise<{ items: PersonalHealthRuleConfig[]; total: number }> {
    return await PersonalHealthRuleRepository.findAll(page, pageSize, elderId);
  }

  static async getActiveForElder(elderId: number): Promise<PersonalHealthRuleConfig[]> {
    return await PersonalHealthRuleRepository.findByElderId(elderId);
  }
}

