import Router from '@koa/router';
import { ElderController } from '../controllers/elder.controller';

const router = new Router({
  prefix: '/api/v1/elder-health'
});

router.post('/elder', ElderController.createElder);
router.get('/elder/:id', ElderController.getElderById);
router.get('/elder/list', ElderController.getElderList);
router.put('/elder/:id', ElderController.updateElder);
router.delete('/elder/:id', ElderController.deleteElder);

export default router;
