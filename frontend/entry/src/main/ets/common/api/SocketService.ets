// import { client_socket } from '@ohos/socketio';
import { webview } from "@kit.ArkWeb";
import { JSON } from "@kit.ArkTS";

// 定义通用接口
export interface ISocketClient {
  on(event: string, callback: (data: string) => void): void;

  emit(event: string, data: string): void;

  connect(uri: string): void;

  close(): void;

  set_open_listener(callback: () => void): void;

  set_close_listener(callback: (reason: string) => void): void;

  set_fail_listener(callback: () => void): void;

  set_reconnect_listener(callback: () => void): void;
}

// 模拟客户端 (用于降级)
export class MockSocketClient implements ISocketClient {
  private listeners: Map<string, Function[]> = new Map();
  private openCallback?: () => void;

  on(event: string, callback: (data: string) => void): void {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event)?.push(callback);
  }

  emit(event: string, data: string): void {
    console.log('[MockSocket] Emit:', event, data);
  }

  connect(uri: string): void {
    console.log('[MockSocket] Connecting to:', uri);
    setTimeout(() => {
      if (this.openCallback) {
        this.openCallback();
      }
    }, 1000);
  }

  close(): void {
  }

  set_open_listener(callback: () => void): void {
    this.openCallback = callback;
  }

  set_close_listener(callback: (reason: string) => void): void {
  }

  set_fail_listener(callback: () => void): void {
  }

  set_reconnect_listener(callback: () => void): void {
  }
}

// Web Bridge 客户端
export class BridgeSocketClient implements ISocketClient {
  private controller: webview.WebviewController;
  private eventHandlers: Map<string, (data: string) => void> = new Map();
  private openHandler?: () => void;
  private closeHandler?: (reason: string) => void;

  constructor(controller: webview.WebviewController) {
    this.controller = controller;
  }

  connect(uri: string): void {
    try {
      this.controller.runJavaScript(`window.bridge.connect('${uri}')`);
    } catch (e) {
      console.error('Bridge connect failed:', e);
    }
  }

  emit(event: string, data: string): void {
    try {
      if (!this.controller) {
        console.warn('[BridgeSocketClient] Emit failed: controller is null');
        return;
      }
      const safeData = data.replace(/'/g, "\\'");
      // 执行 JS。这里包裹 try catch 是因为如果 Web 组件正好在销毁，controller.runJavaScript 会抛出异常
      this.controller.runJavaScript(`window.bridge.emit('${event}', '${safeData}')`);
    } catch (e) {
      console.error('[BridgeSocketClient] Bridge emit failed:', e);
    }
  }

  on(event: string, callback: (data: string) => void): void {
    this.eventHandlers.set(event, callback);
  }

  close(): void {
    try {
      this.controller.runJavaScript(`window.bridge.disconnect()`);
    } catch (e) {
    }
  }

  // 由 SocketService 调用的内部方法
  handleEvent(event: string, data: string) {
    if (event === 'connect') {
      if (this.openHandler) {
        this.openHandler();
      }
    } else if (event === 'disconnect') {
      if (this.closeHandler) {
        this.closeHandler(data);
      }
    } else {
      const handler = this.eventHandlers.get(event);
      if (handler) {
        handler(data);
      }
    }
  }

  set_open_listener(callback: () => void): void {
    this.openHandler = callback;
  }

  set_close_listener(callback: (reason: string) => void): void {
    this.closeHandler = callback;
  }

  set_fail_listener(callback: () => void): void {
  }

  set_reconnect_listener(callback: () => void): void {
  }
}

@ObservedV2
export class SocketService {
  private static instance: SocketService;
  private client: ISocketClient | null = null;
  @Trace isConnected: boolean = false;
  private listeners: Map<string, Function[]> = new Map();
  private webController: webview.WebviewController | null = null;

  private constructor() {
  }

  public static getInstance(): SocketService {
    if (!SocketService.instance) {
      SocketService.instance = new SocketService();
    }
    return SocketService.instance;
  }

  public setWebController(controller: webview.WebviewController) {
    console.log('[socket debug] websocket webController set')
    this.webController = controller;
  }

  public handleBridgeEvent(event: string, data: string) {
    if (this.client instanceof BridgeSocketClient) {
      (this.client as BridgeSocketClient).handleEvent(event, data);
    }
  }

  public async init(uri: string): Promise<void> {
    console.log("[socket debug] trying to init Socket Service")
    
    // 如果已经初始化且连接正常，直接返回
    if (this.client && this.isConnected) {
      console.log("[socket debug] Socket Service already initialized and connected");
      return;
    }

    // 如果已经有 client 但未连接，先清理
    if (this.client && !this.isConnected) {
      console.log("[socket debug] Socket Service exists but not connected, cleaning up");
      this.client.close();
      this.client = null;
    }

    // 优先尝试使用 Web Bridge (如果已配置)
    if (this.webController) {
      this.client = new BridgeSocketClient(this.webController);
      console.log("[socket debug] using bridge SocketClient")
    } else {
      try {
        // const socketIo = await import('@ohos/socketio');
        // // 强制转换为 ISocketClient
        // this.client = new socketIo.client_socket() as Object as ISocketClient;
      } catch (e) {
        console.error('[socket debug] Failed to load @ohos/socketio, fallback to Mock:', e);
        this.client = new MockSocketClient();
      }
    }

    if (!this.client) {
      return;
    }

    console.log("[socket debug] setting up basic listener")

    // 设置基础监听
    this.client.set_open_listener(() => {
      console.info('[socket debug] SocketService: Connected');
      this.isConnected = true;
      this.notifyListeners('connect', '');
    });

    this.client.set_close_listener((reason: string) => {
      console.info('[socket debug] SocketService: Disconnected, reason:', reason);
      this.isConnected = false;
      this.notifyListeners('disconnect', reason);
    });

    this.client.set_fail_listener(() => {
      console.debug('[socket debug] SocketService: Connection failed');
    });

    this.client.set_reconnect_listener(() => {
      console.info('[socket debug] SocketService: Reconnected');
      this.isConnected = true;
    });

    // 注册业务事件监听
    this.client.on('joined_question', (data: string): void => {
      this.notifyListeners('joined_question', data);
    });
    this.client.on('left_question', (data: string): void => {
      this.notifyListeners('left_question', data);
    });
    this.client.on('new_message', (data: string): void => {
      this.notifyListeners('new_message', data);
    });
    this.client.on('send_message:ack', (data: string): void => {
      this.notifyListeners('send_message:ack', data);
    });
    this.client.on('error', (data: string): void => {
      this.notifyListeners('error', data);
    });

    // 注册通知事件监听
    this.client.on('notification:consultation_reply', (data: string): void => {
      this.notifyListeners('notification:consultation_reply', data);
    });
    this.client.on('notification:task_reminder', (data: string): void => {
      this.notifyListeners('notification:task_reminder', data);
    });
    this.client.on('notification:task_checkin', (data: string): void => {
      this.notifyListeners('notification:task_checkin', data);
    });

    console.log("[socket debug] trying to connect socket")
    this.client.connect(uri);
  }

  public connect(uri: string) {
    this.init(uri);
  }

  public close() {
    if (this.client) {
      console.debug("[socket debug] Socket Service close")
      this.client.close();
      this.client = null;
      this.isConnected = false;
    }
  }

  // --- 业务方法 ---

  public joinQuestion(questionId: number, userId: number, userType: string, displayName: string): void {
    if (!this.client) {
      console.log("[socket debug] join_question: this.client not is null")
      return;
    }
    const payload = JSON.stringify({
      question_id: questionId,
      user_id: userId,
      user_type: userType,
      role_display_name: displayName
    });
    this.client.emit('join_question', payload);
    console.log("[socket debug] join_question: ", JSON.stringify(payload));
  }

  public leaveQuestion(questionId: number): void {
    if (!this.client) {
      return;
    }
    const payload = JSON.stringify({
      question_id: questionId
    });
    this.client.emit('leave_question', payload);
  }

  public sendMessage(message: Record<string, Object> | string): void {
    if (!this.client) {
      return;
    }
    console.log("trying to send message,payload:" + message)
    this.client.emit('send_message', typeof message === 'string' ? message : JSON.stringify(message));
  }

  public bindUser(userId: number): void {
    if (!this.client) {
      return;
    }
    const payload = JSON.stringify({
      user_id: userId
    });
    console.log("[socket debug] Binding user to socket:", userId);
    this.client.emit('bind_user', payload);
  }

  // --- 事件订阅 ---

  public on<T>(event: string, callback: (data: T | string) => void) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event)?.push(callback);
  }

  public off(event: string, callback: Function) {
    if (!this.listeners.has(event)) {
      return;
    }
    const callbacks = this.listeners.get(event);
    if (callbacks) {
      const index = callbacks.indexOf(callback);
      if (index !== -1) {
        callbacks.splice(index, 1);
      }
    }
  }

  private notifyListeners(event: string, data: Object) {
    const callbacks = this.listeners.get(event);
    if (callbacks) {
      callbacks.forEach(cb => {
        try {
          // SocketIO 返回的数据通常是 JSON 字符串，尝试解析
          if (typeof data === 'string' && (data.startsWith('{') || data.startsWith('['))) {
            cb(JSON.parse(data));
          } else {
            cb(data);
          }
        } catch (e) {
          console.error(`Error handling event ${event}:`, e);
          cb(data);
        }
      });
    }
  }
}
