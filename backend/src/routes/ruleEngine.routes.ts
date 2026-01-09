import Router from '@koa/router';
import { RuleEngineController } from '../controllers/ruleEngine.controller';
import { validateQuery } from '../middlewares/validation.middleware';
import { evaluateRulesQuerySchema } from '../dto/requests/ruleEngine.dto';

const router = new Router({
  prefix: '/api/v1/elder-health/rules'
});

router.get(
  '/evaluate',
  validateQuery(evaluateRulesQuerySchema),
  RuleEngineController.evaluateRules
);

export default router;

