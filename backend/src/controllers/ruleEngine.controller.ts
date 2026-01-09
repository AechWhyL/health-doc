import { Context } from 'koa';
import { RuleEngineService } from '../services/ruleEngine.service';
import { EvaluateRulesQuery } from '../dto/requests/ruleEngine.dto';

export class RuleEngineController {
  /**
   * @swagger
   * /api/v1/elder-health/rules/evaluate:
   *   get:
   *     summary: 评估老人近期健康数据规则
   *     description: 基于最近一段时间的日常健康数据，对血压、血糖、体重、步数等进行规则评估
   *     tags: [健康规则评估]
   *     parameters:
   *       - in: query
   *         name: elder_id
   *         required: true
   *         schema:
   *           type: integer
   *         description: 老人ID
   *         example: 1
   *       - in: query
   *         name: windowDays
   *         required: false
   *         schema:
   *           type: integer
   *           default: 30
   *         description: 向前统计的天数窗口，默认30天
   *     responses:
   *       200:
   *         description: 评估成功
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
   *                   example: success
   *                 data:
   *                   type: array
   *                   items:
   *                     type: object
   *                     properties:
   *                       id:
   *                         type: string
   *                         description: 规则ID
   *                         example: BP_AVG_7_DAYS
   *                       name:
   *                         type: string
   *                         description: 规则名称
   *                         example: 最近7天平均血压水平
   *                       level:
   *                         type: string
   *                         description: 评估结果等级
   *                         enum: [NORMAL, MILD, MODERATE, SEVERE]
   *                         example: MILD
   *                       message:
   *                         type: string
   *                         description: 人类可读的结果描述
   *                         example: 最近7天平均血压约为收缩压130.5、舒张压82.3
   *       400:
   *         description: 请求参数错误
   *       404:
   *         description: 老人信息不存在
   *       500:
   *         description: 服务器内部错误
   */
  static async evaluateRules(ctx: Context) {
    const data: EvaluateRulesQuery = ctx.state.validatedData || ctx.query;
    const elderId = Number(data.elder_id);
    const windowDays = data.windowDays ?? 30;
    const result = await RuleEngineService.evaluateRulesForElder(elderId, windowDays);
    ctx.success(result);
  }
}

