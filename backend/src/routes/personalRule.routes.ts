import Router from '@koa/router';
import { PersonalRuleController } from '../controllers/personalRule.controller';
import { validateBody, validateQuery } from '../middlewares/validation.middleware';
import { createPersonalRuleSchema, updatePersonalRuleSchema, queryPersonalRuleSchema } from '../dto/requests/personalRule.dto';

const router = new Router({
  prefix: '/api/v1/elder-health/personal-rules'
});

router.get('/', validateQuery(queryPersonalRuleSchema), PersonalRuleController.list);
router.post('/', validateBody(createPersonalRuleSchema), PersonalRuleController.create);
router.put('/:id', validateBody(updatePersonalRuleSchema), PersonalRuleController.update);
router.delete('/:id', PersonalRuleController.delete);

export default router;

