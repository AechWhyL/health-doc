import { promptAction } from '@kit.ArkUI';
import { httpRequest } from '../../common/api/HttpUtil';
import { RequestEnum } from '../../common/api/httpEnum';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
}

interface ElderResponse {
  id: number;
  user_id: number;
  name: string;
  gender: number;
  birth_date: string;
  phone: string;
  age: number;
}

interface UserElderRelationItem {
  relation_id: number;
  elder_id: number;
  relation_name: string | null;
  elder: ElderResponse;
}

interface MyEldersListData {
  items: UserElderRelationItem[];
  total: number;
}

interface ElderListData {
  items: ElderResponse[];
  total: number;
}

interface SearchElderParams {
  page: number;
  pageSize: number;
  name?: string;
  phone?: string;
}

interface AddElderRelationRequest {
  elder_id: number;
  relation_name?: string;
}

interface QueryMyEldersParams {
  page: number;
  pageSize: number;
}

@Builder
export function AssociatedEldersPageBuilder() {
  AssociatedEldersPage()
}

@Component
export struct AssociatedEldersPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State searchKeyword: string = '';
  @State myElders: UserElderRelationItem[] = [];
  @State searchResults: ElderResponse[] = [];
  @State isLoading: boolean = false;
  @State isSearching: boolean = false;

  aboutToAppear() {
    this.loadMyElders();
  }

  async loadMyElders() {
    this.isLoading = true;
    try {
      const params: QueryMyEldersParams = { page: 1, pageSize: 100 };
      const response = await httpRequest<ApiResponse<MyEldersListData>, QueryMyEldersParams>({
        url: '/api/v1/users/me/elders',
        method: RequestEnum.GET,
        params: params
      });
      if (response.code === 200 && response.data) {
        this.myElders = response.data.items || [];
      }
    } catch (error) {
      promptAction.showToast({ message: '加载关联老人失败' });
    } finally {
      this.isLoading = false;
    }
  }

  async searchElders() {
    if (!this.searchKeyword.trim()) {
      this.searchResults = [];
      return;
    }
    this.isSearching = true;
    try {
      const params: SearchElderParams = { page: 1, pageSize: 20 };
      if (/^\d{11}$/.test(this.searchKeyword.trim())) {
        params.phone = this.searchKeyword.trim();
      } else {
        params.name = this.searchKeyword.trim();
      }

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
      }
    } catch (error) {
      promptAction.showToast({ message: '搜索失败' });
    } finally {
      this.isSearching = false;
    }
  }

  isAssociated(elderId: number): boolean {
    return this.myElders.some(item => item.elder.user_id === elderId);
  }

  getRelationId(elderId: number): number | null {
    const relation = this.myElders.find(item => item.elder.user_id === elderId);
    return relation ? relation.relation_id : null;
  }

  async addAssociation(elder: ElderResponse) {
    try {
      const response = await httpRequest<ApiResponse, AddElderRelationRequest>({
        url: '/api/v1/users/me/elders',
        method: RequestEnum.POST,
        params: { elder_id: elder.user_id }
      });
      if (response.code === 200 || response.code === 201) {
        promptAction.showToast({ message: '关联成功' });
        await this.loadMyElders();
      } else {
        promptAction.showToast({ message: response.message || '关联失败' });
      }
    } catch (error) {
      promptAction.showToast({ message: '网络异常' });
    }
  }

  async removeAssociation(relationId: number) {
    try {
      const response = await httpRequest<ApiResponse, void>({
        url: `/api/v1/users/me/elders/${relationId}`,
        method: RequestEnum.DELETE
      });
      if (response.code === 200) {
        promptAction.showToast({ message: '已取消关联' });
        await this.loadMyElders();
      } else {
        promptAction.showToast({ message: response.message || '取消关联失败' });
      }
    } catch (error) {
      promptAction.showToast({ message: '网络异常' });
    }
  }

  confirmRemove(relationId: number, name: string) {
    AlertDialog.show({
      title: '取消关联',
      message: `确定要取消与 ${name} 的关联吗？`,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确定',
        fontColor: '#ef4444',
        action: () => {
          this.removeAssociation(relationId);
        }
      }
    });
  }

  @Builder
  ElderItem(elder: ElderResponse, isSearchResult: boolean) {
    Row() {
      // Avatar / Icon
      Text(elder.gender === 1 ? '👴' : '👵')
        .fontSize(40)
        .margin({ right: 12 })

      // Info
      Column() {
        Row() {
          Text(elder.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e293b')
          Text(`${elder.age}岁`)
            .fontSize(12)
            .fontColor('#64748b')
            .margin({ left: 8 })
            .backgroundColor('#f1f5f9')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
        }
        
        Text(elder.phone)
          .fontSize(14)
          .fontColor('#64748b')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // Action Button
      if (this.isAssociated(elder.user_id)) {
        Button('已关联')
          .type(ButtonType.Capsule)
          .backgroundColor('#dcfce7')
          .fontColor('#16a34a')
          .fontSize(12)
          .height(28)
          .onClick(() => {
            const relationId = this.getRelationId(elder.user_id);
            if (relationId) {
              this.confirmRemove(relationId, elder.name);
            }
          })
      } else {
        Button('关联')
          .type(ButtonType.Capsule)
          .backgroundColor('#2563eb')
          .fontSize(12)
          .height(28)
          .onClick(() => {
            this.addAssociation(elder);
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  build() {
    NavDestination() {
      Column() {

        // Search Bar
        Row() {
          TextInput({ text: this.searchKeyword, placeholder: '搜索姓名或手机号' })
            .height(40)
            .fontSize(14)
            .backgroundColor('#f1f5f9')
            .borderRadius(20)
            .layoutWeight(1)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.searchKeyword = value;
              if (value.trim() === '') {
                this.searchResults = [];
              }
            })
            .onSubmit(() => {
              this.searchElders();
            })

          Button('搜索')
            .type(ButtonType.Capsule)
            .backgroundColor('#2563eb')
            .height(36)
            .fontSize(13)
            .margin({ left: 12 })
            .onClick(() => {
              this.searchElders();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
        .backgroundColor(Color.White)

        // Content
        Scroll() {
          Column() {
            if (this.searchKeyword.trim()) {
              // Search Results Mode
              Text('搜索结果')
                .fontSize(14)
                .fontColor('#64748b')
                .width('100%')
                .margin({ bottom: 12, top: 18 })
              
              if (this.isSearching) {
                LoadingProgress().width(32).height(32).margin({ top: 20 })
              } else if (this.searchResults.length === 0) {
                Column() {
                  Text('🔍').fontSize(40)
                  Text('未找到匹配的老人').fontSize(14).fontColor('#9ca3af').margin({ top: 8 })
                }.margin({ top: 40 })
              } else {
                ForEach(this.searchResults, (elder: ElderResponse) => {
                  this.ElderItem(elder, true)
                }, (elder: ElderResponse) => elder.id.toString())
              }
            } else {
              // My Elders List Mode
              if (this.myElders.length > 0) {
                Text('已关联的老人')
                .fontSize(14)
                .fontColor('#64748b')
                .width('100%')
                .margin({ bottom: 12, top: 12 })

                ForEach(this.myElders, (item: UserElderRelationItem) => {
                  this.ElderItem(item.elder, false)
                }, (item: UserElderRelationItem) => item.relation_id.toString())
              } else if (!this.isLoading) {
                Column() {
                  Text('👨‍👩‍👧‍👦').fontSize(48)
                  Text('暂无关联老人').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#374151').margin({ top: 16 })
                  Text('请在上搜索栏输入姓名或手机号添加').fontSize(13).fontColor('#9ca3af').margin({ top: 8 })
                }.width('100%').height(300).justifyContent(FlexAlign.Center)
              }
            }
          }
          .padding({ left: 16, right: 16, bottom: 20 })
          .constraintSize({
            minHeight:"100%"
          })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f8fafc')
    }
    .title('关联老人')

  }
}
