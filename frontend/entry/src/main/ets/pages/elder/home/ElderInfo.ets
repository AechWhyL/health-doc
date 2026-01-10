import apiService, { ApiResponse, ElderProfile, PaginatedResult, UserSummary } from '../../../common/api/ApiService';

@Component
export struct ElderInfo {
  @State elder: ElderProfile | null = null;
  @State loading: boolean = false;
  @State error: string = '';
  private loaded: boolean = false;

  aboutToAppear() {
    if (this.loaded) {
      return;
    }
    this.loaded = true;
    this.loadElderProfile();
  }

  private async loadElderProfile(): Promise<void> {
    this.loading = true;
    this.error = '';
    try {
      const userResp: ApiResponse<UserSummary> = await apiService.getCurrentUser();
      if (userResp.code !== 200) {
        this.error = '获取当前用户信息失败';
        return;
      }
      const user: UserSummary = userResp.data;
      let nameFilter: string | undefined = undefined;
      if (user.real_name !== null && user.real_name !== '') {
        nameFilter = user.real_name as string;
      } else {
        nameFilter = user.username;
      }
      const elderResp: ApiResponse<PaginatedResult<ElderProfile>> = await apiService.getElderList(1, 1, nameFilter, undefined);
      if (elderResp.code === 200 && elderResp.data.items.length > 0) {
        this.elder = elderResp.data.items[0];
      } else {
        this.error = '未找到对应的老人档案';
      }
    } catch (e) {
      if ((e as Object) instanceof Error) {
        const err = e as Error;
        const message: string = err.message;
        this.error = message;
      } else {
        this.error = '加载老人档案失败';
      }
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      if (this.loading) {
        Text('正在加载老人档案...')
          .fontSize(16)
      } else if (this.error !== '') {
        Text(this.error)
          .fontSize(16)
          .fontColor(Color.Red)
      } else if (this.elder === null) {
        Text('暂无老人档案信息')
          .fontSize(16)
      } else {
        Text('个人基础信息')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24, bottom: 16 })

        Column() {
          Row() {
            Text('姓名：')
              .fontSize(16)
            Text(this.elder.name)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 8 })

          Row() {
            Text('性别：')
              .fontSize(16)
            Text(this.elder.gender === 1 ? '男' : '女')
              .fontSize(16)
          }
          .margin({ bottom: 8 })

          Row() {
            Text('年龄：')
              .fontSize(16)
            Text(this.elder.age.toString() + ' 岁')
              .fontSize(16)
          }
          .margin({ bottom: 8 })

          Row() {
            Text('联系方式：')
              .fontSize(16)
            Text(this.elder.phone)
              .fontSize(16)
          }
          .margin({ bottom: 8 })

          Row() {
            Text('家庭住址：')
              .fontSize(16)
            Text(this.elder.address === null ? '未填写' : this.elder.address as string)
              .fontSize(16)
          }
          .margin({ bottom: 8 })

          Row() {
            Text('紧急联系人：')
              .fontSize(16)
            Text(this.elder.emergency_contact)
              .fontSize(16)
          }
          .margin({ bottom: 8 })

          Row() {
            Text('血型：')
              .fontSize(16)
            Text(this.elder.blood_type === null ? '未填写' : this.elder.blood_type as string)
              .fontSize(16)
          }
          .margin({ bottom: 8 })
        }
      }
    }
    .padding(16)
  }
}