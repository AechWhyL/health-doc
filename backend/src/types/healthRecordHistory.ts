export type OperationType = 'ADD' | 'MODIFY';

export interface HealthRecordHistory {
    id?: number;
    health_record_id: number;
    operator_id: number;
    operator_name?: string; // Joined from users table
    operation_type: OperationType;
    snapshot_before?: any; // JSON
    snapshot_after: any; // JSON
    created_at?: string;
}
