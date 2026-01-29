import { Database } from '../config/database';
import { HealthRecordHistory } from '../types/healthRecordHistory';

export class HealthRecordHistoryRepository {
    static async create(data: HealthRecordHistory): Promise<number> {
        const sql = `
      INSERT INTO health_record_history (health_record_id, operator_id, operation_type, snapshot_before, snapshot_after)
      VALUES (?, ?, ?, ?, ?)
    `;
        const params = [
            data.health_record_id,
            data.operator_id,
            data.operation_type,
            data.snapshot_before ? JSON.stringify(data.snapshot_before) : null,
            JSON.stringify(data.snapshot_after)
        ];
        return await Database.insert(sql, params);
    }

    static async findByRecordId(recordId: number): Promise<HealthRecordHistory[]> {
        const sql = `
      SELECT hrh.*, u.real_name as operator_name
      FROM health_record_history hrh
      LEFT JOIN users u ON hrh.operator_id = u.id
      WHERE hrh.health_record_id = ?
      ORDER BY hrh.created_at DESC
    `;
        const results = await Database.query<HealthRecordHistory>(sql, [recordId]);

        return results.map(item => {
            if (item.snapshot_before && typeof (item as any).snapshot_before === 'string') {
                try {
                    (item as any).snapshot_before = JSON.parse((item as any).snapshot_before);
                } catch (e) {
                    console.error('Error parsing snapshot_before', e);
                }
            }
            if (item.snapshot_after && typeof (item as any).snapshot_after === 'string') {
                try {
                    (item as any).snapshot_after = JSON.parse((item as any).snapshot_after);
                } catch (e) {
                    console.error('Error parsing snapshot_after', e);
                }
            }
            return item;
        });
    }
}
