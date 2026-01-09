import { ElderBasicInfo } from './healthRecord';
import { DailyHealthMeasurement } from './dailyHealthMeasurement';

export type HealthStatusLevel = 'NORMAL' | 'MILD' | 'MODERATE' | 'SEVERE';

export interface HealthRuleContext {
  elder: ElderBasicInfo;
  measurements: DailyHealthMeasurement[];
  windowDays: number;
}

export interface HealthRuleResult {
  id: string;
  name: string;
  level: HealthStatusLevel;
  message: string;
}

export interface HealthRule {
  id: string;
  name: string;
  description?: string;
  evaluate(context: HealthRuleContext): HealthRuleResult | null;
}
