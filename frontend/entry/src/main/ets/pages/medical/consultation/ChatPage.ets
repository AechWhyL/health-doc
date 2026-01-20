import { SocketService } from '../../../common/api/SocketService';
import { ConsultationService } from '../../../common/api/ConsultationService';
import { ConsultationQuestion, ConsultationMessage } from '../../../models/ConsultationModels';
import { ChatView } from '../../../components/medical/ChatView';
import { BASEURL } from '../../../common/api/httpEnum';
import { SocketBridge } from '../../../components/SocketBridge';

@Builder
export function ChatPageBuilder() {
  ChatPage()
}

@Component
export struct ChatPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State questionId: number = 0;
  @State title: string = '';
  @State messages: ConsultationMessage[] = [];
  @State isLoadingMessages: boolean = false;
  @State currentUserId: number = 456; // 假设当前登录医生ID为456
  @State currentUserType: string = 'STAFF';
  @State currentUserDisplayName: string = '王医生';
  private socketService: SocketService | null = null;
  // 监听器回调引用
  private onNewMessage = (data: Object | string) => {
    console.log("ChatPage: onNewMessage")
    const msg = data as ConsultationMessage;
    if (msg.question_id === this.questionId) {
      // 简单的去重逻辑：检查是否已存在相同ID的消息
      const exists = this.messages.some(m => m.id === msg.id);
      if (!exists) {
        this.messages.push(msg);
      }
    }
  }
  private onSendMessageAck = (data: Object | string) => {
    // 处理消息发送确认
  }

  aboutToAppear(): void {
    console.log('[socket debug] chatPage about to appear')
  }

  // 初始化数据
  initData() {
    if (!this.questionId) {
      return;
    }
    if(!this.socketService){
      console.log('[socket debug] socket service not ready,stop init')
      return
    }

    // 初始化 Socket 连接
    this.socketService.init(BASEURL.baseUrl);

    // 加入房间
    this.socketService.joinQuestion(
      this.questionId,
      this.currentUserId,
      this.currentUserType,
      this.currentUserDisplayName
    );

    // 注册监听器
    this.socketService.on('new_message', this.onNewMessage);
    this.socketService.on('send_message:ack', this.onSendMessageAck);

    // 加载历史消息
    this.loadHistoryMessages();
  }

  aboutToDisappear() {
    if (this.questionId && this.socketService) {
      console.debug("[socket debug] chat page about to disappear")
      this.socketService.leaveQuestion(this.questionId);
      this.socketService.off('new_message', this.onNewMessage);
      this.socketService.off('send_message:ack', this.onSendMessageAck);
      this.socketService.close()
    }
  }

  async loadHistoryMessages() {
    this.isLoadingMessages = true;
    try {
      const response = await ConsultationService.getMessageList(this.questionId);
      if (response.code === 200) {
        this.messages = response.data.items;
      }
    } catch (error) {
      console.error('[socket debug] Failed to load history messages:', error);
    } finally {
      this.isLoadingMessages = false;
    }
  }

  handleSendMessage = async (text: string) => {
    if(!this.socketService){
      console.log('[socket debug] socket service not ready, stop send message')
      return
    }
    const tempId = -Date.now();
    const payload: Record<string, Object> = {
      'question_id': this.questionId,
      'sender_type': this.currentUserType,
      'sender_id': this.currentUserId,
      'role_display_name': this.currentUserDisplayName,
      'content_type': 'TEXT',
      'content_text': text,
      'attachments': []
    };

    // 乐观更新 UI
    const optimisticMsg: ConsultationMessage = {
      id: tempId,
      question_id: this.questionId,
      sender_type: this.currentUserType as 'STAFF' | 'ELDER' | 'FAMILY' | 'SYSTEM',
      sender_id: this.currentUserId,
      role_display_name: this.currentUserDisplayName,
      content_type: 'TEXT',
      content_text: text,
      attachments: [],
      sent_at: new Date().toISOString(),
      status: 'SENDING'
    };

    this.messages.push(optimisticMsg);

    try {
      // 调用后端 API 持久化消息
      const response = await ConsultationService.createMessage(this.questionId, payload);
      if (response.code === 200 && response.data) {
        const savedMsg = response.data;
        // 更新本地消息为服务器返回的真实数据
        const index = this.messages.findIndex(m => m.id === tempId);
        if (index !== -1) {
          this.messages[index] = savedMsg;
        }

        // 广播消息 (使用带有真实ID的消息，确保其他客户端收到正确数据)
        // 注意：onNewMessage 会通过 ID 去重，避免重复显示
        this.socketService.sendMessage(savedMsg as Object as Record<string, Object>);
      } else {
        // API 调用失败
        this.updateMessageStatus(tempId, 'FAILED');
      }
    } catch (error) {
      console.error('Send message failed:', error);
      this.updateMessageStatus(tempId, 'FAILED');
    }
  }

  updateMessageStatus(tempId: number, status: 'SENDING' | 'SENT' | 'FAILED') {
    const index = this.messages.findIndex(m => m.id === tempId);
    if (index !== -1) {
      let msg = this.messages[index];
      msg.status = status;
      this.messages[index] = msg;
    }
  }

  build() {
    NavDestination() {
      Stack() {
        SocketBridge({
          onWebControllerAttached: () => {
            this.socketService = SocketService.getInstance()
            this.initData()
          }
        })

        Column() {
          // Header
          Row() {
            Image($r('app.media.startIcon')) // 占位返回图标，实际开发中请替换
              .width(24)
              .height(24)
              .margin({ right: 16 })
              .onClick(() => {
                this.navPathStack.pop();
              })

            Column() {
              Text(this.title)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(`咨询编号: CQ${this.questionId}`)
                .fontSize(12)
                .fontColor('#6B7280')
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .shadow({ radius: 2, color: '#0F172A0D', offsetY: 1 })
          .zIndex(1)

          // Chat Content
          if (this.isLoadingMessages && this.messages.length === 0) {
            Column() {
              LoadingProgress().width(32).height(32).color('#2563eb')
              Text('加载消息中...')
                .fontSize(13)
                .fontColor('#64748b')
                .margin({ top: 8 })
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else {
            ChatView({
              messages: $messages,
              currentUserId: this.currentUserId,
              onSendMessage: this.handleSendMessage
            })
              .layoutWeight(1)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F9FAFB')
      }
      .alignContent(Alignment.TopStart)
    }
    .hideTitleBar(false)
    .onReady((context: NavDestinationContext) => {
      const params = context.pathInfo.param as ConsultationQuestion;
      console.log("ChatPageReady")
      if (params) {
        this.questionId = params.id;
        this.title = params.title;
        this.initData();
      }
    })
  }
}
