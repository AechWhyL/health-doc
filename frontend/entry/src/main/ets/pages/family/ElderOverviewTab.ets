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
  // 搜索相关
  @State showAddDialog: boolean = false;
  @State searchPhone: string = '';
  @State searchResults: ElderResponse[] = [];
  @State isSearching: boolean = false;
  @State selectedElder: ElderResponse | null = null;
  @State relationName: string = '';
  @State isAdding: boolean = false;

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

  private async searchElderByPhone(): Promise<void> {
    if (this.searchPhone.trim() === '') {
      promptAction.showToast({ message: '请输入手机号' });
      return;
    }
    this.isSearching = true;
    this.searchResults = [];
    this.selectedElder = null;

    try {
      const params: SearchElderParams = { phone: this.searchPhone.trim(), page: 1, pageSize: 10 };
      const response = await httpRequest<ApiResponse<ElderListData>, SearchElderParams>({
        url: '/api/v1/elder-health/elder/list',
        method: RequestEnum.GET,
        params: params
      });

      if (response.code === 200 && response.data) {
        this.searchResults = response.data.items || [];
        if (this.searchResults.length === 0) {
          promptAction.showToast({ message: '未找到匹配的老人' });
        }
      } else {
        promptAction.showToast({ message: response.message || '搜索失败' });
      }
    } catch (error) {
      console.error('搜索老人失败:', error);
      promptAction.showToast({ message: '搜索失败，请重试' });
    } finally {
      this.isSearching = false;
    }
  }

  private async addElderRelation(): Promise<void> {
    if (!this.selectedElder) {
      promptAction.showToast({ message: '请先选择要添加的老人' });
      return;
    }

    this.isAdding = true;
    try {
      const data: AddElderRelationRequest = {
        elder_id: this.selectedElder.user_id,
        relation_name: this.relationName.trim() || undefined
      };

      const response = await httpRequest<ApiResponse<AddElderRelationResponse>, AddElderRelationRequest>({
        url: '/api/v1/users/me/elders',
        method: RequestEnum.POST,
        params: data
      });

      if (response.code === 200 || response.code === 201) {
        promptAction.showToast({ message: '添加成功' });
        this.showAddDialog = false;
        this.searchPhone = '';
        this.searchResults = [];
        this.selectedElder = null;
        this.relationName = '';
        this.loadElders(); // 刷新列表
      } else {
        promptAction.showToast({ message: response.message || '添加失败' });
      }
    } catch (error) {
      console.error('添加老人关联失败:', error);
      promptAction.showToast({ message: '添加失败，请重试' });
    } finally {
      this.isAdding = false;
    }
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

        Button('+ 添加老人')
          .type(ButtonType.Capsule)
          .backgroundColor('#2563eb')
          .fontSize(13)
          .height(36)
          .onClick(() => {
            this.showAddDialog = true;
            this.searchPhone = '';
            this.searchResults = [];
            this.selectedElder = null;
            this.relationName = '';
          })
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

    // 搜索添加老人弹窗
    if (this.showAddDialog) {
      Column() {
        Column() {
          Text('添加关联老人')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e293b')
            .margin({ bottom: 16 })

          // 手机号搜索
          Text('输入老人手机号搜索')
            .fontSize(13)
            .fontColor('#64748b')
            .alignSelf(ItemAlign.Start)
          Row() {
            TextInput({ text: this.searchPhone, placeholder: '请输入手机号' })
              .height(44)
              .fontSize(14)
              .backgroundColor('#f8fafc')
              .borderRadius(10)
              .layoutWeight(1)
              .onChange((value: string) => {
                this.searchPhone = value;
              })
            Button(this.isSearching ? '...' : '搜索')
              .type(ButtonType.Capsule)
              .backgroundColor('#2563eb')
              .height(44)
              .width(70)
              .margin({ left: 10 })
              .enabled(!this.isSearching)
              .onClick(() => {
                this.searchElderByPhone();
              })
          }
          .width('100%')
          .margin({ top: 6, bottom: 14 })

          // 搜索结果
          if (this.searchResults.length > 0) {
            Text('搜索结果')
              .fontSize(13)
              .fontColor('#64748b')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })

            ForEach(this.searchResults, (elder: ElderResponse) => {
              Row() {
                Column() {
                  Text(elder.gender === 1 ? '👴' : '👵').fontSize(24)
                }
                .width(40)
                .height(40)
                .borderRadius(20)
                .backgroundColor('#f1f5f9')
                .justifyContent(FlexAlign.Center)

                Column() {
                  Text(elder.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1e293b')
                  Text(elder.phone + ' · ' + elder.age + '岁')
                    .fontSize(12)
                    .fontColor('#64748b')
                    .margin({ top: 2 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 10 })

                if (this.selectedElder && this.selectedElder.id === elder.id) {
                  Text('✓')
                    .fontSize(16)
                    .fontColor('#16a34a')
                } else {
                  Text('选择')
                    .fontSize(13)
                    .fontColor('#2563eb')
                }
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.selectedElder && this.selectedElder.id === elder.id ? '#eff6ff' : '#f8fafc')
              .borderRadius(10)
              .margin({ bottom: 8 })
              .onClick(() => {
                this.selectedElder = elder;
              })
            }, (elder: ElderResponse) => elder.id.toString())
          }

          // 关系名称
          if (this.selectedElder) {
            Text('与老人的关系（可选）')
              .fontSize(13)
              .fontColor('#64748b')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 8 })
            TextInput({ text: this.relationName, placeholder: '如：父亲、母亲' })
              .height(44)
              .fontSize(14)
              .backgroundColor('#f8fafc')
              .borderRadius(10)
              .margin({ top: 6, bottom: 16 })
              .onChange((value: string) => {
                this.relationName = value;
              })
          }

          // 按钮
          Row() {
            Button('取消')
              .type(ButtonType.Capsule)
              .backgroundColor('#f1f5f9')
              .fontColor('#64748b')
              .layoutWeight(1)
              .height(44)
              .margin({ right: 10 })
              .onClick(() => {
                this.showAddDialog = false;
              })

            Button(this.isAdding ? '添加中...' : '确认添加')
              .type(ButtonType.Capsule)
              .backgroundColor(this.selectedElder ? '#2563eb' : '#cbd5e1')
              .layoutWeight(1)
              .height(44)
              .enabled(!!this.selectedElder && !this.isAdding)
              .onClick(() => {
                this.addElderRelation();
              })
          }
          .width('100%')
          .margin({ top: 8 })
        }
        .width('90%')
        .padding(24)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .shadow({ radius: 20, color: '#0002' })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#00000066')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.showAddDialog = false;
      })
    }
    }
    .width('100%')
    .height('100%')
  }
}
