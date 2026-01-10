import Router from '@koa/router';
import { UserController } from '../controllers/user.controller';
import { authMiddleware } from '../middlewares/auth.middleware';
import { validateBody, validateQuery, validateParams } from '../middlewares/validation.middleware';
import {
  createUserSchema,
  updateUserSchema,
  queryUserSchema,
  loginSchema,
  changePasswordSchema,
  idParamSchema,
  queryUserEldersSchema,
  createUserElderRelationSchema,
  userElderRelationIdParamSchema
} from '../dto/requests/user.dto';

const router = new Router({
  prefix: '/api/v1/users'
});

router.post('/login', validateBody(loginSchema), UserController.login);

router.post('/', validateBody(createUserSchema), UserController.createUser);
router.get('/current', authMiddleware, UserController.getCurrentUser);
router.get(
  '/me/elders',
  authMiddleware,
  validateQuery(queryUserEldersSchema),
  UserController.getMyElders
);
router.post(
  '/me/elders',
  authMiddleware,
  validateBody(createUserElderRelationSchema),
  UserController.addMyElder
);
router.delete(
  '/me/elders/:relationId',
  authMiddleware,
  validateParams(userElderRelationIdParamSchema),
  UserController.deleteMyElder
);
router.get('/:id', validateParams(idParamSchema), UserController.getUserById);
router.get('/', validateQuery(queryUserSchema), UserController.getUserList);
router.put('/:id', validateParams(idParamSchema), validateBody(updateUserSchema), UserController.updateUser);
router.delete('/:id', validateParams(idParamSchema), UserController.deleteUser);
router.post('/:id/change-password', authMiddleware, validateParams(idParamSchema), validateBody(changePasswordSchema), UserController.changePassword);
router.get('/:id/roles', validateParams(idParamSchema), UserController.getUserRoles);

export default router;
