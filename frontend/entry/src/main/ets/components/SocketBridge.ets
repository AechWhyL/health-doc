import { webview } from '@kit.ArkWeb';
import { SocketService } from '../common/api/SocketService';

@Component
export struct SocketBridge {
  controller: webview.WebviewController = new webview.WebviewController();
  @State isReady: boolean = false;
  onWebControllerAttached: () => void = () => {
  }

  // aboutToAppear() {
  //   // 注入控制器到 SocketService
  //   SocketService.getInstance().setWebController(this.controller);
  //   webview.WebviewController.setWebDebuggingAccess(true,9222)
  //   this.onWebControllerSet()
  // }



  build() {
    Column() {
      Web({
        src: $rawfile('socket_bridge.html'),
        controller: this.controller
      })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .javaScriptProxy({
          object: {
            proxyTest: ()=>{
              console.log('[socket debug] proxyTest');
            },
            postMessage: (msg: string) => {
              console.log('[socket debug] from js socket bridge:' + msg)
              try {
                const event = JSON.parse(msg) as BridgeEvent;
                if (event.type === 'event' && event.event) {
                  SocketService.getInstance().handleBridgeEvent(event.event, event.data || '');
                } else if (event.type === 'connect') {
                  SocketService.getInstance().handleBridgeEvent('connect', '');
                } else if (event.type === 'disconnect') {
                  SocketService.getInstance().handleBridgeEvent('disconnect', event.data || '');
                }
              } catch (e) {
                console.error('Bridge parse error:', e);
              }
            }
          },
          name: "bridgeProxy",
          methodList: ["postMessage"],
          controller: this.controller
        })
        .onPageBegin(() => {
          this.isReady = true;
        })
        .onControllerAttached(() => {
          // 注入控制器到 SocketService
          console.log("[socket debug] web controller attached")
          SocketService.getInstance().setWebController(this.controller);
          webview.WebviewController.setWebDebuggingAccess(true, 9222)
        })
        .onPageEnd(()=>{
          this.onWebControllerAttached()
        })
        .width('1px')
        .height('1px')
        // .visibility(Visibility.Hidden)
    }
    .width('100%')
    .height('100%')
  }
}

interface BridgeEvent {
  type: string;
  event?: string;
  data?: string;
}
