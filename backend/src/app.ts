import Koa from 'koa';
import { createServer } from 'http';
import cors from '@koa/cors';
import helmet from 'koa-helmet';
import logger from 'koa-logger';
import serve from 'koa-static';
import path from 'path';
import { HttpMethodEnum, koaBody } from 'koa-body';
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
  },
  parsedMethods: [HttpMethodEnum.POST, HttpMethodEnum.PUT]
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

RoleService.ensureDefaultRoles()
  .then(() => {
    console.log('默认角色已初始化');
  })
  .catch((error) => {
    console.error('初始化默认角色失败', error);
  });

const httpServer = createServer(app.callback());
initSocketServer(httpServer);

// 初始化定时任务调度器
import('./services/taskScheduler').then(({ TaskScheduler }) => {
  TaskScheduler.init();
  console.log('定时任务调度器已初始化');
}).catch((error) => {
  console.error('初始化定时任务调度器失败', error);
});


httpServer.listen(config.PORT, () => {
  console.log(`HTTP 服务器已启动，运行在 http://localhost:${config.PORT}`);
  console.log(`当前环境: ${config.NODE_ENV}`);
});

export default app;
