import Router from '@koa/router';
import { UserController } from '../controllers/user.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = new Router({
  prefix: '/api/v1/users'
});

router.post('/login', UserController.login);

router.post('/', UserController.createUser);
router.get('/current', authMiddleware, UserController.getCurrentUser);
router.get('/:id', UserController.getUserById);
router.get('/', UserController.getUserList);
router.put('/:id', UserController.updateUser);
router.delete('/:id', UserController.deleteUser);
router.post('/:id/change-password', authMiddleware, UserController.changePassword);
router.get('/:id/roles', UserController.getUserRoles);

export default router;
