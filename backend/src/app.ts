import Koa from 'koa';
import { createServer } from 'http';
import cors from '@koa/cors';
import helmet from 'koa-helmet';
import logger from 'koa-logger';
import serve from 'koa-static';
import path from 'path';
import { koaBody } from 'koa-body';
import { koaSwagger } from 'koa2-swagger-ui';
import config from './config/env';
import { responseFormatter } from './middlewares/responseFormatter';
import routes from './routes';
import { swaggerSpec } from './config/swagger';
import { RoleService } from './services/role.service';
import { initSocketServer } from './realtime/socket';

const app = new Koa();

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'", 'https://cdnjs.cloudflare.com'],
      styleSrc: ["'self'", "'unsafe-inline'", 'https://cdnjs.cloudflare.com', 'https://fonts.googleapis.com'],
      imgSrc: ["'self'", 'data:', 'https:'],
      connectSrc: ["'self'"],
      fontSrc: ["'self'", 'https://cdnjs.cloudflare.com', 'https://fonts.gstatic.com'],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
    },
  },
}));
app.use(cors());
app.use(logger());

const uploadsRoot = path.resolve(__dirname, '../uploads');

app.use(koaBody({
  multipart: true,
  urlencoded: true,
  json: true,
  formidable: {
    uploadDir: uploadsRoot,
    keepExtensions: true
  }
}));

app.use(responseFormatter);

app.use(serve(uploadsRoot, {
  maxage: 7 * 24 * 60 * 60 * 1000,
  index: false
}));

app.use(koaSwagger({
  routePrefix: '/swagger',
  swaggerOptions: {
    spec: swaggerSpec as Record<string, unknown>,
  },
}));

routes.forEach(router => {
  app.use(router.routes()).use(router.allowedMethods());
});

app.use(async (ctx) => {
  if (ctx.path === '/api/health') {
    ctx.success({ status: 'ok', version: '1.0.0' }, '健康检查成功');
  } else if (ctx.path === '/api/test/error') {
    ctx.error('测试错误响应', 400);
  } else if (ctx.path === '/api/test/paginate') {
    const mockData = [
      { id: 1, name: '测试数据1' },
      { id: 2, name: '测试数据2' },
      { id: 3, name: '测试数据3' },
      { id: 4, name: '测试数据4' },
      { id: 5, name: '测试数据5' }
    ];
    ctx.paginate(mockData, 1, 10, 50, '分页数据获取成功');
  }
});

RoleService.ensureDefaultRoles()
  .then(() => {
    console.log('默认角色已初始化');
  })
  .catch((error) => {
    console.error('初始化默认角色失败', error);
  });

const httpServer = createServer(app.callback());
initSocketServer(httpServer);

httpServer.listen(config.PORT, () => {
  console.log(`HTTP 服务器已启动，运行在 http://localhost:${config.PORT}`);
  console.log(`当前环境: ${config.NODE_ENV}`);
});

export default app;
