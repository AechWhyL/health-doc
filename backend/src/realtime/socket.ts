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

const getQuestionRoomName = (questionId: number): string => {
  return `consultation:question:${questionId}`;
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

  const data: CreateConsultationMessageRequest = {
    sender_type: payload.sender_type,
    sender_id: payload.sender_id,
    role_display_name: payload.role_display_name,
    content_type: payload.content_type,
    content_text: payload.content_text,
    attachments: payload.attachments
  };

  try {
    const message = await ConsultationService.createMessage(questionId, data);

    socket.emit('send_message:ack', {
      success: true,
      message: '发送成功',
      data: message
    });

    const room = getQuestionRoomName(questionId);
    io.to(room).emit('new_message', message);
  } catch (error: unknown) {
    const err = error as { message?: unknown } | null;
    const errorMessage =
      typeof err?.message === 'string' ? err.message : '发送失败：服务器内部错误';

    if (errorMessage.includes('咨询问题不存在')) {
      socket.emit('send_message:ack', {
        success: false,
        message: `发送失败：${errorMessage}`
      });
      socket.emit('error', {
        code: 'QUESTION_NOT_FOUND',
        message: errorMessage
      });
      return;
    }

    socket.emit('send_message:ack', {
      success: false,
      message: `发送失败：${errorMessage}`
    });
    socket.emit('error', {
      code: 'INTERNAL_ERROR',
      message: errorMessage
    });
  }
};

export const initSocketServer = (httpServer: HttpServer): Server => {
  const io = new Server(httpServer, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
      credentials: true
    }
  });

  io.on('connection', socket => {
    socket.on('join_question', payload => {
      handleJoinQuestion(socket, payload);
    });

    socket.on('leave_question', payload => {
      handleLeaveQuestion(socket, payload);
    });

    socket.on('send_message', payload => {
      handleSendMessage(io, socket, payload);
    });
  });

  return io;
};

