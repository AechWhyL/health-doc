import { promptAction } from '@kit.ArkUI';
import dayjs from 'dayjs';
import { httpRequest } from '../../../common/api/HttpUtil';
import { RequestEnum } from '../../../common/api/httpEnum';
import { HealthRecordDialog } from '../../../components/medical/HealthRecordDialog';
import { HealthRecordDetailDialog } from '../../../components/medical/HealthRecordDetailDialog';
import {
  HealthRecordType,
  HealthRecordItem,
  CreateHealthRecordPayload,
  UpdateHealthRecordPayload,
  HealthRecordFormSubmitPayload
} from '../../../models/HealthRecordModels';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

interface ElderResponse {
  id: number;
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

interface HealthRecordListQueryParams {
  page: number;
  pageSize: number;
  elder_id?: number;
  record_type?: HealthRecordType;
}

interface HealthRecordListPageData {
  items: HealthRecordItem[];
  total: number;
  pages: number;
  current: number;
  size: number;
}

@Builder
export function ElderArchiveBuilder() {
  ElderArchive()
}

@ComponentV2
export struct ElderArchive {
  @Local private elder: ElderResponse | null = null
  @Local private records: HealthRecordItem[] = []
  @Local private isLoading: boolean = false
  @Local private errorMessage: string = ''
  @Local private selectedRecordType: HealthRecordType = 'MEDICAL_HISTORY'
  @Local private editingRecord: HealthRecordItem | null = null
  @Local private viewingRecord: HealthRecordItem | null = null

  // Dialog state
  @Local private dialogRecordType: HealthRecordType = 'MEDICAL_HISTORY'
  @Local private dialogMode: 'create' | 'edit' = 'create'
  @Local private dialogInitialTitle: string = ''
  @Local private dialogInitialDate: string = ''
  @Local private dialogInitialContent: Record<string, Object> | null = null

  navPathStack: NavPathStack = new NavPathStack()
  types: HealthRecordType[] = ['MEDICAL_HISTORY', 'CHECK_REPORT', 'MEDICATION', 'ALLERGY']

  private formDialogController: CustomDialogController | null = null
  private detailDialogController: CustomDialogController | null = null

  aboutToAppear(): void {
    this.loadRecords()
  }

  @Monitor('elder')
  private async loadRecords(): Promise<void> {
    if (this.elder === null) {
      return
    }
    if (this.isLoading) {
      return
    }
    this.isLoading = true
    this.errorMessage = ''
    try {
      const query: HealthRecordListQueryParams = {
        page: 1,
        pageSize: 50,
        elder_id: this.elder.id
      }
      const response = await httpRequest<ApiResponse<HealthRecordListPageData>, HealthRecordListQueryParams>({
        url: '/api/v1/elder-health/health-record/list',
        method: RequestEnum.GET,
        token: 'auth',
        params: query
      })
      if (response.code !== 200 || !response.data) {
        const msg = response.message || '加载健康档案失败'
        this.errorMessage = msg
        return
      }
      const pageData = response.data
      const list = pageData && pageData.items ? pageData.items : []
      this.records = list
    } catch (_error) {
      this.errorMessage = '网络异常，无法同步健康档案'
    } finally {
      this.isLoading = false
    }
  }

  private openCreateDialog(): void {
    this.dialogMode = 'create'
    this.dialogRecordType = this.selectedRecordType
    this.dialogInitialTitle = ''
    this.dialogInitialDate = ''
    this.dialogInitialContent = null
    this.openFormDialog()
  }

  private openEditDialog(record: HealthRecordItem): void {
    this.editingRecord = record
    this.dialogMode = 'edit'
    this.dialogRecordType = record.record_type
    this.dialogInitialTitle = record.record_title
    this.dialogInitialDate = record.record_date
    this.dialogInitialContent = record.content_structured
    this.openFormDialog()
  }

  private openFormDialog(): void {
    this.formDialogController = new CustomDialogController({
      builder: HealthRecordDialog({
        elderName: this.elder?.name || '',
        recordType: this.dialogRecordType,
        mode: this.dialogMode,
        initialTitle: this.dialogInitialTitle,
        initialDate: this.dialogInitialDate,
        initialContent: this.dialogInitialContent,
        onSubmit: (payload) => {
          this.handleSubmit(payload)
        },
        onCancel: () => {
          this.formDialogController = null
        }
      }),
      alignment: DialogAlignment.Center,
      customStyle: true,
      width: '92%'
    })
    this.formDialogController.open()
  }

  private openDetailDialog(record: HealthRecordItem): void {
    this.viewingRecord = record
    this.detailDialogController = new CustomDialogController({
      builder: HealthRecordDetailDialog({
        record: record,
        onEdit: () => {
          this.openEditDialog(record)
        },
        onDelete: () => {
          this.handleDeleteRecord(record)
        }
      }),
      alignment: DialogAlignment.Center,
      customStyle: true,
      width: '92%'
    })
    this.detailDialogController.open()
  }

  private async handleSubmit(payload: HealthRecordFormSubmitPayload): Promise<void> {
    if (this.dialogMode === 'create') {
      if (this.elder === null) return
      const createPayload: CreateHealthRecordPayload = {
        elder_id: this.elder.id,
        record_type: payload.recordType,
        record_title: payload.recordTitle,
        record_date: payload.recordDate,
        content_structured: payload.contentStructured
      }
      await this.handleCreateSubmit(createPayload)
    } else {
      if (this.editingRecord === null) return
      const updatePayload: UpdateHealthRecordPayload = {
        record_type: payload.recordType,
        record_title: payload.recordTitle,
        record_date: payload.recordDate,
        content_structured: payload.contentStructured
      }
      await this.handleEditSubmit(this.editingRecord.id, updatePayload)
    }
  }

  private async handleCreateSubmit(payload: CreateHealthRecordPayload): Promise<void> {
    try {
      const response = await httpRequest<ApiResponse<HealthRecordItem>, CreateHealthRecordPayload>({
        url: '/api/v1/elder-health/health-record',
        method: RequestEnum.POST,
        token: 'auth',
        params: payload
      })
      if (response.code !== 200 || !response.data) {
        const msg = response.message || '创建健康记录失败'
        this.getUIContext().getPromptAction().showToast({
          message: msg
        })
        return
      }
      this.getUIContext().getPromptAction().showToast({
        message: '创建健康记录成功'
      })
      await this.loadRecords()
    } catch (_error) {
      this.getUIContext().getPromptAction().showToast({
        message: '网络异常，创建健康记录失败'
      })
    }
  }

  private async handleEditSubmit(recordId: number, payload: UpdateHealthRecordPayload): Promise<void> {
    try {
      const response = await httpRequest<ApiResponse<HealthRecordItem>, UpdateHealthRecordPayload>({
        url: '/api/v1/elder-health/health-record/' + recordId.toString(),
        method: RequestEnum.PUT,
        token: 'auth',
        params: payload
      })
      if (response.code !== 200 || !response.data) {
        const msg = response.message || '更新健康记录失败'
        this.getUIContext().getPromptAction().showToast({
          message: msg
        })
        return
      }
      this.getUIContext().getPromptAction().showToast({
        message: '更新健康记录成功'
      })
      await this.loadRecords()
    } catch (_error) {
      this.getUIContext().getPromptAction().showToast({
        message: '网络异常，更新健康记录失败'
      })
    }
  }

  private async handleDeleteRecord(record: HealthRecordItem): Promise<void> {
    if (this.elder === null) {
      return
    }
    try {
      const response = await httpRequest<ApiResponse<null>, Object>({
        url: '/api/v1/elder-health/health-record/' + record.id.toString(),
        method: RequestEnum.DELETE,
        token: 'auth',
      })
      if (response.code !== 200) {
        const msg = response.message || '删除健康记录失败'
        this.getUIContext().getPromptAction().showToast({
          message: msg
        })
        return
      }
      this.getUIContext().getPromptAction().showToast({
        message: '删除健康记录成功'
      })
      await this.loadRecords()
    } catch (_error) {
      this.getUIContext().getPromptAction().showToast({
        message: '网络异常，删除健康记录失败'
      })
    }
  }

  private getRecordTypeLabel(type: HealthRecordType): string {
    if (type === 'MEDICAL_HISTORY') return '病史记录'
    if (type === 'CHECK_REPORT') return '检查报告'
    if (type === 'MEDICATION') return '用药记录'
    return '过敏记录'
  }

  private formatDateHumanReadable(dateStr: string): string {
    if (!dateStr) return ''
    const date = dayjs(dateStr)
    const now = dayjs()

    if (date.isSame(now, 'day')) {
      return '今天'
    }
    if (date.isSame(now.subtract(1, 'day'), 'day')) {
      return '昨天'
    }
    return date.format('YYYY年M月D日')
  }

  private formatBirthDate(dateStr: string): string {
    if (!dateStr) return '未填写'
    return dayjs(dateStr).format('YYYY年M月D日')
  }

  private getGenderEmoji(gender: number): string {
    return gender === 1 ? '👴' : '👵'
  }

  private getGenderText(gender: number): string {
    return gender === 1 ? '男' : '女'
  }

  private getTypeAbbr(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '病史'
      case 'CHECK_REPORT': return '检查'
      case 'MEDICATION': return '用药'
      case 'ALLERGY': return '过敏'
    }
  }

  private getTypeColor(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '#eff6ff'
      case 'CHECK_REPORT': return '#f0fdf4'
      case 'MEDICATION': return '#fef2f2'
      case 'ALLERGY': return '#fff7ed'
    }
  }

  private getTypeTextColor(type: HealthRecordType): string {
    switch (type) {
      case 'MEDICAL_HISTORY': return '#1d4ed8'
      case 'CHECK_REPORT': return '#15803d'
      case 'MEDICATION': return '#b91c1c'
      case 'ALLERGY': return '#c2410c'
    }
  }

  @Builder
  private InfoRow(icon: string, label: string, value: string) {
    Row() {
      Text(icon + ' ' + label)
        .fontSize(13)
        .fontColor('#64748b')
        .width(120)
      Text(value)
        .fontSize(14)
        .fontColor('#1e293b')
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }

  @Builder
  buildElderInfoCard() {
    if (this.elder) {
      Column() {
        // Header with avatar and basic info
        Row() {
          Column() {
            Text(this.getGenderEmoji(this.elder.gender))
              .fontSize(40)
          }
          .width(72)
          .height(72)
          .borderRadius(36)
          .backgroundColor('#f1f5f9')
          .justifyContent(FlexAlign.Center)

          Column() {
            Text(this.elder.name)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1e293b')
            Text(this.getGenderText(this.elder.gender) + ' · ' + this.elder.age + '岁')
              .fontSize(14)
              .fontColor('#64748b')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 })
        }
        .width('100%')

        // Detailed info
        Column() {
          this.InfoRow('📱', '电话', this.elder.phone)
          this.InfoRow('🎂', '出生日期', this.formatBirthDate(this.elder.birth_date))
          this.InfoRow('📍', '地址', this.elder.address || '未填写')
          this.InfoRow('🆘', '紧急联系人', this.elder.emergency_contact || '未填写')
          if (this.elder.blood_type) {
            this.InfoRow('🩸', '血型', this.elder.blood_type)
          }
          if (this.elder.height) {
            this.InfoRow('📏', '身高', this.elder.height + ' cm')
          }
          if (this.elder.weight) {
            this.InfoRow('⚖️', '体重', this.elder.weight + ' kg')
          }
        }
        .margin({ top: 20 })
        .padding(16)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
        .width('100%')
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 8, color: '#0f172a10', offsetY: 2 })
    }
  }

  @Builder
  buildHealthRecordListSection() {
    Column() {
      // Section header
      Row() {
        Text('健康档案')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1e293b')

        Blank()

        Text(`共 ${this.records.length} 条`)
          .fontSize(13)
          .fontColor('#64748b')
      }
      .width('100%')
      .margin({ bottom: 14 })

      // Loading / Empty / Error states
      if (this.isLoading && this.records.length === 0) {
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
      } else if (this.errorMessage !== '') {
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
              this.loadRecords()
            })
        }
        .width('100%')
        .padding(32)
        .justifyContent(FlexAlign.Center)
      } else if (!this.isLoading && this.records.length === 0) {
        Column() {
          Text('📋')
            .fontSize(40)
          Text('暂无健康档案')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#374151')
            .margin({ top: 12 })
          Text('点击下方按钮添加第一条记录')
            .fontSize(13)
            .fontColor('#9ca3af')
            .margin({ top: 6 })
        }
        .width('100%')
        .padding(40)
        .justifyContent(FlexAlign.Center)
      } else {
        // Record list
        ForEach(this.records, (item: HealthRecordItem) => {
          Row() {
            // Left: Type icon box
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

            // Middle: Title and date
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
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 14 })

            // Right: Arrow icon
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
            this.openDetailDialog(item)
          })
        }, (item: HealthRecordItem) => item.id.toString())
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: '#0f172a10', offsetY: 2 })
    .margin({ top: 16 })
  }

  @Builder
  buildFAB() {
    Column() {
      // Record type selector
      Row({ space: 6 }) {
        ForEach(this.types, (type: HealthRecordType) => {
          Text(this.getTypeAbbr(type))
            .fontSize(11)
            .fontColor(type === this.selectedRecordType ? Color.White : '#4b5563')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .borderRadius(16)
            .backgroundColor(type === this.selectedRecordType ? '#1e293b' : '#f1f5f9')
            .onClick(() => {
              this.selectedRecordType = type
            })
        }, (type: HealthRecordType) => type)
      }
      .margin({ bottom: 12 })

      // Add button
      Button('+ 新增档案记录')
        .type(ButtonType.Capsule)
        .backgroundColor('#1e293b')
        .fontColor(Color.White)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .height(48)
        .width('100%')
        .shadow({ radius: 12, color: '#1e293b40', offsetY: 4 })
        .onClick(() => {
          this.openCreateDialog()
        })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 12, bottom: 24 })
    .backgroundColor('#ffffffee')
    .backdropBlur(20)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  build() {
    Column() {
      NavDestination() {
        Stack({ alignContent: Alignment.Bottom }) {
          Scroll() {
            Column() {
              // Elder info card
              this.buildElderInfoCard()

              // Health records list
              this.buildHealthRecordListSection()

              // Bottom padding for FAB
              Column().height(120)
            }
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .backgroundColor('#f1f5f9')

          // FAB area at bottom
          this.buildFAB()
        }
        .width('100%')
        .height('100%')
      }
      .title('老人详情与健康档案')
      .onReady((ctx: NavDestinationContext) => {
        this.navPathStack = ctx.pathStack;
        this.elder = ctx.pathInfo.param as ElderResponse
      })
      .width('100%')
      .height('100%')
      .backgroundColor('#f1f5f9')
    }
  }
}
