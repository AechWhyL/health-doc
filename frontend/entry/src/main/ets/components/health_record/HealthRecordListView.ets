import { promptAction } from '@kit.ArkUI';
import dayjs from 'dayjs';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';
import {
  HealthRecordType,
  HealthRecordItem,
  HealthRecordListQueryParams,
  HealthRecordListPageData
} from '../../models/HealthArchiveModels';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

export class  HealthRecordListViewController {
  refresh:()=>void = ()=>{}
}

/**
 * 健康档案列表展示组件
 * 支持筛选、排序,可在医护端和家属端复用
 */
@ComponentV2
export struct HealthRecordListView {
  // ==================== Props ====================
  @Param @Require elderId: number = 0;
  @Param elderName: string = '';
  @Param showAddButton: boolean = true;
  @Param onItemClick?: (record: HealthRecordItem) => void = ()=>{};
  @Param onAddClick?: () => void = ()=>{};

  @Param refresher:number = 0

  // ==================== State ====================
  @Local private records: HealthRecordItem[] = [];
  @Local private filteredRecords: HealthRecordItem[] = [];
  @Local private isLoading: boolean = false;
  @Local private errorMessage: string = '';
  @Local private selectedRecordType: HealthRecordType | 'ALL' = 'ALL';
  @Local private sortOrder: 'desc' | 'asc' = 'desc'; // desc=最新, asc=最早

  private types: (HealthRecordType | 'ALL')[] = ['ALL', 'MEDICAL_HISTORY', 'CHECK_REPORT', 'MEDICATION', 'ALLERGY'];

  @Param
  controller:HealthRecordListViewController = new HealthRecordListViewController()

  // ==================== 生命周期 ====================
  aboutToAppear(): void {
    this.loadRecords();
    if(this.controller){
      this.controller.refresh = this.refresh
    }
  }

  @Monitor('elderId')
  onElderIdChange(): void {
    if (this.elderId > 0) {
      this.loadRecords();
    }
  }

  // ==================== 数据加载 ====================
  private async loadRecords(): Promise<void> {
    if (this.elderId <= 0) {
      return;
    }
    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const query: HealthRecordListQueryParams = {
        page: 1,
        pageSize: 100,
        elder_id: this.elderId,
        sort_by: 'created_at',
        sort_order: this.sortOrder
      };

      const response = await httpRequest<ApiResponse<HealthRecordListPageData>, HealthRecordListQueryParams>({
        url: '/api/v1/elder-health/health-record/list',
        method: RequestEnum.GET,
        token: 'auth',
        params: query
      });

      if (response.code !== 200 || !response.data) {
        const msg = response.message || '加载健康档案失败';
        this.errorMessage = msg;
        return;
      }

      const pageData = response.data;
      this.records = pageData && pageData.items ? pageData.items : [];
      this.applyFilters();
    } catch (_error) {
      this.errorMessage = '网络异常,无法加载健康档案';
    } finally {
      this.isLoading = false;
    }
  }

  // ==================== 筛选和排序 ====================
  private applyFilters(): void {
    let filtered = [...this.records];

    // 按类型筛选
    if (this.selectedRecordType !== 'ALL') {
      filtered = filtered.filter((r: HealthRecordItem) => r.record_type === this.selectedRecordType);
    }

    // 按时间排序
    filtered.sort((a: HealthRecordItem, b: HealthRecordItem) => {
      const dateA = new Date(a.created_at).getTime();
      const dateB = new Date(b.created_at).getTime();
      return this.sortOrder === 'desc' ? dateB - dateA : dateA - dateB;
    });

    this.filteredRecords = filtered;
  }

  private handleTypeFilterChange(type: HealthRecordType | 'ALL'): void {
    this.selectedRecordType = type;
    this.applyFilters();
  }

  private handleSortToggle(): void {
    this.sortOrder = this.sortOrder === 'desc' ? 'asc' : 'desc';
    this.applyFilters();
  }

  // ==================== 工具方法 ====================
  private getRecordTypeLabel(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '病史记录';
      case 'CHECK_REPORT': return '检查报告';
      case 'MEDICATION': return '用药记录';
      case 'ALLERGY': return '过敏记录';
    }
  }

  private getTypeAbbr(type: HealthRecordType | 'ALL'): string {
    switch (type) {
      case 'ALL': return '全部';
      case 'MEDICAL_HISTORY': return '病史';
      case 'CHECK_REPORT': return '检查';
      case 'MEDICATION': return '用药';
      case 'ALLERGY': return '过敏';
    }
  }

  private getTypeColor(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '#eff6ff';
      case 'CHECK_REPORT': return '#f0fdf4';
      case 'MEDICATION': return '#fef2f2';
      case 'ALLERGY': return '#fff7ed';
    }
  }

  private getTypeTextColor(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '#1d4ed8';
      case 'CHECK_REPORT': return '#15803d';
      case 'MEDICATION': return '#b91c1c';
      case 'ALLERGY': return '#c2410c';
    }
  }

  private formatDateHumanReadable(dateStr: string): string {
    if (!dateStr) return '';
    const date = dayjs(dateStr);
    const now = dayjs();

    if (date.isSame(now, 'day')) {
      return '今天';
    }
    if (date.isSame(now.subtract(1, 'day'), 'day')) {
      return '昨天';
    }
    return date.format('YYYY年M月D日');
  }

  // ==================== UI 构建器 ====================
  @Builder
  private buildFilterBar() {
    Row({ space: 8 }) {
      // 类型筛选器
      Row({ space: 6 }) {
        ForEach(this.types, (type: HealthRecordType | 'ALL') => {
          Text(this.getTypeAbbr(type))
            .fontSize(11)
            .fontColor(type === this.selectedRecordType ? Color.White : '#4b5563')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .borderRadius(16)
            .backgroundColor(type === this.selectedRecordType ? '#2563eb' : '#f1f5f9')
            .onClick(() => {
              this.handleTypeFilterChange(type);
            })
        }, (type: HealthRecordType | 'ALL') => type)
      }
      .layoutWeight(1)

      // 排序按钮
      Row({ space: 4 }) {
        Text(this.sortOrder === 'desc' ? '↓' : '↑')
          .fontSize(14)
          .fontColor('#2563eb')
        Text(this.sortOrder === 'desc' ? '最新' : '最早')
          .fontSize(12)
          .fontColor('#2563eb')
      }
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .borderRadius(16)
      .backgroundColor('#eff6ff')
      .onClick(() => {
        this.handleSortToggle();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }

  @Builder
  private buildRecordItem(item: HealthRecordItem) {
    Row() {
      // 左侧类型图标
      Column() {
        Text(this.getTypeAbbr(item.record_type))
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTypeTextColor(item.record_type))
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.getTypeColor(item.record_type))
      .borderRadius(12)

      // 中间标题和日期
      Column() {
        Text(item.record_title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1e293b')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 8 }) {
          Text(this.getRecordTypeLabel(item.record_type))
            .fontSize(11)
            .fontColor(this.getTypeTextColor(item.record_type))

          Text('·')
            .fontSize(11)
            .fontColor('#cbd5e1')

          Text(this.formatDateHumanReadable(item.record_date))
            .fontSize(11)
            .fontColor('#64748b')
        }
        .margin({ top: 6 })

        if (item.creator_name) {
          Text('创建人: ' + item.creator_name)
            .fontSize(11)
            .fontColor('#64748b')
            .margin({ top: 4 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })

      // 右侧箭头
      Text('›')
        .fontSize(24)
        .fontColor('#cbd5e1')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(14)
    .shadow({ radius: 4, color: '#0f172a08', offsetY: 1 })
    .margin({ bottom: 10 })
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(item);
      }
    })
  }

  @Builder
  private buildEmptyState() {
    Column() {
      Text('📋')
        .fontSize(40)
      Text('暂无健康档案')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#374151')
        .margin({ top: 12 })
      Text(this.selectedRecordType === 'ALL' ? '点击下方按钮添加第一条记录' : '该类型暂无记录,试试切换筛选条件')
        .fontSize(13)
        .fontColor('#9ca3af')
        .margin({ top: 6 })
    }
    .width('100%')
    .padding(40)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private buildLoadingState() {
    Row() {
      LoadingProgress().width(24).height(24).color('#2563eb')
      Text('正在加载...')
        .fontSize(13)
        .fontColor('#64748b')
        .margin({ left: 8 })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding(32)
  }

  @Builder
  private buildErrorState() {
    Column() {
      Text('❌')
        .fontSize(32)
      Text(this.errorMessage)
        .fontSize(13)
        .fontColor('#dc2626')
        .margin({ top: 8 })
      Button('重试')
        .type(ButtonType.Capsule)
        .backgroundColor('#2563eb')
        .fontSize(13)
        .height(36)
        .margin({ top: 12 })
        .onClick(() => {
          this.loadRecords();
        })
    }
    .width('100%')
    .padding(32)
    .justifyContent(FlexAlign.Center)
  }

  // ==================== 主构建方法 ====================
  build() {
    Column() {
      // 筛选栏
      this.buildFilterBar()

      // 列表内容
      if (this.isLoading && this.records.length === 0) {
        this.buildLoadingState()
      } else if (this.errorMessage !== '') {
        this.buildErrorState()
      } else if (this.filteredRecords.length === 0) {
        this.buildEmptyState()
      } else {
        Scroll() {
          Column() {
            ForEach(this.filteredRecords, (item: HealthRecordItem) => {
              this.buildRecordItem(item)
            }, (item: HealthRecordItem) => item.id.toString())

            // 底部间距,为添加按钮留空间
            if (this.showAddButton) {
              Column().height(80)
            }
          }
          .padding({ left: 16, right: 16, top: 8, bottom: 16 })
          .constraintSize({
            minHeight:"100%"
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      //
      // // 添加按钮
      // if (this.showAddButton) {
      //   Column() {
      //     Button('+ 新增档案记录')
      //       .type(ButtonType.Capsule)
      //       .backgroundColor('#2563eb')
      //       .fontColor(Color.White)
      //       .fontSize(14)
      //       .fontWeight(FontWeight.Medium)
      //       .height(48)
      //       .width('90%')
      //       .shadow({ radius: 12, color: '#2563eb40', offsetY: 4 })
      //       .onClick(() => {
      //         if (this.onAddClick) {
      //           this.onAddClick();
      //         }
      //       })
      //   }
      //   .width('100%')
      //   .padding({ left: 20, right: 20, top: 12, bottom: 24 })
      //   .backgroundColor('#ffffffee')
      //   .backdropBlur(20)
      // }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f1f5f9')
  }

  // ==================== 公共方法 ====================
  /**
   * 刷新列表数据
   */
  @Monitor('refresher')
  public refresh(): void {
    console.log("[HealthRecordList] refresh")
    this.loadRecords();
  }
}
