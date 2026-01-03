import Router from '@koa/router';
import { ElderController } from '../controllers/elder.controller';
import { validateBody, validateQuery, validateParams } from '../middlewares/validation.middleware';
import { createElderSchema, updateElderSchema, queryElderSchema, idParamSchema } from '../dto/requests/elder.dto';

const router = new Router({
  prefix: '/api/v1/elder-health'
});

router.post('/elder', validateBody(createElderSchema), ElderController.createElder);
router.get('/elder/list', validateQuery(queryElderSchema), ElderController.getElderList);
router.get('/elder/:id', validateParams(idParamSchema), ElderController.getElderById);
router.put('/elder/:id', validateParams(idParamSchema), validateBody(updateElderSchema), ElderController.updateElder);
router.delete('/elder/:id', validateParams(idParamSchema), ElderController.deleteElder);

export default router;
