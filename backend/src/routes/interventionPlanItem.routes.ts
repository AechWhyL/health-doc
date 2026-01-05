import Router from '@koa/router';
import { InterventionPlanItemController } from '../controllers/interventionPlanItem.controller';
import { validateBody, validateParams, validateQuery } from '../middlewares/validation.middleware';
import {
  createPlanItemSchema,
  updatePlanItemSchema,
  planIdParamSchema,
  planItemIdParamSchema,
  queryPlanItemSchema,
  createPlanItemScheduleSchema,
  updatePlanItemScheduleSchema,
  scheduleIdParamSchema,
  createTaskInstancesSchema,
  queryPlanTaskInstanceSchema,
  taskIdParamSchema,
  updateTaskInstanceStatusSchema
} from '../dto/requests/interventionPlanItem.dto';

const router = new Router({
  prefix: '/api/v1/intervention'
});

router.post(
  '/plans/:planId/items',
  validateParams(planIdParamSchema),
  validateBody(createPlanItemSchema),
  InterventionPlanItemController.createPlanItem
);

router.get(
  '/plans/:planId/items',
  validateParams(planIdParamSchema),
  validateQuery(queryPlanItemSchema),
  InterventionPlanItemController.getPlanItemsByPlanId
);

router.get(
  '/items/:itemId',
  validateParams(planItemIdParamSchema),
  InterventionPlanItemController.getPlanItemById
);

router.put(
  '/items/:itemId',
  validateParams(planItemIdParamSchema),
  validateBody(updatePlanItemSchema),
  InterventionPlanItemController.updatePlanItem
);

router.patch(
  '/items/:itemId/status',
  validateParams(planItemIdParamSchema),
  validateBody(
    queryPlanItemSchema.keys({
      status: queryPlanItemSchema.extract('status').required()
    })
  ),
  InterventionPlanItemController.updatePlanItemStatus
);

router.delete(
  '/items/:itemId',
  validateParams(planItemIdParamSchema),
  InterventionPlanItemController.deletePlanItem
);

router.post(
  '/items/:itemId/schedules',
  validateParams(planItemIdParamSchema),
  validateBody(createPlanItemScheduleSchema),
  InterventionPlanItemController.createPlanItemSchedule
);

router.get(
  '/items/:itemId/schedules',
  validateParams(planItemIdParamSchema),
  InterventionPlanItemController.getPlanItemSchedules
);

router.put(
  '/schedules/:scheduleId',
  validateParams(scheduleIdParamSchema),
  validateBody(updatePlanItemScheduleSchema),
  InterventionPlanItemController.updatePlanItemSchedule
);

router.delete(
  '/schedules/:scheduleId',
  validateParams(scheduleIdParamSchema),
  InterventionPlanItemController.deletePlanItemSchedule
);

router.post(
  '/schedules/:scheduleId/tasks/generate',
  validateParams(scheduleIdParamSchema),
  validateBody(createTaskInstancesSchema),
  InterventionPlanItemController.generateTaskInstancesForSchedule
);

router.get(
  '/items/:itemId/tasks',
  validateParams(planItemIdParamSchema),
  validateQuery(queryPlanTaskInstanceSchema),
  InterventionPlanItemController.getTaskInstancesByItemId
);

router.patch(
  '/tasks/:taskId/status',
  validateParams(taskIdParamSchema),
  validateBody(updateTaskInstanceStatusSchema),
  InterventionPlanItemController.updateTaskInstanceStatus
);

export default router;
