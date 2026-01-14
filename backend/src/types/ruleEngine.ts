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

export interface PersonalHealthRuleConfig {
  id: string;
  name: string;
  elderId?: number;
  level: HealthStatusLevel;
  logic: unknown;
  messageTemplate?: string;
  isActive: boolean;
}

export interface HealthIndicatorSummary {
  avgSbp: number | null;
  avgDbp: number | null;
  avgFpg: number | null;
  avgPpg2h: number | null;
  avgSteps: number | null;
  latestWeight: number | null;
  earliestWeight: number | null;
  weightDiff: number | null;
}

export interface PersonalHealthRuleRecord {
  id: number;
  elder_id: number | null;
  name: string;
  level: HealthStatusLevel;
  logic: unknown;
  message_template: string | null;
  is_active: number;
  created_by_user_id: number | null;
  created_at?: string;
  updated_at?: string;
}
