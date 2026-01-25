import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';
import { ElderCard } from '../../components/family/ElderCard';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

interface ElderResponse {
  id: number;
  user_id: number;
  name: string;
  gender: number;
  birth_date: string;
  phone: string;
  address: string | null;
  emergency_contact: string;
  height: number | null;
  weight: number | null;
  blood_type: string | null;
  age: number;
  created_at: string;
  updated_at: string;
}

interface UserElderRelationItem {
  relation_id: number;
  elder_id: number;
  relation_name: string | null;
  remark: string | null;
  elder: ElderResponse;
}

interface MyEldersListData {
  items: UserElderRelationItem[];
  total: number;
}

interface HealthJudgment {
  bp_level: 'NORMAL' | 'MILD' | 'MODERATE' | 'SEVERE';
  fpg_level: 'NORMAL' | 'MILD' | 'MODERATE' | 'SEVERE';
  ppg_level: 'NORMAL' | 'MILD' | 'MODERATE' | 'SEVERE';
}

interface HealthMeasurement {
  id: number;
  elder_id: number;
  measured_at: string;
  sbp?: number;
  dbp?: number;
  fpg?: number;
  ppg_2h?: number;
  weight?: number;
  steps?: number;
  source: string;
  remark?: string;
  judgment?: HealthJudgment;
}

interface HealthMeasurementListData {
  records: HealthMeasurement[];
  total: number;
  current: number;
  size: number;
}

interface HealthSummary {
  latestSbp?: number;
  latestDbp?: number;
  latestFpg?: number;
  hasWarning: boolean;
  warningText?: string;
  bpLevel?: string;
  fpgLevel?: string;
}

interface ElderWithHealth {
  relation: UserElderRelationItem;
  healthSummary: HealthSummary;
}

interface PaginationParams {
  page: number;
  pageSize: number;
}

interface ElderIdParams extends PaginationParams {
  elder_id: number;
  include_judgment?: boolean;
}

interface SearchElderParams {
  page: number;
  pageSize: number;
  phone: string;
}

interface ElderListData {
  items: ElderResponse[];
  total: number;
}

interface AddElderRelationRequest {
  elder_id: number;
  relation_name?: string;
  remark?: string;
}

interface AddElderRelationResponse {
  relation_id: number;
  elder_id: number;
  relation_name: string | null;
  remark: string | null;
}

@Component
export struct ElderOverviewTab {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State elders: ElderWithHealth[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';


  aboutToAppear(): void {
    this.loadElders();
  }

  private async loadElders(): Promise<void> {
    if (this.isLoading) {
      return;
    }
    this.isLoading = true;
    this.errorMessage = '';

    try {
      // 获取关联老人列表
      const params: PaginationParams = { page: 1, pageSize: 20 };
      const response = await httpRequest<ApiResponse<MyEldersListData>, PaginationParams>({
        url: '/api/v1/users/me/elders',
        method: RequestEnum.GET,
        params: params
      });

      if (response.code !== 200 || !response.data) {
        this.errorMessage = response.message || '获取关联老人失败';
        promptAction.showToast({ message: this.errorMessage });
        return;
      }

      const items = response.data.items || [];

      // 为每个老人获取最新健康数据
      const eldersWithHealth: ElderWithHealth[] = [];
      for (const item of items) {
        const healthSummary = await this.fetchLatestHealth(item.elder.user_id);
        eldersWithHealth.push({
          relation: item,
          healthSummary: healthSummary
        });
      }

      this.elders = eldersWithHealth;
    } catch (error) {
      console.error('加载关联老人失败:', error);
      this.errorMessage = '网络异常，无法获取老人列表';
      promptAction.showToast({ message: this.errorMessage });
    } finally {
      this.isLoading = false;
    }
  }

  private async fetchLatestHealth(elderId: number): Promise<HealthSummary> {
    try {
      const healthParams: ElderIdParams = { 
        elder_id: elderId, 
        page: 1, 
        pageSize: 1,
        include_judgment: true
      };
      const response = await httpRequest<ApiResponse<HealthMeasurementListData>, ElderIdParams>({
        url: '/api/v1/elder-health/daily-health/list',
        method: RequestEnum.GET,
        params: healthParams
      });

      if (response.code === 200 && response.data && response.data.records.length > 0) {
        const latest = response.data.records[0];
        
        let hasWarning = false;
        let warningText: string | undefined = undefined;

        if (latest.judgment) {
          const warnings: string[] = [];
          // 检查血压
          if (latest.judgment.bp_level && latest.judgment.bp_level !== 'NORMAL') {
             if (latest.judgment.bp_level === 'SEVERE') warnings.push('血压严重偏高');
             else if (latest.judgment.bp_level === 'MODERATE') warnings.push('血压中度偏高');
             else warnings.push('血压偏高');
          }
          // 检查血糖 (空腹或餐后)
          if (latest.judgment.fpg_level && latest.judgment.fpg_level !== 'NORMAL') {
             if (latest.judgment.fpg_level === 'SEVERE') warnings.push('血糖严重偏高');
             else if (latest.judgment.fpg_level === 'MODERATE') warnings.push('血糖中度偏高');
             else warnings.push('血糖偏高');
          } else if (latest.judgment.ppg_level && latest.judgment.ppg_level !== 'NORMAL') {
             if (latest.judgment.ppg_level === 'SEVERE') warnings.push('血糖严重偏高');
             else if (latest.judgment.ppg_level === 'MODERATE') warnings.push('血糖中度偏高');
             else warnings.push('血糖偏高');
          }

          if (warnings.length > 0) {
            hasWarning = true;
            warningText = warnings.join('、') + '，建议关注';
          }
        } else {
          // Fallback if no judgment (though backend should return it if requested)
           const isBpHigh = (latest.sbp !== undefined && latest.sbp >= 140) ||
            (latest.dbp !== undefined && latest.dbp >= 90);
           const isBsHigh = (latest.fpg !== undefined && latest.fpg >= 7.0);
           
           if (isBpHigh || isBsHigh) {
             hasWarning = true;
             const warnings: string[] = [];
             if (isBpHigh) warnings.push('血压偏高');
             if (isBsHigh) warnings.push('血糖偏高');
             warningText = warnings.join('、') + '，建议关注';
           }
        }

        return {
          latestSbp: latest.sbp,
          latestDbp: latest.dbp,
          latestFpg: latest.fpg,
          hasWarning: hasWarning,
          warningText: warningText,
          bpLevel: latest.judgment?.bp_level,
          fpgLevel: latest.judgment?.fpg_level
        };
      }
    } catch (error) {
      console.warn('获取健康数据失败:', error);
    }

    return { hasWarning: false };
  }

  private openElderArchive(elder: ElderResponse): void {
    this.navPathStack.pushPath({
      name: 'Family_ElderArchive',
      param: elder
    });
  }



  build() {
    Stack() {
    Column() {
      // 页面标题
      Row() {
        Column() {
          Text('关联老人')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e293b')
          Text('实时查看老人健康状态')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)


      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })

      // 加载状态
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('正在加载...')
            .fontSize(14)
            .fontColor('#64748b')
            .margin({ top: 12 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.errorMessage !== '') {
        // 错误状态
        Column() {
          Text('😔')
            .fontSize(40)
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#ef4444')
            .margin({ top: 12 })
          Button('重新加载')
            .type(ButtonType.Capsule)
            .backgroundColor('#2563eb')
            .margin({ top: 16 })
            .onClick(() => {
              this.loadElders();
            })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.elders.length === 0) {
        // 空状态
        Column() {
          Text('👨‍👩‍👧‍👦')
            .fontSize(48)
          Text('暂无关联老人')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#374151')
            .margin({ top: 16 })
          Text('请联系医护人员添加老人关联关系')
            .fontSize(13)
            .fontColor('#9ca3af')
            .margin({ top: 8 })
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
      } else {
        // 老人卡片列表
        Scroll() {
          Column() {
            ForEach(this.elders, (item: ElderWithHealth) => {
              ElderCard({
                elderName: item.relation.elder.name,
                elderAge: item.relation.elder.age,
                elderGender: item.relation.elder.gender,
                elderPhone: item.relation.elder.phone,
                relationName: item.relation.relation_name || '',
                healthSummary: item.healthSummary,
                onCardClick: () => {
                  this.openElderArchive(item.relation.elder);
                },
                onViewArchive: () => {
                  this.openElderArchive(item.relation.elder);
                }
              })
            }, (item: ElderWithHealth) => item.relation.relation_id.toString())
          }
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')


    }
    .width('100%')
    .height('100%')
  }
}
