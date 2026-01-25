import { ConsultationService } from '../../../common/api/ConsultationService';
import { ConsultationQuestion } from '../../../models/ConsultationModels';
import { SectionHeader } from '../../../components/common/SectionHeader';
import { EmptyState } from '../../../components/common/EmptyState';

@Component
export struct ConsultationList {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State questions: ConsultationQuestion[] = [];
  @State isLoading: boolean = false;

  aboutToAppear() {
    this.fetchQuestions();
  }

  async fetchQuestions() {
    this.isLoading = true;
    try {
      const response = await ConsultationService.getQuestionList({});
      if (response.code === 200) {
        this.questions = response.data.items;
      }
    } catch (error) {
      console.error('Failed to fetch questions:', error);
    } finally {
      this.isLoading = false;
    }
  }

  private getCreatorTypeText(creatorType: string): string {
    switch (creatorType) {
      case 'ELDER':
        return '老人';
      case 'FAMILY':
        return '家属';
      case 'STAFF':
        return '医护';
      default:
        return '';
    }
  }

  @Builder
  private buildQuestionCard(item: ConsultationQuestion) {
    Column() {
      Row() {
        // 左侧图标
        Text('💬')
          .fontSize(28)
          .margin({ right: 14 })

        // 中间内容
        Column() {
          Row() {
            Text(item.title)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1e293b')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }

          Row({ space: 8 }) {
            // 创建者信息

            Text(`来自${this.getCreatorTypeText(item.creator_type)}`)
              .fontSize(12)
              .fontColor('#64748b')
            Divider().vertical(true).height(20)
            Text(`${item.creator_summary?.name || "匿名"}`)
              .fontSize(12)
              .fontColor('#64748b')


            // 优先级
            if (item.priority === 'URGENT') {
              Text('紧急')
                .fontSize(11)
                .fontColor('#dc2626')
                .padding({
                  left: 6,
                  right: 6,
                  top: 2,
                  bottom: 2
                })
                .backgroundColor('#fef2f2')
                .borderRadius(4)
            }
          }
          .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 右侧操作按钮 - 统一为"回复"
        Text('回复')
          .fontSize(12)
          .fontColor('#2563eb')
          .backgroundColor('#eff6ff')
          .padding({
            left: 10,
            right: 10,
            top: 6,
            bottom: 6
          })
          .borderRadius(14)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(14)
    .shadow({ radius: 4, color: '#0f172a0a', offsetY: 1 })
    .margin({ bottom: 12 })
    .onClick(() => {
      this.navPathStack.pushPath({
        name: 'Medical_ConsultationTab_ChatPage',
        param: item as Object
      });
    })
  }

  build() {
    Column() {
      // 标题栏
      SectionHeader({
        title: '咨询列表',
        subtitle: `共 ${this.questions.length} 条咨询`
      })

      // 内容区
      if (this.isLoading && this.questions.length === 0) {
        Column() {
          LoadingProgress().width(32).height(32).color('#2563eb')
          Text('加载中...')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.questions.length === 0) {
        EmptyState({
          icon: '💬',
          title: '暂无咨询',
          subtitle: '当前没有待处理的咨询问题'
        })
      } else {
        Scroll() {
          Column() {
            ForEach(this.questions, (item: ConsultationQuestion) => {
              this.buildQuestionCard(item)
            }, (item: ConsultationQuestion) => item.id.toString())
          }
          .constraintSize({
            minHeight:"100%"
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#f8fafc')
  }
}
