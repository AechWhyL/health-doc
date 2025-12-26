import { MedicationRepository } from '../repositories/medication.repository';
import { MedicationRecord } from '../types/healthRecord';
import { CreateMedicationRequest, UpdateMedicationRequest, MedicationResponse } from '../dto/requests/medication.dto';

export class MedicationService {
  static async createMedication(data: CreateMedicationRequest): Promise<MedicationResponse> {
    const medicationData: Omit<MedicationRecord, 'id' | 'created_at' | 'updated_at'> = {
      elder_id: data.elder_id,
      drug_name: data.drug_name,
      dosage: data.dosage,
      frequency: data.frequency,
      start_date: data.start_date,
      end_date: data.end_date,
      notes: data.notes
    };

    const insertId = await MedicationRepository.create(medicationData);
    const medication = await MedicationRepository.findById(insertId);

    if (!medication) {
      throw new Error('创建用药记录失败');
    }

    return this.toResponse(medication);
  }

  static async getMedicationById(id: number): Promise<MedicationResponse> {
    const medication = await MedicationRepository.findById(id);
    if (!medication) {
      throw new Error('用药记录不存在');
    }
    return this.toResponse(medication);
  }

  static async getMedicationList(
    page: number,
    pageSize: number,
    elderId?: number,
    drugName?: string,
    startDate?: string,
    endDate?: string
  ): Promise<{ items: MedicationResponse[]; total: number }> {
    let where = '1=1';
    const params: any[] = [];

    if (elderId) {
      where += ' AND elder_id = ?';
      params.push(elderId);
    }
    if (drugName) {
      where += ' AND drug_name LIKE ?';
      params.push(`%${drugName}%`);
    }
    if (startDate) {
      where += ' AND start_date >= ?';
      params.push(startDate);
    }
    if (endDate) {
      where += ' AND start_date <= ?';
      params.push(endDate);
    }

    const { items, total } = await MedicationRepository.findAll(page, pageSize, where, params);
    return {
      items: items.map(item => this.toResponse(item)),
      total
    };
  }

  static async getMedicationsByElderId(elderId: number): Promise<MedicationResponse[]> {
    const medications = await MedicationRepository.findByElderId(elderId);
    return medications.map(item => this.toResponse(item));
  }

  static async updateMedication(id: number, data: UpdateMedicationRequest): Promise<MedicationResponse> {
    const existingMedication = await MedicationRepository.findById(id);
    if (!existingMedication) {
      throw new Error('用药记录不存在');
    }

    const updateData: Partial<Omit<MedicationRecord, 'id' | 'elder_id' | 'created_at' | 'updated_at'>> = {};
    if (data.drug_name !== undefined) updateData.drug_name = data.drug_name;
    if (data.dosage !== undefined) updateData.dosage = data.dosage;
    if (data.frequency !== undefined) updateData.frequency = data.frequency;
    if (data.start_date !== undefined) updateData.start_date = data.start_date;
    if (data.end_date !== undefined) updateData.end_date = data.end_date;
    if (data.notes !== undefined) updateData.notes = data.notes;

    const success = await MedicationRepository.update(id, updateData);
    if (!success) {
      throw new Error('更新用药记录失败');
    }

    const medication = await MedicationRepository.findById(id);
    if (!medication) {
      throw new Error('获取更新后的用药记录失败');
    }

    return this.toResponse(medication);
  }

  static async deleteMedication(id: number): Promise<boolean> {
    const medication = await MedicationRepository.findById(id);
    if (!medication) {
      throw new Error('用药记录不存在');
    }

    const success = await MedicationRepository.delete(id);
    if (!success) {
      throw new Error('删除用药记录失败');
    }

    return true;
  }

  private static toResponse(medication: MedicationRecord): MedicationResponse {
    return {
      id: medication.id!,
      elder_id: medication.elder_id,
      drug_name: medication.drug_name,
      dosage: medication.dosage || null,
      frequency: medication.frequency || null,
      start_date: medication.start_date,
      end_date: medication.end_date || null,
      notes: medication.notes || null,
      created_at: medication.created_at || '',
      updated_at: medication.updated_at || ''
    };
  }
}
