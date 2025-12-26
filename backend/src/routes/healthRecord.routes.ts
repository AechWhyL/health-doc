import Router from '@koa/router';
import { HealthRecordController } from '../controllers/healthRecord.controller';

const router = new Router({
  prefix: '/api/v1/elder-health'
});

router.post('/health-record', HealthRecordController.createHealthRecord);
router.get('/health-record/:id', HealthRecordController.getHealthRecordById);
router.get('/health-record/list', HealthRecordController.getHealthRecordList);
router.get('/health-record/elder/:elder_id', HealthRecordController.getHealthRecordsByElderId);
router.put('/health-record/:id', HealthRecordController.updateHealthRecord);
router.delete('/health-record/:id', HealthRecordController.deleteHealthRecord);

export default router;
