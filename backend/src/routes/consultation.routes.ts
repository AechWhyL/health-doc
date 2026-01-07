import Router from '@koa/router';
import { ConsultationController } from '../controllers/consultation.controller';
import {
  createConsultationQuestionSchema,
  queryConsultationQuestionSchema,
  idParamSchema,
  createConsultationMessageSchema,
  queryConsultationMessageSchema
} from '../dto/requests/consultation.dto';
import { validateBody, validateParams, validateQuery } from '../middlewares/validation.middleware';

const router = new Router({
  prefix: '/api/v1/consultation'
});

router.post(
  '/questions',
  validateBody(createConsultationQuestionSchema),
  ConsultationController.createQuestion
);

router.get(
  '/questions',
  validateQuery(queryConsultationQuestionSchema),
  ConsultationController.getQuestionList
);

router.get(
  '/questions/:id',
  validateParams(idParamSchema),
  ConsultationController.getQuestionById
);

router.post(
  '/questions/:id/messages',
  validateParams(idParamSchema),
  validateBody(createConsultationMessageSchema),
  ConsultationController.createMessage
);

router.get(
  '/questions/:id/messages',
  validateParams(idParamSchema),
  validateQuery(queryConsultationMessageSchema),
  ConsultationController.getMessageList
);

export default router;

