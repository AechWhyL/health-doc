import Router from '@koa/router';
import { HealthRecordController } from '../controllers/healthRecord.controller';

import { authMiddleware } from '../middlewares/auth.middleware';

const router = new Router({
  prefix: '/api/v1/elder-health'
});

router.post('/health-record', authMiddleware, HealthRecordController.createHealthRecord);
router.get('/health-record/list', HealthRecordController.getHealthRecordList);
router.get('/health-record/elder/:elder_id', HealthRecordController.getHealthRecordsByElderId);
router.get('/health-record/:id', HealthRecordController.getHealthRecordById);
router.put('/health-record/:id', HealthRecordController.updateHealthRecord);
router.delete('/health-record/:id', HealthRecordController.deleteHealthRecord);

export default router;
