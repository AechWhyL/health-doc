import Router from '@koa/router';
import { MedicationController } from '../controllers/medication.controller';

const router = new Router({
  prefix: '/api/v1/elder-health'
});

router.post('/medication', MedicationController.createMedication);
router.get('/medication/:id', MedicationController.getMedicationById);
router.get('/medication/list', MedicationController.getMedicationList);
router.get('/medication/elder/:elder_id', MedicationController.getMedicationsByElderId);
router.put('/medication/:id', MedicationController.updateMedication);
router.delete('/medication/:id', MedicationController.deleteMedication);

export default router;
