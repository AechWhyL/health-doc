import Router from '@koa/router';
import { DailyHealthMeasurementController } from '../controllers/dailyHealthMeasurement.controller';
import { validateBody, validateQuery, validateParams } from '../middlewares/validation.middleware';
import { authMiddleware } from '../middlewares/auth.middleware';
import {
  createDailyHealthMeasurementSchema,
  updateDailyHealthMeasurementSchema,
  queryDailyHealthMeasurementSchema,
  idParamSchema
} from '../dto/requests/dailyHealthMeasurement.dto';

const router = new Router({
  prefix: '/api/v1/elder-health/daily-health'
});

router.post(
  '/',
  authMiddleware,
  validateBody(createDailyHealthMeasurementSchema),
  DailyHealthMeasurementController.createDailyHealthMeasurement
);

router.get(
  '/list',
  validateQuery(queryDailyHealthMeasurementSchema),
  DailyHealthMeasurementController.getDailyHealthMeasurementList
);

router.get(
  '/:id',
  validateParams(idParamSchema),
  DailyHealthMeasurementController.getDailyHealthMeasurementById
);

router.put(
  '/:id',
  validateParams(idParamSchema),
  validateBody(updateDailyHealthMeasurementSchema),
  DailyHealthMeasurementController.updateDailyHealthMeasurement
);

router.delete(
  '/:id',
  validateParams(idParamSchema),
  DailyHealthMeasurementController.deleteDailyHealthMeasurement
);

export default router;
