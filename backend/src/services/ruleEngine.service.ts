import jsonLogic from 'json-logic-js';
import { ElderRepository } from '../repositories/elder.repository';
import { DailyHealthMeasurementRepository } from '../repositories/dailyHealthMeasurement.repository';
import {
  HealthIndicatorSummary,
  HealthRule,
  HealthRuleContext,
  HealthRuleResult,
  HealthStatusLevel,
  PersonalHealthRuleConfig
} from '../types/ruleEngine';
import { NotFoundError } from '../utils/errors';
import { PersonalHealthRuleService } from './personalHealthRule.service';

function calcAverage(values: (number | undefined)[]): number | null {
  const filtered = values.filter(v => v !== undefined) as number[];
  if (!filtered.length) {
    return null;
  }
  const sum = filtered.reduce((acc, v) => acc + v, 0);
  return sum / filtered.length;
}

function bpLevel(sbp?: number, dbp?: number): HealthStatusLevel | null {
  if (sbp === undefined && dbp === undefined) {
    return null;
  }
  const s = sbp ?? 0;
  const d = dbp ?? 0;

  if (s < 120 && d < 80) {
    return 'NORMAL';
  }
  if ((s >= 120 && s < 130) && d < 80) {
    return 'MILD';
  }
  if ((s >= 130 && s < 140) || (d >= 80 && d < 90)) {
    return 'MILD';
  }
  if ((s >= 140 && s <= 159) || (d >= 90 && d <= 99)) {
    return 'MODERATE';
  }
  if (s >= 160 || d >= 100) {
    return 'SEVERE';
  }
  return 'NORMAL';
}

function glucoseFpgLevel(fpg?: number): HealthStatusLevel | null {
  if (fpg === undefined) {
    return null;
  }
  if (fpg < 6.1) {
    return 'NORMAL';
  }
  if (fpg < 7.0) {
    return 'MILD';
  }
  if (fpg < 11.1) {
    return 'MODERATE';
  }
  return 'SEVERE';
}

function glucosePpgLevel(ppg?: number): HealthStatusLevel | null {
  if (ppg === undefined) {
    return null;
  }
  if (ppg < 7.8) {
    return 'NORMAL';
  }
  if (ppg < 11.1) {
    return 'MILD';
  }
  if (ppg < 16.7) {
    return 'MODERATE';
  }
  return 'SEVERE';
}

function stepsLevel(steps?: number): HealthStatusLevel | null {
  if (steps === undefined) {
    return null;
  }
  if (steps >= 8000) {
    return 'NORMAL';
  }
  if (steps >= 6000) {
    return 'MILD';
  }
  if (steps >= 4000) {
    return 'MODERATE';
  }
  return 'SEVERE';
}

const rules: HealthRule[] = [];

function buildIndicatorSummary(context: HealthRuleContext): HealthIndicatorSummary {
  const recent = context.measurements.slice(0, context.windowDays);
  const recentWithSbp = recent.filter(m => m.sbp !== undefined);
  const recentWithDbp = recent.filter(m => m.dbp !== undefined);
  const recentWithFpg = recent.filter(m => m.fpg !== undefined);
  const recentWithPpg2h = recent.filter(m => m.ppg_2h !== undefined);
  const recentWithSteps = recent.filter(m => m.steps !== undefined);
  const withWeight = recent.filter(m => m.weight !== undefined);

  const avgSbp = recentWithSbp.length ? calcAverage(recentWithSbp.map(m => m.sbp)) : null;
  const avgDbp = recentWithDbp.length ? calcAverage(recentWithDbp.map(m => m.dbp)) : null;
  const avgFpg = recentWithFpg.length ? calcAverage(recentWithFpg.map(m => m.fpg)) : null;
  const avgPpg2h = recentWithPpg2h.length ? calcAverage(recentWithPpg2h.map(m => m.ppg_2h)) : null;
  const avgSteps = recentWithSteps.length ? calcAverage(recentWithSteps.map(m => m.steps)) : null;

  let latestWeight: number | null = null;
  let earliestWeight: number | null = null;
  let weightDiff: number | null = null;

  if (withWeight.length >= 2) {
    const latest = withWeight[0];
    const earliest = withWeight[withWeight.length - 1];
    latestWeight = latest.weight ?? null;
    earliestWeight = earliest.weight ?? null;
    if (latestWeight !== null && earliestWeight !== null) {
      weightDiff = latestWeight - earliestWeight;
    }
  }

  return {
    avgSbp,
    avgDbp,
    avgFpg,
    avgPpg2h,
    avgSteps,
    latestWeight,
    earliestWeight,
    weightDiff
  };
}

function formatTemplate(template: string, variables: Record<string, string | number | null>): string {
  let result = template;
  Object.keys(variables).forEach(key => {
    const value = variables[key];
    const safeValue = value === null || value === undefined ? '' : String(value);
    result = result.replace(new RegExp(`{{\\s*${key}\\s*}}`, 'g'), safeValue);
  });
  return result;
}

function evaluatePersonalRules(context: HealthRuleContext, personalRules: PersonalHealthRuleConfig[]): HealthRuleResult[] {
  if (!personalRules.length) {
    return [];
  }
  const summary = buildIndicatorSummary(context);
  const data = {
    elder: context.elder,
    windowDays: context.windowDays,
    measurementsCount: context.measurements.length,
    indicators: summary
  };

  const results: HealthRuleResult[] = [];

  personalRules.forEach(ruleConfig => {
    if (!ruleConfig.isActive) {
      return;
    }
    if (ruleConfig.elderId && ruleConfig.elderId !== context.elder.id) {
      return;
    }
    try {
      const passed = jsonLogic.apply(ruleConfig.logic as jsonLogic.RulesLogic, data);
      if (passed) {
        const variables: Record<string, string | number | null> = {
          elderName: context.elder.name,
          windowDays: context.windowDays,
          avgSbp: summary.avgSbp,
          avgDbp: summary.avgDbp,
          avgFpg: summary.avgFpg,
          avgPpg2h: summary.avgPpg2h,
          avgSteps: summary.avgSteps,
          latestWeight: summary.latestWeight,
          earliestWeight: summary.earliestWeight,
          weightDiff: summary.weightDiff
        };
        const message =
          ruleConfig.messageTemplate !== undefined && ruleConfig.messageTemplate !== ''
            ? formatTemplate(ruleConfig.messageTemplate, variables)
            : ruleConfig.name;
        results.push({
          id: `P_${ruleConfig.id}`,
          name: ruleConfig.name,
          level: ruleConfig.level,
          message
        });
      }
    } catch {
      return;
    }
  });

  return results;
}

function defineRules(): HealthRule[] {
  const list: HealthRule[] = [];

  list.push({
    id: 'BP_AVG_7_DAYS',
    name: '最近7天平均血压水平',
    evaluate(context: HealthRuleContext): HealthRuleResult | null {
      const recent = context.measurements.slice(0, 7);
      if (!recent.length) {
        return null;
      }
      const avgSbp = calcAverage(recent.map(m => m.sbp));
      const avgDbp = calcAverage(recent.map(m => m.dbp));
      if (avgSbp === null && avgDbp === null) {
        return null;
      }
      const level = bpLevel(avgSbp ?? undefined, avgDbp ?? undefined) || 'NORMAL';
      const message = `最近7天平均血压约为收缩压${avgSbp?.toFixed(1) ?? '-'}、舒张压${avgDbp?.toFixed(1) ?? '-'}`;
      return {
        id: 'BP_AVG_7_DAYS',
        name: '最近7天平均血压水平',
        level,
        message
      };
    }
  });

  list.push({
    id: 'BP_HIGH_LOAD_7_DAYS',
    name: '最近7天高血压负荷',
    evaluate(context: HealthRuleContext): HealthRuleResult | null {
      const recent = context.measurements.slice(0, 7);
      if (!recent.length) {
        return null;
      }
      let highCount = 0;
      recent.forEach(m => {
        const level = bpLevel(m.sbp, m.dbp);
        if (level === 'MODERATE' || level === 'SEVERE') {
          highCount += 1;
        }
      });
      const ratio = highCount / recent.length;
      let level: HealthStatusLevel = 'NORMAL';
      if (ratio >= 0.1 && ratio < 0.3) {
        level = 'MILD';
      } else if (ratio >= 0.3 && ratio < 0.5) {
        level = 'MODERATE';
      } else if (ratio >= 0.5) {
        level = 'SEVERE';
      }
      if (level === 'NORMAL') {
        return {
          id: 'BP_HIGH_LOAD_7_DAYS',
          name: '最近7天高血压负荷',
          level,
          message: '最近7天血压整体控制良好，高血压天数较少'
        };
      }
      const message = `最近7天中有${highCount}天血压偏高，占比${(ratio * 100).toFixed(0)}%`;
      return {
        id: 'BP_HIGH_LOAD_7_DAYS',
        name: '最近7天高血压负荷',
        level,
        message
      };
    }
  });

  list.push({
    id: 'BP_LAST_READING',
    name: '最近一次血压读数',
    evaluate(context: HealthRuleContext): HealthRuleResult | null {
      const latest = context.measurements[0];
      if (!latest || (latest.sbp === undefined && latest.dbp === undefined)) {
        return null;
      }
      const level = bpLevel(latest.sbp, latest.dbp) || 'NORMAL';
      const message = `最近一次血压为收缩压${latest.sbp ?? '-'}、舒张压${latest.dbp ?? '-'}`;
      return {
        id: 'BP_LAST_READING',
        name: '最近一次血压读数',
        level,
        message
      };
    }
  });

  list.push({
    id: 'GLUCOSE_FPG_AVG_7_DAYS',
    name: '最近7天空腹血糖平均水平',
    evaluate(context: HealthRuleContext): HealthRuleResult | null {
      const recent = context.measurements.slice(0, 7).filter(m => m.fpg !== undefined);
      if (!recent.length) {
        return null;
      }
      const avg = calcAverage(recent.map(m => m.fpg));
      if (avg === null) {
        return null;
      }
      const level = glucoseFpgLevel(avg) || 'NORMAL';
      const message = `最近7天空腹血糖平均值约为${avg.toFixed(1)} mmol/L`;
      return {
        id: 'GLUCOSE_FPG_AVG_7_DAYS',
        name: '最近7天空腹血糖平均水平',
        level,
        message
      };
    }
  });

  list.push({
    id: 'GLUCOSE_PPG_AVG_7_DAYS',
    name: '最近7天餐后2小时血糖平均水平',
    evaluate(context: HealthRuleContext): HealthRuleResult | null {
      const recent = context.measurements.slice(0, 7).filter(m => m.ppg_2h !== undefined);
      if (!recent.length) {
        return null;
      }
      const avg = calcAverage(recent.map(m => m.ppg_2h));
      if (avg === null) {
        return null;
      }
      const level = glucosePpgLevel(avg) || 'NORMAL';
      const message = `最近7天餐后2小时血糖平均值约为${avg.toFixed(1)} mmol/L`;
      return {
        id: 'GLUCOSE_PPG_AVG_7_DAYS',
        name: '最近7天餐后2小时血糖平均水平',
        level,
        message
      };
    }
  });

  list.push({
    id: 'GLUCOSE_FPG_VARIATION',
    name: '最近7天空腹血糖波动',
    evaluate(context: HealthRuleContext): HealthRuleResult | null {
      const recent = context.measurements.slice(0, 7).filter(m => m.fpg !== undefined);
      if (recent.length < 2) {
        return null;
      }
      const values = recent.map(m => m.fpg!) as number[];
      const max = Math.max(...values);
      const min = Math.min(...values);
      const diff = max - min;
      let level: HealthStatusLevel = 'NORMAL';
      if (diff >= 2 && diff < 4) {
        level = 'MILD';
      } else if (diff >= 4 && diff < 6) {
        level = 'MODERATE';
      } else if (diff >= 6) {
        level = 'SEVERE';
      }
      if (level === 'NORMAL') {
        return {
          id: 'GLUCOSE_FPG_VARIATION',
          name: '最近7天空腹血糖波动',
          level,
          message: '最近7天空腹血糖波动较小'
        };
      }
      const message = `最近7天空腹血糖最高${max.toFixed(1)}、最低${min.toFixed(1)}，波动幅度${diff.toFixed(1)} mmol/L`;
      return {
        id: 'GLUCOSE_FPG_VARIATION',
        name: '最近7天空腹血糖波动',
        level,
        message
      };
    }
  });

  list.push({
    id: 'WEIGHT_TREND_30_DAYS',
    name: '最近30天体重变化趋势',
    evaluate(context: HealthRuleContext): HealthRuleResult | null {
      const withWeight = context.measurements.filter(m => m.weight !== undefined);
      if (withWeight.length < 2) {
        return null;
      }
      const latest = withWeight[0];
      const earliest = withWeight[withWeight.length - 1];
      const latestW = latest.weight!;
      const earliestW = earliest.weight!;
      const diff = latestW - earliestW;
      const absDiff = Math.abs(diff);

      let level: HealthStatusLevel = 'NORMAL';
      if (absDiff >= 2 && absDiff < 5) {
        level = 'MILD';
      } else if (absDiff >= 5 && absDiff < 10) {
        level = 'MODERATE';
      } else if (absDiff >= 10) {
        level = 'SEVERE';
      }

      if (level === 'NORMAL') {
        return {
          id: 'WEIGHT_TREND_30_DAYS',
          name: '最近30天体重变化趋势',
          level,
          message: '最近体重变化不大，较为稳定'
        };
      }

      const direction = diff > 0 ? '上升' : '下降';
      const message = `最近一段时间体重${direction}约${absDiff.toFixed(1)} kg（从${earliestW.toFixed(1)}到${latestW.toFixed(1)}）`;
      return {
        id: 'WEIGHT_TREND_30_DAYS',
        name: '最近30天体重变化趋势',
        level,
        message
      };
    }
  });

  list.push({
    id: 'STEPS_AVG_7_DAYS',
    name: '最近7天日均步数',
    evaluate(context: HealthRuleContext): HealthRuleResult | null {
      const recent = context.measurements.slice(0, 7).filter(m => m.steps !== undefined);
      if (!recent.length) {
        return null;
      }
      const avg = calcAverage(recent.map(m => m.steps));
      if (avg === null) {
        return null;
      }
      const level = stepsLevel(avg) || 'NORMAL';
      const message = `最近7天日均步数约为${avg.toFixed(0)}步`;
      return {
        id: 'STEPS_AVG_7_DAYS',
        name: '最近7天日均步数',
        level,
        message
      };
    }
  });

  list.push({
    id: 'STEPS_LOW_DAYS_7_DAYS',
    name: '最近7天活动不足天数',
    evaluate(context: HealthRuleContext): HealthRuleResult | null {
      const recent = context.measurements.slice(0, 7).filter(m => m.steps !== undefined);
      if (!recent.length) {
        return null;
      }
      let lowCount = 0;
      recent.forEach(m => {
        const level = stepsLevel(m.steps);
        if (level === 'MODERATE' || level === 'SEVERE') {
          lowCount += 1;
        }
      });
      const ratio = lowCount / recent.length;
      let level: HealthStatusLevel = 'NORMAL';
      if (ratio >= 0.3 && ratio < 0.5) {
        level = 'MILD';
      } else if (ratio >= 0.5 && ratio < 0.7) {
        level = 'MODERATE';
      } else if (ratio >= 0.7) {
        level = 'SEVERE';
      }
      if (level === 'NORMAL') {
        return {
          id: 'STEPS_LOW_DAYS_7_DAYS',
          name: '最近7天活动不足天数',
          level,
          message: '最近7天整体活动量还可以'
        };
      }
      const message = `最近7天中有${lowCount}天步数偏少，占比${(ratio * 100).toFixed(0)}%`;
      return {
        id: 'STEPS_LOW_DAYS_7_DAYS',
        name: '最近7天活动不足天数',
        level,
        message
      };
    }
  });

  return list;
}

if (!rules.length) {
  rules.push(...defineRules());
}

export class RuleEngineService {
  static async evaluateRulesForElder(elderId: number, windowDays: number): Promise<HealthRuleResult[]> {
    const elder = await ElderRepository.findById(elderId);
    if (!elder) {
      throw new NotFoundError('老人信息不存在');
    }

    const days = windowDays > 0 ? windowDays : 30;
    const measurements = await DailyHealthMeasurementRepository.findByElderInRecentDays(elderId, days);

    const context: HealthRuleContext = {
      elder,
      measurements,
      windowDays: days
    };

    const results: HealthRuleResult[] = [];
    rules.forEach(rule => {
      const result = rule.evaluate(context);
      if (result) {
        results.push(result);
      }
    });

    const personalRuleConfigs = await PersonalHealthRuleService.getActiveForElder(elderId);
    const personalRuleResults = evaluatePersonalRules(context, personalRuleConfigs);
    if (personalRuleResults.length) {
      results.push(...personalRuleResults);
    }

    return results;
  }
}
