import { Server, Socket } from 'socket.io';
import { Server as HttpServer } from 'http';
import { ConsultationService } from '../services/consultation.service';
import {
  ConsultationAttachmentInput,
  CreateConsultationMessageRequest
} from '../dto/requests/consultation.dto';
import {
  ConsultationContentType,
  ConsultationSenderType
} from '../types/consultation';
import { UserNotificationRecord } from '../types/notification';

let ioInstance: Server | null = null;

interface JoinQuestionPayload {
  question_id: number;
  user_id?: number;
  user_type?: string;
  role_display_name?: string;
}

interface SendMessagePayload {
  question_id: number;
  sender_type: ConsultationSenderType;
  sender_id?: number;
  role_display_name?: string;
  content_type: ConsultationContentType;
  content_text?: string;
  attachments?: ConsultationAttachmentInput[];
}

interface BindUserPayload {
  user_id: number;
}

type NotificationSocketPayload = Pick<
  UserNotificationRecord,
  'id' | 'biz_type' | 'biz_id' | 'title' | 'content' | 'status' | 'created_at' | 'read_at'
>;

const getQuestionRoomName = (questionId: number): string => {
  return `consultation:question:${questionId}`;
};

const getUserRoomName = (userId: number): string => {
  return `user:${userId}`;
};

const handleJoinQuestion = (socket: Socket, payload: JoinQuestionPayload): void => {
  if (!payload || typeof payload.question_id !== 'number' || payload.question_id <= 0) {
    socket.emit('error', {
      code: 'INVALID_PAYLOAD',
      message: 'question_id 必须为正整数'
    });
    return;
  }

  const room = getQuestionRoomName(payload.question_id);
  socket.join(room);
  socket.emit('joined_question', {
    question_id: payload.question_id
  });
};

const handleLeaveQuestion = (socket: Socket, payload: { question_id: number }): void => {
  if (!payload || typeof payload.question_id !== 'number' || payload.question_id <= 0) {
    socket.emit('error', {
      code: 'INVALID_PAYLOAD',
      message: 'question_id 必须为正整数'
    });
    return;
  }

  const room = getQuestionRoomName(payload.question_id);
  socket.leave(room);
  socket.emit('left_question', {
    question_id: payload.question_id
  });
};

const handleSendMessage = async (io: Server, socket: Socket, payload: SendMessagePayload) => {
  if (!payload || typeof payload.question_id !== 'number' || payload.question_id <= 0) {
    socket.emit('send_message:ack', {
      success: false,
      message: '发送失败：question_id 必须为正整数'
    });
    return;
  }

  if (!payload.sender_type || !payload.content_type) {
    socket.emit('send_message:ack', {
      success: false,
      message: '发送失败：sender_type 和 content_type 为必填项'
    });
    return;
  }

  const questionId = payload.question_id;

  // 注意：消息持久化已由前端通过HTTP API完成
  // Socket仅负责将消息广播给房间内的其他客户端
  try {
    socket.emit('send_message:ack', {
      success: true,
      message: '广播成功'
    });

    // 广播消息到房间（包括发送者，前端会通过ID去重）
    const room = getQuestionRoomName(questionId);
    io.to(room).emit('new_message', payload);
  } catch (error: unknown) {
    const err = error as { message?: unknown } | null;
    const errorMessage =
      typeof err?.message === 'string' ? err.message : '广播失败：服务器内部错误';

    socket.emit('send_message:ack', {
      success: false,
      message: `广播失败：${errorMessage}`
    });
  }
};

const handleBindUser = (socket: Socket, payload: BindUserPayload): void => {
  if (!payload || typeof payload.user_id !== 'number' || payload.user_id <= 0) {
    socket.emit('error', {
      code: 'INVALID_PAYLOAD',
      message: 'user_id 必须为正整数'
    });
    return;
  }

  const room = getUserRoomName(payload.user_id);
  socket.join(room);
  socket.emit('bind_user:ack', {
    success: true,
    user_id: payload.user_id
  });
};

export const initSocketServer = (httpServer: HttpServer): Server => {
  const io = new Server(httpServer, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
      credentials: true
    }
  });

  ioInstance = io;

  console.log('[WebSocket] WebSocket 服务器初始化成功');

  io.on('connection', socket => {
    console.log(`[WebSocket] 客户端已连接 - Socket ID: ${socket.id}`);

    socket.on('join_question', payload => {
      console.log("[WebSocket] join_question", payload);
      handleJoinQuestion(socket, payload);
    });

    socket.on('leave_question', payload => {
      console.log("[WebSocket] leave_question", payload);
      handleLeaveQuestion(socket, payload);
    });

    socket.on('send_message', payload => {
      handleSendMessage(io, socket, payload);
    });

    socket.on('bind_user', payload => {
      handleBindUser(socket, payload as BindUserPayload);
    });

    socket.on('disconnect', reason => {
      console.log(`[WebSocket] 客户端已断开连接 - Socket ID: ${socket.id}, 原因: ${reason}`);
    });

    // ==================== 测试事件（仅用于调试） ====================

    socket.on('test:push_consultation_reply', payload => {
      console.log("[WebSocket] test:push_consultation_reply", payload);
      const { question_id, sender_id, sender_name, message_preview } = payload || {};
      if (!question_id) {
        return;
      }
      emitConsultationReplyNotification(
        question_id,
        sender_id || 999,
        sender_name || '测试用户',
        message_preview || '这在是一条测试回复消息'
      );
    });

    socket.on('test:push_task_reminder', payload => {
      console.log("[WebSocket] test:push_task_reminder", payload);
      const { user_id, task_date, pending_tasks } = payload || {};
      if (!user_id) {
        return;
      }
      emitTaskReminderNotification(
        user_id,
        task_date || new Date().toISOString().split('T')[0],
        pending_tasks || [
          { task_id: 101, item_name: '测试任务-测血压', task_time: '08:00' },
          { task_id: 102, item_name: '测试任务-吃药', task_time: '12:00' }
        ]
      );
    });

    socket.on('test:push_task_checkin', payload => {
      console.log("[WebSocket] test:push_task_checkin", payload);
      const { medical_staff_id, task_id, elder_name, item_name } = payload || {};
      if (!medical_staff_id) {
        return;
      }
      emitTaskCheckinNotification(
        medical_staff_id,
        task_id || 201,
        elder_name || '测试老人',
        item_name || '测试任务-康复训练'
      );
    });
  });

  return io;
};

export const emitNotificationToUser = (
  userId: number,
  notification: NotificationSocketPayload
): void => {
  if (!ioInstance) {
    return;
  }
  const room = getUserRoomName(userId);
  ioInstance.to(room).emit('notification:new', notification);
};

// ==================== 新增通知推送方法 ====================

// 咨询回复通知数据结构
interface ConsultationReplyNotification {
  type: 'CONSULTATION_REPLY';
  question_id: number;
  sender_id: number;
  sender_name: string;
  message_preview: string;
  created_at: string;
}

// 任务提醒通知数据结构
interface TaskReminderNotification {
  type: 'TASK_REMINDER';
  task_date: string;
  pending_tasks: Array<{
    task_id: number;
    item_name: string;
    task_time: string;
  }>;
  message?: string; // 展示的提醒文案
  elder_name?: string; // 关联的老人姓名
}

// 任务签到通知数据结构
interface TaskCheckinNotification {
  type: 'TASK_CHECKIN';
  task_id: number;
  elder_name: string;
  item_name: string;
  complete_time: string;
}

/**
 * 推送咨询回复通知到指定问题房间
 * @param questionId 问题ID
 * @param senderId 发送者ID
 * @param senderName 发送者名称
 * @param messagePreview 消息预览
 */
export const emitConsultationReplyNotification = (
  questionId: number,
  senderId: number,
  senderName: string,
  messagePreview: string
): void => {
  if (!ioInstance) {
    console.warn('[Socket] Cannot emit consultation reply notification: ioInstance is null');
    return;
  }

  const notification: ConsultationReplyNotification = {
    type: 'CONSULTATION_REPLY',
    question_id: questionId,
    sender_id: senderId,
    sender_name: senderName,
    message_preview: messagePreview,
    created_at: new Date().toISOString()
  };

  const room = getQuestionRoomName(questionId);
  ioInstance.to(room).emit('notification:consultation_reply', notification);
  console.log(`[Socket] Emitted consultation reply notification to room: ${room}`);
};

/**
 * 推送任务提醒通知到指定用户
 * @param userId 用户ID
 * @param taskDate 任务日期
 * @param pendingTasks 未完成任务列表
 * @param message 自定义展示文案（可选）
 * @param elderName 关联的老人姓名（可选）
 */
export const emitTaskReminderNotification = (
  userId: number,
  taskDate: string,
  pendingTasks: Array<{ task_id: number; item_name: string; task_time: string }>,
  message?: string,
  elderName?: string
): void => {
  if (!ioInstance) {
    console.warn('[Socket] Cannot emit task reminder notification: ioInstance is null');
    return;
  }

  const notification: TaskReminderNotification = {
    type: 'TASK_REMINDER',
    task_date: taskDate,
    pending_tasks: pendingTasks,
    message,
    elder_name: elderName
  };

  const room = getUserRoomName(userId);
  ioInstance.to(room).emit('notification:task_reminder', notification);
  console.log(`[Socket] Emitted task reminder notification to user: ${userId}`);
};

/**
 * 推送任务签到通知到指定医护人员
 * @param medicalStaffId 医护人员ID
 * @param taskId 任务ID
 * @param elderName 老人姓名
 * @param itemName 任务项名称
 */
export const emitTaskCheckinNotification = (
  medicalStaffId: number,
  taskId: number,
  elderName: string,
  itemName: string
): void => {
  if (!ioInstance) {
    console.warn('[Socket] Cannot emit task checkin notification: ioInstance is null');
    return;
  }

  const notification: TaskCheckinNotification = {
    type: 'TASK_CHECKIN',
    task_id: taskId,
    elder_name: elderName,
    item_name: itemName,
    complete_time: new Date().toISOString()
  };

  const room = getUserRoomName(medicalStaffId);
  ioInstance.to(room).emit('notification:task_checkin', notification);
  console.log(`[Socket] Emitted task checkin notification to medical staff: ${medicalStaffId}`);
};

