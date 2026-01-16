import { ConsultationMessage } from '../../models/ConsultationModels';

@Component
export struct ChatView {
  @Link messages: ConsultationMessage[];
  @Prop currentUserId: number;
  @State inputText: string = '';
  onSendMessage: (text: string) => void = () => {};
  private scroller: Scroller = new Scroller();

  build() {
    Column() {
      // 消息列表
      List({ scroller: this.scroller, initialIndex: this.messages.length - 1 }) {
        ForEach(this.messages, (msg: ConsultationMessage) => {
          ListItem() {
            this.MessageItem(msg)
          }
        }, (msg: ConsultationMessage) => msg.id.toString() + msg.sent_at)
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })

      // 底部输入栏
      Row() {
        TextInput({ placeholder: '输入要发送的回复内容...', text: this.inputText })
          .layoutWeight(1)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#F3F4F6')
          .onChange((value: string) => {
            this.inputText = value;
          })
          .onSubmit(() => {
            this.handleSend();
          })

        Button('发送')
          .height(36)
          .width(70)
          .margin({ left: 8 })
          .backgroundColor('#111827')
          .fontColor('#F9FAFB')
          .fontSize(14)
          .onClick(() => {
            this.handleSend();
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: '#E5E7EB' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')
  }

  @Builder
  MessageItem(msg: ConsultationMessage) {
    Column() {
      if (msg.sender_id === this.currentUserId) {
        // 自己的消息
        Row() {
          Text(msg.content_text)
            .fontSize(14)
            .fontColor('#F9FAFB')
            .padding({ top: 8, bottom: 8, left: 12, right: 12 })
            .backgroundColor('#111827')
            .borderRadius(12)
            .constraintSize({ maxWidth: '80%' })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .margin({ bottom: 4 })

        Row() {
          Text(`我 · ${this.formatTime(msg.sent_at)}`)
            .fontSize(10)
            .fontColor('#9CA3AF')
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .margin({ bottom: 12 })

      } else {
        // 对方的消息
        Row() {
          Text(msg.content_text)
            .fontSize(14)
            .fontColor('#111827')
            .padding({ top: 8, bottom: 8, left: 12, right: 12 })
            .backgroundColor('#E5E7EB') // 原型中的 #F3F4F6 可能太浅，稍微加深
            .borderRadius(12)
            .constraintSize({ maxWidth: '80%' })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .margin({ bottom: 4 })

        Row() {
          Text(`${msg.role_display_name} · ${this.formatTime(msg.sent_at)}`)
            .fontSize(10)
            .fontColor('#9CA3AF')
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .margin({ bottom: 12 })
      }
    }
  }

  handleSend() {
    if (this.inputText.trim().length > 0) {
      this.onSendMessage(this.inputText);
      this.inputText = '';
      // 滚动到底部
      this.scroller.scrollToIndex(this.messages.length);
    }
  }

  formatTime(timeStr: string): string {
    if (!timeStr) return '';
    try {
      const date = new Date(timeStr);
      const hours = date.getHours().toString().padStart(2, '0');
      const minutes = date.getMinutes().toString().padStart(2, '0');
      return `${hours}:${minutes}`;
    } catch (e) {
      return timeStr;
    }
  }
}
