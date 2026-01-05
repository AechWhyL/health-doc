import Router from '@koa/router';
import { InterventionPlanController } from '../controllers/interventionPlan.controller';
import { validateBody, validateParams, validateQuery } from '../middlewares/validation.middleware';
import {
  createInterventionPlanSchema,
  updateInterventionPlanSchema,
  updateInterventionPlanStatusSchema,
  queryInterventionPlanSchema,
  idParamSchema,
  elderUserIdParamSchema
} from '../dto/requests/interventionPlan.dto';

const router = new Router({
  prefix: '/api/v1/intervention'
});

router.post('/plans', validateBody(createInterventionPlanSchema), InterventionPlanController.createPlan);
router.get('/plans/:id', validateParams(idParamSchema), InterventionPlanController.getPlanById);
router.get(
  '/elders/:elderUserId/plans',
  validateParams(elderUserIdParamSchema),
  validateQuery(queryInterventionPlanSchema),
  InterventionPlanController.getPlansByElderUserId
);
router.put('/plans/:id', validateParams(idParamSchema), validateBody(updateInterventionPlanSchema), InterventionPlanController.updatePlan);
router.patch(
  '/plans/:id/status',
  validateParams(idParamSchema),
  validateBody(updateInterventionPlanStatusSchema),
  InterventionPlanController.updatePlanStatus
);

export default router;

