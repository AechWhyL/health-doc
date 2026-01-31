import { SocketService } from '../../common/api/SocketService';
import { ConsultationService } from '../../common/api/ConsultationService';
import { ConsultationQuestion, ConsultationMessage } from '../../models/ConsultationModels';
import { ChatView } from '../../components/medical/ChatView';
import dayjs from 'dayjs';
import { BASEURL } from '../../common/api/httpEnum';
import { UserWithRoleResponse } from '../Login';
import { ConsultationDetailParams } from './ConsultationDetailPage';

@Builder
export function ChatPageBuilder() {
  ChatPage()
}

@Component
export struct ChatPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State questionId: number = 0;
  @State title: string = '';
  @State createdAt: string = '';
  @State messages: ConsultationMessage[] = [];
  @State isLoadingMessages: boolean = false;
  @State currentUserId: number = 0;
  @State currentUserType: string = '';
  @State currentUserDisplayName: string = '';
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
    // 获取当前用户信息
    const user = AppStorage.get<UserWithRoleResponse>('currentUser');
    if (user) {
      this.currentUserId = user.id;
      this.currentUserDisplayName = user.real_name || user.username;
      
      // 简单的角色映射逻辑：根据角色代码列表判断当前身份
      // 优先级：医护 > 家属 > 老人 (假设一个人可能有多个角色，这里取最高优先级的身份作为当前聊天身份)
      // 实际业务中可能需要通过路由参数或者上下文明确指定以什么身份进入聊天
      const roleCodes = user.roles.map(r => r.role_code.toLowerCase());
      if (roleCodes.includes('medical_staff')) {
        this.currentUserType = 'STAFF';
      } else if (roleCodes.includes('family')) {
        this.currentUserType = 'FAMILY';
      } else if (roleCodes.includes('elder')) {
        this.currentUserType = 'ELDER';
      } else {
        this.currentUserType = 'UNKNOWN';
      }
      console.log(`[ChatPage] Initialized with User: ${this.currentUserId}, Type: ${this.currentUserType}, Name: ${this.currentUserDisplayName}`);
    } else {
      console.error('[ChatPage] No current user found in AppStorage');
    }

    // 获取全局 SocketService 实例
    this.socketService = SocketService.getInstance();
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
      // 注意：不再关闭 WebSocket 连接，因为它是全局的
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
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              
               Row() {
                 Text(this.createdAt ? dayjs(this.createdAt).format('YYYY-MM-DD HH:mm') : '')
                   .fontSize(12)
                   .fontColor('#6B7280')
                   .margin({ right: 8 })

                 Text('查看详情 >') // Add visual cue for clickability
                  .fontSize(12)
                  .fontColor('#2563eb')
               }
            }
            .alignItems(HorizontalAlign.Start)
            .onClick(() => {
                 const param:ConsultationDetailParams = { id: this.questionId }
                 this.navPathStack.pushPath({
                   name: 'Common_ConsultationDetail',
                   param:param
                 });
            })
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
    .title("咨询")
    .onReady((context: NavDestinationContext) => {
      const params = context.pathInfo.param as ConsultationQuestion;
      console.log("ChatPageReady: "+ JSON.stringify(params))
      if (params) {
        this.questionId = params.id;
        this.title = params.title;
        // params might be incomplete (just id and title), but if it has createdAt use it.
        // Ideally we should refetch question details here or pass full object.
        // Assuming params is the full ConsultationQuestion object from list
        this.createdAt = params.created_at || ''; 
        this.initData();
      }
    })
  }
}
