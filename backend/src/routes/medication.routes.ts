import Router from '@koa/router';
import { MedicationController } from '../controllers/medication.controller';
import { validateBody, validateQuery, validateParams } from '../middlewares/validation.middleware';
import { createMedicationSchema, updateMedicationSchema, queryMedicationSchema, idParamSchema, elderIdParamSchema } from '../dto/requests/medication.dto';

const router = new Router({
  prefix: '/api/v1/elder-health'
});

router.post('/medication', validateBody(createMedicationSchema), MedicationController.createMedication);
router.get('/medication/:id', validateParams(idParamSchema), MedicationController.getMedicationById);
router.get('/medication/list', validateQuery(queryMedicationSchema), MedicationController.getMedicationList);
router.get('/medication/elder/:elder_id', validateParams(elderIdParamSchema), MedicationController.getMedicationsByElderId);
router.put('/medication/:id', validateParams(idParamSchema), validateBody(updateMedicationSchema), MedicationController.updateMedication);
router.delete('/medication/:id', validateParams(idParamSchema), MedicationController.deleteMedication);

export default router;
