import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../../common/api/HttpUtil';
import { RequestEnum } from '../../../common/api/httpEnum';
import { CareCard } from '../../../components/medical/CareCard';
import { HealthRecordDialog } from '../../../components/medical/HealthRecordDialog';
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
  @Local private formMode: 'create' | 'edit' = 'create'
  @Local private editingRecord: HealthRecordItem | null = null
  
  // Dialog state
  @Local private dialogRecordType: HealthRecordType = 'MEDICAL_HISTORY'
  @Local private dialogMode: 'create' | 'edit' = 'create'
  @Local private dialogInitialTitle: string = ''
  @Local private dialogInitialDate: string = ''
  @Local private dialogInitialContent: Record<string, Object> | null = null
  
  navPathStack: NavPathStack = new NavPathStack()
  types: HealthRecordType[] = ['MEDICAL_HISTORY', 'CHECK_REPORT', 'MEDICATION', 'ALLERGY']

  private dialogController: CustomDialogController | null = null

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
    this.openDialog()
  }

  private openEditDialog(record: HealthRecordItem): void {
    this.editingRecord = record
    this.dialogMode = 'edit'
    this.dialogRecordType = record.record_type
    this.dialogInitialTitle = record.record_title
    this.dialogInitialDate = record.record_date
    this.dialogInitialContent = record.content_structured
    this.openDialog()
  }

  private openDialog() {
    this.dialogController = new CustomDialogController({
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
          this.dialogController = null
        }
      }),
      alignment: DialogAlignment.Center,
      customStyle: true,
      width: '90%'
    })
    this.dialogController.open()
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

  private getRecordTypeCode(type: HealthRecordType): string {
    return type
  }

  private formatDateHumanReadable(dateStr: string): string {
    if (!dateStr) return ''
    const date = new Date(dateStr)
    const now = new Date()
    
    // Reset hours for accurate date comparison
    const d = new Date(date.getFullYear(), date.getMonth(), date.getDate())
    const n = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    
    const diffTime = n.getTime() - d.getTime()
    const oneDay = 24 * 60 * 60 * 1000
    
    if (diffTime === 0) {
      return '今天'
    }
    if (diffTime === oneDay) {
      return '昨天'
    }
    
    return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`
  }

  private getTypeAbbr(type: HealthRecordType): string {
     switch(type) {
       case 'MEDICAL_HISTORY': return '病史'
       case 'CHECK_REPORT': return '检查'
       case 'MEDICATION': return '用药'
       case 'ALLERGY': return '过敏'
     }
  }

  private getTypeColor(type: HealthRecordType): string {
     switch(type) {
       case 'MEDICAL_HISTORY': return '#eff6ff'
       case 'CHECK_REPORT': return '#f0fdf4'
       case 'MEDICATION': return '#fef2f2'
       case 'ALLERGY': return '#fff7ed'
     }
  }
  
  private getTypeTextColor(type: HealthRecordType): string {
      switch(type) {
       case 'MEDICAL_HISTORY': return '#1d4ed8'
       case 'CHECK_REPORT': return '#15803d'
       case 'MEDICATION': return '#b91c1c'
       case 'ALLERGY': return '#c2410c'
     }
  }

  @Builder
  buildBasicInfoContent() {
    Column() {
      Row() {
        Text('基本信息')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .margin({ bottom: 8 })

      Column({ space: 8 }) {
        Row() {
          Text('姓名')
            .fontSize(13)
            .fontColor('#6b7280')
            .width(80)
          Text(this.elder?.name)
            .fontSize(13)
            .fontColor('#111827')
        }
        .width('100%')

        Row() {
          Text('性别')
            .fontSize(13)
            .fontColor('#6b7280')
            .width(80)
          Text(this.elder?.gender === 0 ? '女' : '男')
            .fontSize(13)
            .fontColor('#111827')
        }
        .width('100%')

        Row() {
          Text('出生日期')
            .fontSize(13)
            .fontColor('#6b7280')
            .width(80)
          Text(this.elder?.birth_date)
            .fontSize(13)
            .fontColor('#111827')
        }
        .width('100%')

        Row() {
          Text('联系电话')
            .fontSize(13)
            .fontColor('#6b7280')
            .width(80)
          Text(this.elder?.phone)
            .fontSize(13)
            .fontColor('#111827')
        }
        .width('100%')
      }
      .margin({ bottom: 12 })
    }
  }

  @Builder
  buildHealthRecordListContent() {
    Column() {
      Row() {
        Column() {
          Text('健康档案列表')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
      }
      .margin({ bottom: 6 })

      if (this.isLoading && this.records.length === 0) {
        Text('正在同步健康档案...')
          .fontSize(12)
          .fontColor('#6b7280')
          .margin({ top: 4 })
      } else if (!this.isLoading && this.records.length === 0) {
        Text('暂无健康记录，请添加')
          .fontSize(12)
          .fontColor('#6b7280')
          .margin({ top: 4 })
      }

      if (this.errorMessage !== '') {
        Text(this.errorMessage)
          .fontSize(11)
          .fontColor('#b91c1c')
          .margin({ top: 4 })
      }

      if (this.records.length > 0) {
        Column() {
          ForEach(this.records, (item: HealthRecordItem) => {
            Row() {
              // Left: Type box
              Column() {
                Text(this.getTypeAbbr(item.record_type))
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.getTypeTextColor(item.record_type))
              }
              .width(40)
              .height(40)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.getTypeColor(item.record_type))
              .borderRadius(8)
              .margin({ right: 12 })
              
              // Middle: Content
              Column() {
                Text(item.record_title)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#111827')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                
                Text(this.formatDateHumanReadable(item.record_date))
                  .fontSize(11)
                  .fontColor('#6b7280')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              // Right: Actions
              Column() {
                Text('编辑')
                  .fontSize(11)
                  .fontColor('#2563eb')
                  .margin({ bottom: 6 })
                  .onClick(() => {
                    this.openEditDialog(item)
                  })
                Text('删除')
                  .fontSize(11)
                  .fontColor('#b91c1c')
                  .onClick(() => {
                    this.handleDeleteRecord(item)
                  })
              }
              .margin({ left: 8 })
            }
            .width('100%')
            .padding(12)
            .borderRadius(12)
            .backgroundColor('#ffffff')
            .margin({ bottom: 8 })
          }, (item: HealthRecordItem) => item.id.toString())
        }
      }
    }
  }

  @Builder
  buildAddHealthRecordContent() {
    Column() {
      Row() {
        Column() {
          Text('新增健康档案记录')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
      }
      .margin({ bottom: 6 })

      Row() {
        ForEach(this.types, (item: HealthRecordType) => {
          Text(this.getRecordTypeLabel(item))
            .fontSize(11)
            .fontColor(item === this.selectedRecordType ? '#f9fafb' : '#4b5563')
            .padding({
              left: 12,
              right: 12,
              top: 6,
              bottom: 6
            })
            .borderRadius(999)
            .backgroundColor(item === this.selectedRecordType ? '#111827' : '#f3f4f6')
            .margin({ right: 8 })
            .onClick(() => {
              this.selectedRecordType = item
            })
        }, (item: HealthRecordType) => this.getRecordTypeCode(item))
      }
      .margin({ bottom: 12 })

      Button('新增健康档案记录')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(40)
        .backgroundColor('#111827')
        .fontColor('#f9fafb')
        .onClick(() => {
          this.openCreateDialog()
        })
    }
  }

  build() {
    Column() {
      NavDestination() {
        Column() {
          if (this.elder !== null) {
            CareCard({
              content: () => {
                this.buildBasicInfoContent()
              }
            })
          }

          CareCard({
            content: () => {
              this.buildHealthRecordListContent()
            }
          })

          CareCard({
            content: () => {
              this.buildAddHealthRecordContent()
            }
          })
        }
        .padding({
          left: 16,
          right: 16,
          top: 10,
          bottom: 10
        })
      }
      .title({ main: '老人详情与健康档案', sub: '查看与管理健康记录' })
      .onReady((ctx: NavDestinationContext) => {
        this.navPathStack = ctx.pathStack;
        this.elder = ctx.pathInfo.param as ElderResponse
      })
      .width('100%')
      .height('100%')
      .backgroundColor('#f3f4f6')
    }
  }
}
