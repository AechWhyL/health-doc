import { HealthDataRecordHistoryRepository } from '../repositories/healthDataRecordHistory.repository';
import { HealthDataRecordHistory } from '../types/healthDataRecord';

export class HealthDataRecordHistoryService {
  static async getHistoryById(id: number): Promise<HealthDataRecordHistory> {
    const history = await HealthDataRecordHistoryRepository.findById(id);
    if (!history) {
      throw new Error('历史记录不存在');
    }
    return history;
  }

  static async getHistoryByHealthRecordId(healthRecordId: number): Promise<HealthDataRecordHistory[]> {
    const historyList = await HealthDataRecordHistoryRepository.findByHealthRecordId(healthRecordId);
    return historyList;
  }

  static async getHistoryByOperationType(operationType: string, page: number = 1, pageSize: number = 10): Promise<{ items: HealthDataRecordHistory[]; total: number }> {
    const validOperationTypes = ['INSERT', 'UPDATE', 'DELETE'];
    if (!validOperationTypes.includes(operationType)) {
      throw new Error('无效的操作类型');
    }

    return await HealthDataRecordHistoryRepository.findByOperationType(operationType, page, pageSize);
  }

  static async getHistoryByOperator(operatorId: number, operatorType?: string, page: number = 1, pageSize: number = 10): Promise<{ items: HealthDataRecordHistory[]; total: number }> {
    const validOperatorTypes = ['ELDER', 'FAMILY', 'DOCTOR'];
    if (operatorType && !validOperatorTypes.includes(operatorType)) {
      throw new Error('无效的操作人类型');
    }

    return await HealthDataRecordHistoryRepository.findByOperator(operatorId, operatorType, page, pageSize);
  }

  static async getHistoryByDateRange(startTime: string, endTime: string, page: number = 1, pageSize: number = 10): Promise<{ items: HealthDataRecordHistory[]; total: number }> {
    const start = new Date(startTime);
    const end = new Date(endTime);

    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      throw new Error('无效的日期格式');
    }

    if (start > end) {
      throw new Error('开始日期不能晚于结束日期');
    }

    return await HealthDataRecordHistoryRepository.findByDateRange(startTime, endTime, page, pageSize);
  }
}
