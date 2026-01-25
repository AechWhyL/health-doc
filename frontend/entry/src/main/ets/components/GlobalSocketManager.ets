import { SocketBridge } from './SocketBridge';
import { SocketService } from '../common/api/SocketService';
import { BASEURL } from '../common/api/httpEnum';

/**
 * 全局 WebSocket 管理器组件
 * 负责在应用级别初始化 WebSocket 连接
 */
@Component
export struct GlobalSocketManager {
  // 初始化完成回调
  onInitialized: () => void = () => {};
  private socketService: SocketService | null = null;

  build() {
    // 使用隐藏的 1px×1px Web 视图，不影响页面布局
    SocketBridge({
      onWebControllerAttached: () => {
        console.log('[GlobalSocketManager] WebController attached, initializing SocketService');
        this.socketService = SocketService.getInstance();
        
        // 初始化 WebSocket 连接
        this.socketService.init(BASEURL.baseUrl);
        
        // 通知初始化完成
        console.log('[GlobalSocketManager] SocketService initialized');
        this.onInitialized();
      }
    })
  }
}
