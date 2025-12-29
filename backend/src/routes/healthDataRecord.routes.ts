import Router from '@koa/router';
import { HealthDataRecordController } from '../controllers/healthDataRecord.controller';

const router = new Router({
  prefix: '/api/v1/health-data/records'
});

router.post('/', HealthDataRecordController.createHealthDataRecord);
router.get('/', HealthDataRecordController.getHealthDataRecords);
router.get('/:id', HealthDataRecordController.getHealthDataRecordById);
router.put('/:id', HealthDataRecordController.updateHealthDataRecord);
router.delete('/:id', HealthDataRecordController.deleteHealthDataRecord);
router.get('/:id/history', HealthDataRecordController.getHealthDataRecordHistory);

export default router;
