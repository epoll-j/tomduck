import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private var proxyService: ProxyService?
    private var localService = LocalService()
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var saveEventSink: FlutterEventSink?
    
    override func application (
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let messenger: FlutterBinaryMessenger = window?.rootViewController as! FlutterBinaryMessenger
        notificationCenterObserver()
        createHtdocs()
        flutterMessengerHandler(messenger: messenger)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func notificationCenterObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCenterHandler), name: NSNotification.Name("save_session"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCenterHandler), name: NSNotification.Name("save_task"), object: nil)
    }
    
    @objc func notificationCenterHandler(_ notify: NSNotification) {
        if notify.name.rawValue.hasPrefix("save") {
            self.saveEventSink?(["event": notify.name.rawValue, "data": notify.object])
        }
    }
    
    func flutterMessengerHandler(messenger: FlutterBinaryMessenger) {
        self.methodChannel = FlutterMethodChannel(name: "iflow.epoll.dev/method_channel", binaryMessenger: messenger)
        self.eventChannel = FlutterEventChannel(name: "iflow.epoll.dev/event_channel", binaryMessenger: messenger)
        self.eventChannel?.setStreamHandler(self)
        
        self.methodChannel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if (call.method.hasPrefix("setId")) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setId_\(call.method.replacingOccurrences(of: "setId_", with: ""))"), object: call.arguments!)
            } else {
                switch call.method {
                case "start_proxy":
                    if let arg = call.arguments as? NSDictionary {
                        if (self.proxyService == nil) {
                            self.proxyService = ProxyService.create(arg)
                        }
                    }
                    self.proxyService?.run({ _ in
                        result(["code": 1, "data": ["wifi": NetworkInfo.LocalWifiIPv4(), ]] as [String : Any])
                    })
                case "stop_proxy":
                    self.proxyService?.close({
                        self.proxyService = nil
                        result(["code": 1])
                    })
                case "start_local_http_service":
                    self.localService.run()
                case "stop_local_http_service":
                    self.localService.close()
                case "get_proxy_state":
                    result(["code": 1, "data": self.proxyService?.wifiState ?? .closed] as [String : Any])
                default: break
                    
                }
            }
        }
    }
    
    func createHtdocs() {
        let fileManager = FileManager.default
        let httpRootDir = LocalService.httpRootPath
        do {
            if !fileManager.fileExists(atPath: httpRootDir.path) {
                try fileManager.createDirectory(at: httpRootDir, withIntermediateDirectories: false)
            }
            let indexPath = httpRootDir.appendingPathComponent("index.html")
            if fileManager.fileExists(atPath: indexPath.path) {
                try fileManager.removeItem(atPath: indexPath.path)
            }
            if let bundlePath = Bundle.main.url(forResource: "index", withExtension: "html") {
                try fileManager.copyItem(at: bundlePath, to: indexPath)
            }
            let caPath = httpRootDir.appendingPathComponent("ca.pem", isDirectory: false)
            if fileManager.fileExists(atPath: caPath.path) {
                try fileManager.removeItem(atPath: caPath.path)
            }
            try? String(data: Data(cert), encoding: .utf8)?.write(to: caPath, atomically: true, encoding: .utf8)
        } catch {
            print("http root create failure: \(error.localizedDescription)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension AppDelegate: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if let argument = arguments as? String {
            if argument == "save_event" {
                self.saveEventSink = events
            }
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let argument = arguments as? String {
            if argument == "save_event" {
                self.saveEventSink = nil
            }
        }
        return nil
    }
}
