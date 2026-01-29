import { HealthRecordService } from '../src/services/healthRecord.service';
import { HealthRecordHistoryRepository } from '../src/repositories/healthRecordHistory.repository';
import { CreateHealthRecordRequest, UpdateHealthRecordRequest } from '../src/dto/requests/healthRecord.dto';
import { Database } from '../src/config/database';

async function testHistory() {
    console.log('--- Starting Verification ---');

    // Get a valid user
    const user = await Database.queryOne('SELECT id FROM users LIMIT 1');
    if (!user) {
        console.error('No users found in database. Cannot verify.');
        process.exit(1);
        return;
    }
    const operatorId = user.id;

    // Get a valid elder
    let elderId = 1;
    const existingRecord = await Database.queryOne('SELECT elder_id FROM health_record LIMIT 1');
    if (existingRecord) {
        elderId = existingRecord.elder_id;
    } else {
        try {
            // Try common table names for elder info if health_record table is empty
            const elderRow = await Database.queryOne('SELECT id FROM elders LIMIT 1'); // Guessing table name
            if (elderRow) elderId = elderRow.id;
        } catch (e) {
            // Fallback to 1 and hope for the best if we can't find one.
            // Or insert a dummy elder if we knew the table schema.
        }
    }

    console.log(`Using Operator ID: ${operatorId}, Elder ID: ${elderId}`);

    try {
        // 1. Create a record
        console.log('1. Creating a new health record...');
        const createData: CreateHealthRecordRequest = {
            elder_id: elderId,
            record_type: 'MEDICAL_HISTORY',
            record_title: 'Test History Record',
            record_date: '2024-01-29',
            content_structured: {
                disease_name: 'Test Disease',
                diagnosed_at: '2024-01-01',
                status: 'ONGOING'
            },
            creator_id: operatorId
        };

        const newRecord = await HealthRecordService.createHealthRecord(createData);
        console.log('Created Record ID:', newRecord.id);

        // Verify ADD history
        let history = await HealthRecordService.getHealthRecordHistory(newRecord.id);
        console.log('History after creation:', history.length);
        if (history.length === 1 && history[0].operation_type === 'ADD') {
            console.log('✅ ADD history recorded successfully.');
        } else {
            console.error('❌ ADD history verification failed.');
        }

        // 2. Update the record
        console.log('\n2. Updating the health record...');
        const updateData: UpdateHealthRecordRequest = {
            record_title: 'Updated Title'
        };

        await HealthRecordService.updateHealthRecord(newRecord.id, updateData, operatorId);
        console.log('Record updated.');

        // Verify MODIFY history
        history = await HealthRecordService.getHealthRecordHistory(newRecord.id);
        console.log('History after update:', history.length);

        const modifyRecord = history.find(h => h.operation_type === 'MODIFY');
        if (modifyRecord) {
            console.log('✅ MODIFY history recorded successfully.');
            // Need to cast to any to access dynamic JSON properties if types are strict
            const snapshotBefore = (modifyRecord as any).snapshot_before;
            const snapshotAfter = (modifyRecord as any).snapshot_after;

            console.log('Snapshot Before Title:', snapshotBefore?.record_title);
            console.log('Snapshot After Title:', snapshotAfter?.record_title);

            if (snapshotBefore?.record_title === 'Test History Record' &&
                snapshotAfter?.record_title === 'Updated Title') {
                console.log('✅ Snapshots are correct.');
            } else {
                console.error('❌ Snapshot content incorrect.');
            }
        } else {
            console.error('❌ MODIFY history verification failed.');
        }

        process.exit(0);

    } catch (error) {
        console.error('Error during verification:', error);
        process.exit(1);
    }
}

testHistory();
