import Router from '@koa/router';
import { InterventionPlanItemController } from '../controllers/interventionPlanItem.controller';
import { validateBody, validateParams, validateQuery } from '../middlewares/validation.middleware';
import {
  createPlanItemSchema,
  updatePlanItemSchema,
  planIdParamSchema,
  planItemIdParamSchema,
  queryPlanItemSchema,
  updatePlanItemStatusSchema,
  createPlanItemScheduleSchema,
  updatePlanItemScheduleSchema,
  scheduleIdParamSchema,
  createTaskInstancesSchema,
  queryPlanTaskInstanceSchema,
  taskIdParamSchema,
  updateTaskInstanceStatusSchema
} from '../dto/requests/interventionPlanItem.dto';

import { authMiddleware as auth } from '../middlewares/auth.middleware';

const router = new Router({
  prefix: '/api/v1/intervention'
});

router.post(
  '/plans/:planId/items',
  auth,
  validateParams(planIdParamSchema),
  validateBody(createPlanItemSchema),
  InterventionPlanItemController.createPlanItem
);

router.get(
  '/plans/:planId/items',
  auth,
  validateParams(planIdParamSchema),
  validateQuery(queryPlanItemSchema),
  InterventionPlanItemController.getPlanItemsByPlanId
);

router.get(
  '/items/:itemId',
  auth,
  validateParams(planItemIdParamSchema),
  InterventionPlanItemController.getPlanItemById
);

router.put(
  '/items/:itemId',
  auth,
  validateParams(planItemIdParamSchema),
  validateBody(updatePlanItemSchema),
  InterventionPlanItemController.updatePlanItem
);

router.post(
  '/items/:itemId/status',
  auth,
  validateParams(planItemIdParamSchema),
  validateBody(updatePlanItemStatusSchema),
  InterventionPlanItemController.updatePlanItemStatus
);

router.delete(
  '/items/:itemId',
  auth,
  validateParams(planItemIdParamSchema),
  InterventionPlanItemController.deletePlanItem
);

router.post(
  '/items/:itemId/schedules',
  auth,
  validateParams(planItemIdParamSchema),
  validateBody(createPlanItemScheduleSchema),
  InterventionPlanItemController.createPlanItemSchedule
);

router.get(
  '/items/:itemId/schedules',
  auth,
  validateParams(planItemIdParamSchema),
  InterventionPlanItemController.getPlanItemSchedules
);

router.put(
  '/schedules/:scheduleId',
  auth,
  validateParams(scheduleIdParamSchema),
  validateBody(updatePlanItemScheduleSchema),
  InterventionPlanItemController.updatePlanItemSchedule
);

router.delete(
  '/schedules/:scheduleId',
  auth,
  validateParams(scheduleIdParamSchema),
  InterventionPlanItemController.deletePlanItemSchedule
);

router.post(
  '/schedules/:scheduleId/tasks/generate',
  auth,
  validateParams(scheduleIdParamSchema),
  validateBody(createTaskInstancesSchema),
  InterventionPlanItemController.generateTaskInstancesForSchedule
);

router.get(
  '/elder/today-tasks',
  auth,
  InterventionPlanItemController.getElderTodayTasks
);

router.get(
  '/stats/today',
  auth,
  InterventionPlanItemController.getTodayTaskStats
);

router.get(
  '/items/:itemId/tasks',
  auth,
  validateParams(planItemIdParamSchema),
  validateQuery(queryPlanTaskInstanceSchema),
  InterventionPlanItemController.getTaskInstancesByItemId
);

router.post(
  '/check-in',
  auth,
  InterventionPlanItemController.checkIn
);

router.get(
  '/tasks/:taskId',
  auth,
  validateParams(taskIdParamSchema),
  InterventionPlanItemController.getTaskInstanceById
);

router.patch(
  '/tasks/:taskId/status',
  validateParams(taskIdParamSchema),
  validateBody(updateTaskInstanceStatusSchema),
  InterventionPlanItemController.updateTaskInstanceStatus
);

export default router;
