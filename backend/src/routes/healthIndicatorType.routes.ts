import Router from '@koa/router';
import { HealthIndicatorTypeController } from '../controllers/healthIndicatorType.controller';

const router = new Router({
  prefix: '/api/v1/health-data/indicator-types'
});

router.post('/', HealthIndicatorTypeController.createIndicatorType);
router.get('/', HealthIndicatorTypeController.getIndicatorTypes);
router.get('/:id', HealthIndicatorTypeController.getIndicatorTypeById);
router.put('/:id', HealthIndicatorTypeController.updateIndicatorType);
router.delete('/:id', HealthIndicatorTypeController.deleteIndicatorType);

export default router;
