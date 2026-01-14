import { Context } from 'koa';
import path from 'path';
import fs from 'fs';

const UPLOAD_ROOT = path.resolve(__dirname, '../../uploads');

export class FileController {
  /**
   * @swagger
   * /api/v1/files/upload:
   *   post:
   *     summary: 上传文件
   *     description: 上传文件到服务器本地目录并返回可访问URL
   *     tags: [文件管理]
   *     security:
   *       - bearerAuth: []
   *     requestBody:
   *       required: true
   *       content:
   *         multipart/form-data:
   *           schema:
   *             type: object
   *             required:
   *               - file
   *             properties:
   *               file:
   *                 type: string
   *                 format: binary
   *                 description: 要上传的文件
   *     responses:
   *       200:
   *         description: 上传成功
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 code:
   *                   type: integer
   *                   example: 200
   *                 message:
   *                   type: string
   *                   example: 文件上传成功
   *                 data:
   *                   type: object
   *                   properties:
   *                     files:
   *                       type: array
   *                       description: 上传成功的文件列表
   *                       items:
   *                         type: object
   *                         properties:
   *                           filename:
   *                             type: string
   *                             description: 服务器保存的文件名
   *                           url:
   *                             type: string
   *                             description: 静态访问URL(/uploads/前缀)
   *       400:
   *         description: 请求参数错误或未提供文件
   *       401:
   *         description: 未认证
   *       500:
   *         description: 服务器内部错误
   */
  static async uploadFile(ctx: Context): Promise<void> {
    const file = (ctx.request as any).files?.file;

    if (!file) {
      ctx.badRequest('未找到上传文件');
      return;
    }

    const fileArray = Array.isArray(file) ? file : [file];
    const savedFiles: string[] = [];

    if (!fs.existsSync(UPLOAD_ROOT)) {
      fs.mkdirSync(UPLOAD_ROOT, { recursive: true });
    }

    for (const item of fileArray) {
      const originalName = item.originalFilename || item.name || 'file';
      const ext = path.extname(originalName);
      const base = path.basename(originalName, ext);
      const safeBase = base.replace(/[^a-zA-Z0-9_-]/g, '_');
      let filename = `${safeBase}${ext}`;
      let targetPath = path.join(UPLOAD_ROOT, filename);
      let counter = 1;

      while (fs.existsSync(targetPath)) {
        filename = `${safeBase}_${counter}${ext}`;
        targetPath = path.join(UPLOAD_ROOT, filename);
        counter += 1;
      }

      const readStream = fs.createReadStream(item.filepath || item.path);
      const writeStream = fs.createWriteStream(targetPath);

      await new Promise<void>((resolve, reject) => {
        readStream.on('error', reject);
        writeStream.on('error', reject);
        writeStream.on('finish', () => resolve());
        readStream.pipe(writeStream);
      });

      savedFiles.push(filename);
    }

    ctx.success(
      {
        files: savedFiles.map(name => ({
          filename: name,
          url: `/uploads/${name}`
        }))
      },
      '文件上传成功'
    );
  }

  /**
   * @swagger
   * /api/v1/files/download/{filename}:
   *   get:
   *     summary: 下载文件
   *     description: 根据文件名从本地目录下载文件
   *     tags: [文件管理]
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - in: path
   *         name: filename
   *         required: true
   *         schema:
   *           type: string
   *         description: 服务器保存的文件名
   *     responses:
   *       200:
   *         description: 文件流
   *         content:
   *           application/octet-stream:
   *             schema:
   *               type: string
   *               format: binary
   *       400:
   *         description: 缺少文件名参数
   *       401:
   *         description: 未认证
   *       404:
   *         description: 文件不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async downloadFile(ctx: Context): Promise<void> {
    const { filename } = ctx.params;

    if (!filename) {
      ctx.badRequest('缺少文件名参数');
      return;
    }

    const filePath = path.join(UPLOAD_ROOT, filename);

    if (!fs.existsSync(filePath)) {
      ctx.notFound('文件不存在');
      return;
    }

    ctx.set('Content-Disposition', `attachment; filename="${encodeURIComponent(filename)}"`);
    ctx.type = path.extname(filename) || 'application/octet-stream';
    ctx.body = fs.createReadStream(filePath);
  }
}
