import Router from '@koa/router';
import { RoleController } from '../controllers/role.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = new Router({
  prefix: '/api/v1/roles'
});

router.post('/', authMiddleware, RoleController.createRole);
router.get('/:id', RoleController.getRoleById);
router.get('/', RoleController.getRoleList);
router.put('/:id', authMiddleware, RoleController.updateRole);
router.delete('/:id', authMiddleware, RoleController.deleteRole);
router.post('/users/:userId/roles/:roleId', authMiddleware, RoleController.assignRoleToUser);
router.delete('/users/:userId/roles/:roleId', authMiddleware, RoleController.removeRoleFromUser);
router.put('/users/:id/roles', authMiddleware, RoleController.updateUserRoles);
router.get('/users/:id/roles', RoleController.getUserRoles);

export default router;
