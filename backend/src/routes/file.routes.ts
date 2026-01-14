import Router from '@koa/router';
import { FileController } from '../controllers/file.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = new Router({
  prefix: '/api/v1/files'
});

router.post('/upload', authMiddleware, FileController.uploadFile);
router.get('/download/:filename', authMiddleware, FileController.downloadFile);

export default router;

