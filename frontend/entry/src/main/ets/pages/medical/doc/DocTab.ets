import { promptAction } from '@kit.ArkUI';
import router from '@ohos.router'
import { httpRequest } from '../../../common/api/HttpUtil';
import { RequestEnum } from '../../../common/api/httpEnum';
import { ElderListItem } from '../../../components/medical/ElderListItem';
import { CareCard } from '../../../components/medical/CareCard';

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

interface UserElderRelationItem {
  relation_id: number;
  elder_id: number;
  relation_name: string | null;
  remark: string | null;
  elder: ElderResponse;
}

interface MyEldersQueryParams {
  page: number;
  pageSize: number;
  elder_name?: string;
}

interface MyEldersListData {
  items: UserElderRelationItem[];
  total: number;
}

interface AddMyElderRequest {
  elder_id: number;
  relation_name?: string;
  remark?: string;
}

interface ElderListQueryParams {
  phone?: string;
  page: number;
  pageSize: number;
  name?: string;
}

interface ElderListPageData {
  items: ElderResponse[];
  total: number;
  pages: number;
  current: number;
  size: number;
}

@Builder
export function DocTabBuilder(){
  DocTab()
}

@Component
export struct DocTab {
  @State private elders: UserElderRelationItem[] = []
  @State private isLoadingElders: boolean = false
  @State private elderError: string = ''
  @State private elderSearchName: string = ''
  @State private phoneSearchValue: string = ''
  @State private isSearchingByPhone: boolean = false
  @State private phoneSearchError: string = ''
  @State private phoneSearchResult: ElderResponse | null = null
  @State private isAddingRelation: boolean = false
  @State private isPhoneElderLinked: boolean = false
  @Consume('navPathStack') navPathStack: NavPathStack;

  aboutToAppear(): void {
    this.loadElders(true)
  }

  private async loadElders(reset: boolean = false): Promise<void> {
    if (this.isLoadingElders) {
      return
    }

    this.isLoadingElders = true
    if (reset) {
      this.elders = []
    }
    console.log("1")

    try {
      let params: MyEldersQueryParams = {
        page: 1,
        pageSize: 20
      }
      const name = this.elderSearchName.trim()
      if (name !== '') {
        params.elder_name = name
      }

      const response = await httpRequest<ApiResponse<MyEldersListData>, MyEldersQueryParams>({
        url: '/api/v1/users/me/elders',
        method: RequestEnum.GET,
        token: 'auth',
        params
      })

      if (response.code !== 200 || !response.data) {
        const msg = response.message || '获取关联老人失败'
        this.elderError = msg
        promptAction.showToast({
          message: msg
        })
        return
      }

      const listData = response.data
      const items = listData && listData.items ? listData.items : []
      this.elders = items
      this.elderError = ''
      console.log("refresh")
    } catch (error) {
      this.elderError = '网络异常，无法获取关联老人'
      promptAction.showToast({
        message: this.elderError
      })
    } finally {
      this.isLoadingElders = false
    }
  }

  private isElderLinked(elderId: number): boolean {
    return this.elders.some((item: UserElderRelationItem) => item.elder_id === elderId)
  }

  private getGenderText(gender: number): string {
    if (gender === 0) {
      return '女'
    }
    if (gender === 1) {
      return '男'
    }
    return '未知'
  }

  private async searchElderByPhone(): Promise<void> {
    if (this.isSearchingByPhone) {
      return
    }
    const value = this.phoneSearchValue.trim()
    if (value === '') {
      this.phoneSearchError = '请输入手机号码'
      this.phoneSearchResult = null
      return
    }

    this.isSearchingByPhone = true
    this.phoneSearchError = ''
    this.phoneSearchResult = null
    this.isPhoneElderLinked = false

    try {
      let params: ElderListQueryParams = {
        page: 1,
        pageSize: 1
      }
      params.phone = value

      const response = await httpRequest<ApiResponse<ElderListPageData>, ElderListQueryParams>({
        url: '/api/v1/elder-health/elder/list',
        method: RequestEnum.GET,
        token: 'auth',
        params
      })

      if (response.code !== 200 || !response.data) {
        const msg = response.message || '搜索老人失败'
        this.phoneSearchError = msg
        promptAction.showToast({
          message: msg
        })
        return
      }

      const pageData = response.data
      const records = pageData && pageData.items ? pageData.items : []
      if (records.length === 0) {
        this.phoneSearchError = '未找到匹配的老人'
        this.phoneSearchResult = null
        this.isPhoneElderLinked = false
        return
      }

      this.phoneSearchResult = records[0]
      this.isPhoneElderLinked = this.isElderLinked(this.phoneSearchResult.id)
    } catch (error) {
      this.phoneSearchError = '网络异常，无法搜索老人'
      promptAction.showToast({
        message: this.phoneSearchError
      })
    } finally {
      this.isSearchingByPhone = false
    }
  }

  private async addElderRelationFromPhone(): Promise<void> {
    if (this.isAddingRelation) {
      return
    }
    if (!this.phoneSearchResult) {
      this.phoneSearchError = '请先通过手机号搜索并定位老人'
      return
    }
    if (this.isElderLinked(this.phoneSearchResult.id)) {
      return
    }

    this.isAddingRelation = true

    try {
      const body: AddMyElderRequest = {
        elder_id: this.phoneSearchResult.id
      }

      const response = await httpRequest<ApiResponse<null>, AddMyElderRequest>({
        url: '/api/v1/users/me/elders',
        method: RequestEnum.POST,
        token: 'auth',
        params: body
      })

      console.log(response.code.toString())

      if (response.code !== 200) {
        const msg = response.message || '关联老人失败'
        return
      }

      console.log("success");

      this.loadElders(true)
      this.isPhoneElderLinked = true
    } catch (error) {
      promptAction.showToast({
        message: '网络异常，关联老人失败'
      })
    } finally {
      this.isAddingRelation = false
    }
  }

  private openElderArchiveDetail(elder: ElderResponse): void {
    console.log("open")
    this.navPathStack.pushPath({
      name: 'Medical_DocTab_ElderArchive',
      param: elder
    })
  }

  @Builder
  private buildElderListSection() {
    Column() {
      Row() {
        Column() {
          Text('老人列表')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
          Text('基于当前医护账号的关联关系展示')
            .fontSize(11)
            .fontColor('#6b7280')
            .margin({ top: 2 })
        }
        .layoutWeight(1)

        Text('ElderController')
          .fontSize(11)
          .fontColor('#1d4ed8')
          .padding({
            left: 8,
            right: 8,
            top: 2,
            bottom: 2
          })
          .borderRadius(999)
          .backgroundColor('#eff6ff')
      }
      .margin({ bottom: 8 })

      if (this.isLoadingElders && this.elders.length === 0) {
        Text('正在加载关联老人...')
          .fontSize(12)
          .fontColor('#6b7280')
          .margin({ top: 4, bottom: 8 })
      } else if (!this.isLoadingElders && this.elders.length === 0) {
        Text('暂无关联老人，请先在后台完成关联')
          .fontSize(12)
          .fontColor('#6b7280')
          .margin({ top: 4, bottom: 8 })
      }

      if (this.elderError !== '') {
        Text(this.elderError)
          .fontSize(11)
          .fontColor('#b91c1c')
          .margin({ bottom: 4 })
      }

      if (this.elders.length > 0) {
        Column() {
          ForEach(this.elders, (item: UserElderRelationItem) => {
            ElderListItem({
              elderName: item.elder.name,
              elderAge: item.elder.age,
              relationText: item.relation_name ? '关系：' + item.relation_name : '关联老人',
              phoneText: item.elder.phone,
              onItemClick: () => {
                console.log("click to doc")
                this.openElderArchiveDetail(item.elder)
              }
            })

          }, (item: UserElderRelationItem) => item.relation_id.toString())
        }
      }
    }
  }

  @Builder
  private buildSectionHeader(title: string, subtitle: string) {
    Row() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        if (subtitle !== '') {
          Text(subtitle)
            .fontSize(12)
            .fontColor('#6b7280')
            .margin({ top: 2 })
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: 8 })
  }

  @Builder
  private buildPhoneAddCardContent() {
    Row() {
      Column() {
        Text('通过手机号添加老人')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
        Text('根据手机号定位老人并添加关注关系')
          .fontSize(11)
          .fontColor('#6b7280')
          .margin({ top: 2 })
      }
      .layoutWeight(1)

      Text('搜索并关注')
        .fontSize(11)
        .fontColor('#166534')
        .padding({
          left: 8,
          right: 8,
          top: 2,
          bottom: 2
        })
        .borderRadius(999)
        .backgroundColor('#ecfdf3')
    }
    .margin({ bottom: 6 })

    Row() {
      TextInput({ text: this.phoneSearchValue, placeholder: '例如：13800001234' })
        .height(32)
        .fontSize(12)
        .padding({ left: 12, right: 12 })
        .borderRadius(16)
        .backgroundColor('#f9fafb')
        .layoutWeight(1)
        .onChange((value: string) => {
          this.phoneSearchValue = value
        })

      Button(this.isSearchingByPhone ? '搜索中' : '按手机号搜索老人')
        .type(ButtonType.Capsule)
        .height(32)
        .margin({ left: 8 })
        .backgroundColor('#111827')
        .fontColor('#f9fafb')
        .enabled(!this.isSearchingByPhone)
        .onClick(() => {
          this.searchElderByPhone()
        })
    }
    .margin({ bottom: 8 })

    if (this.phoneSearchError !== '') {
      Text(this.phoneSearchError)
        .fontSize(11)
        .fontColor('#b91c1c')
        .margin({ bottom: 4 })
    }

    if (this.phoneSearchResult) {
      Column() {
        Row() {
          Column() {
            Text(this.phoneSearchResult.name + ' · ' + this.getGenderText(this.phoneSearchResult.gender) + ' · ' +
            this.phoneSearchResult.age + ' 岁')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
            Text('联系电话：' + this.phoneSearchResult.phone)
              .fontSize(11)
              .fontColor('#6b7280')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
        }
        .padding({
          left: 8,
          right: 8,
          top: 6,
          bottom: 6
        })
        .borderRadius(12)
        .backgroundColor('#f9fafb')
      }
      .margin({ bottom: 6 })
    }

    Button(this.phoneSearchResult !== null && this.isPhoneElderLinked
      ? '已关注'
      : (this.isAddingRelation ? '添加中...' : '添加关注'))
      .type(ButtonType.Capsule)
      .width('100%')
      .height(36)
      .backgroundColor(this.phoneSearchResult !== null && this.isPhoneElderLinked ? '#f9fafb' : '#111827')
      .fontColor(this.phoneSearchResult !== null && this.isPhoneElderLinked ? '#111827' : '#f9fafb')
      .border({
        width: this.phoneSearchResult !== null && this.isPhoneElderLinked ? 1 : 0,
        color: '#e5e7eb'
      })
      .enabled(!(this.phoneSearchResult !== null && this.isPhoneElderLinked) && !this.isAddingRelation &&
        this.phoneSearchResult !== null)
      .onClick(() => {
        this.addElderRelationFromPhone()
      })
  }

  build() {
    Column() {
      this.buildSectionHeader('老人档案', '')

      CareCard({
        content: () => {
          this.buildElderListSection()
        }
      })

      CareCard({
        content: () => {
          this.buildPhoneAddCardContent()
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
}
