import Router from '@koa/router';
import { AllergyController } from '../controllers/allergy.controller';

const router = new Router({
  prefix: '/api/v1/elder-health'
});

router.post('/allergy', AllergyController.createAllergy);
router.get('/allergy/:id', AllergyController.getAllergyById);
router.get('/allergy/list', AllergyController.getAllergyList);
router.get('/allergy/elder/:elder_id', AllergyController.getAllergiesByElderId);
router.put('/allergy/:id', AllergyController.updateAllergy);
router.delete('/allergy/:id', AllergyController.deleteAllergy);

export default router;
