import Router from '@koa/router';
import { FamilyController } from '../controllers/family.controller';
import { validateBody, validateQuery, validateParams } from '../middlewares/validation.middleware';
import { createFamilySchema, updateFamilySchema, queryFamilySchema, idParamSchema, userIdParamSchema } from '../dto/requests/family.dto';

const router = new Router({
    prefix: '/api/v1/family'
});

router.post('/profile', validateBody(createFamilySchema), FamilyController.createFamily);
router.get('/profile/list', validateQuery(queryFamilySchema), FamilyController.getFamilyList);
router.get('/profile/user/:user_id', validateParams(userIdParamSchema), FamilyController.getFamilyByUserId);
router.get('/profile/:id', validateParams(idParamSchema), FamilyController.getFamilyById);
router.put('/profile/:id', validateParams(idParamSchema), validateBody(updateFamilySchema), FamilyController.updateFamily);
router.delete('/profile/:id', validateParams(idParamSchema), FamilyController.deleteFamily);

export default router;
