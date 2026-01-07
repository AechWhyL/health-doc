import Router from '@koa/router';
import { NotificationController } from '../controllers/notification.controller';
import { authMiddleware } from '../middlewares/auth.middleware';
import { validateParams, validateQuery } from '../middlewares/validation.middleware';
import {
  notificationIdParamSchema,
  queryNotificationSchema
} from '../dto/requests/notification.dto';

const router = new Router({
  prefix: '/api/v1/notifications'
});

router.get(
  '/',
  authMiddleware,
  validateQuery(queryNotificationSchema),
  NotificationController.getNotificationList
);

router.patch(
  '/:id/read',
  authMiddleware,
  validateParams(notificationIdParamSchema),
  NotificationController.markAsRead
);

export default router;

