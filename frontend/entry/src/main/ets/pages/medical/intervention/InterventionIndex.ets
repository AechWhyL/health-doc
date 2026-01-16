import { promptAction } from '@kit.ArkUI';
import { InterventionService } from '../../../common/api/InterventionService';
import { ElderListItem } from '../../../components/medical/ElderListItem';
import { ApiResponse } from '../../../models/DTO/types';
import { MyEldersListData, UserElderRelationItem } from '../../../models/DTO/intervention';
import { ElderInterventionPlanList } from '../intervention/ElderInterventionPlanList'
import { InterventionPlanForm } from '../intervention/InterventionPlanForm'
import { InterventionPlanItemDetail } from '../intervention/InterventionPlanItemDetail'

@Component
export struct InterventionIndex {
  @State private elders: UserElderRelationItem[] = []
  @State private isLoadingElders: boolean = false
  @State private elderError: string = ''
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

    try {
      const response = await InterventionService.getMyElders(1, 100) // Load up to 100 for now

      if (response.code !== 200 || !response.data) {
        const msg = response.message || '获取关联老人失败'
        this.elderError = msg
        promptAction.showToast({
          message: msg
        })
        return
      }
      console.log(this.elders.toString())

      const listData = response.data
      const items = listData && listData.items ? listData.items : []
      this.elders = items
      this.elderError = ''
    } catch (error) {
      this.elderError = '网络异常，无法获取关联老人'
      promptAction.showToast({
        message: this.elderError
      })
    } finally {
      this.isLoadingElders = false
    }
  }

  private openElderPlanList(elder: UserElderRelationItem): void {
    this.navPathStack.pushPath({
      name: 'Medical_Intervention_ElderPlanList',
      param: elder
    })
  }

  @Builder
  private buildPageMap(name: string) {
    if (name === 'Medical_Intervention_ElderPlanList') {
      ElderInterventionPlanList()
    }
    if (name === 'Medical_Intervention_PlanForm') {
      InterventionPlanForm()
    }
    if (name === 'Medical_Intervention_PlanItemDetail') {
      InterventionPlanItemDetail()
    }
  }

  build() {
    Column() {
      Navigation(this.navPathStack) {
        Column() {

          // List
          if (this.isLoadingElders && this.elders.length === 0) {
            Column() {
              LoadingProgress()
                .width(32)
                .height(32)
                .color('#2563eb')
              Text('加载中...')
                .fontSize(12)
                .fontColor('#6b7280')
                .margin({ top: 8 })
            }
            .width('100%')
            .padding(20)
            .alignItems(HorizontalAlign.Center)
          } else if (this.elderError) {
            Column() {
              Text(this.elderError)
                .fontSize(12)
                .fontColor('#dc2626')
              Button('重试')
                .fontSize(12)
                .height(28)
                .margin({ top: 8 })
                .onClick(() => {
                  this.loadElders(true)
                })
            }
            .width('100%')
            .padding(20)
            .alignItems(HorizontalAlign.Center)
          } else if (this.elders.length === 0) {
            Column() {
              Text('暂无关联老人')
                .fontSize(12)
                .fontColor('#6b7280')
            }
            .width('100%')
            .padding(20)
            .alignItems(HorizontalAlign.Center)
          } else {
            List() {
              ForEach(this.elders, (item: UserElderRelationItem) => {
                ListItem() {
                  ElderListItem({
                    elderName: item.elder.name,
                    elderAge: item.elder.age,
                    relationText: item.relation_name || '未指定关系',
                    phoneText: item.elder.phone,
                    onItemClick: () => {
                      this.openElderPlanList(item)
                    }
                  })
                }
              }, (item: UserElderRelationItem) => item.relation_id.toString())
            }
            .width('100%')
            .height('100%')
          }
        }
        .width('100%')
        .height('100%')
        .padding({
          left: 16,
          right: 16,
          top: 10,
          bottom: 10
        })
      }
      .navDestination(this.buildPageMap)
    }
  }
}
