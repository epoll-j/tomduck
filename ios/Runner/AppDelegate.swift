import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private var proxyService: ProxyService?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let messenger: FlutterBinaryMessenger = window?.rootViewController as! FlutterBinaryMessenger
        
        flutterMessengerHandler(messenger: messenger)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func flutterMessengerHandler(messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: "iflow.epoll.dev/method_channel", binaryMessenger: messenger)
        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            
            switch call.method {
            case "start_proxy":
                if (self.proxyService == nil) {
                    self.proxyService = ProxyService.create()
                }
                self.proxyService?.run({ _ in
                    result(["code": 1, "data": ["wifi": NetworkInfo.LocalWifiIPv4(), ]] as [String : Any])
                })
            case "close_proxy":
                self.proxyService?.close({
                    self.proxyService = nil
                    result(["code": 1])
                })
            case "get_proxy_state":
                result(["code": 1, "data": self.proxyService?.wifiState ?? .closed] as [String : Any])
            default: break
                
            }
        }
    }
}
