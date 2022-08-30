import os.log
import Flutter
import UIKit
import ChatSDK
import ChatProvidersSDK
import CommonUISDK
import MessagingSDK


public class SwiftZendeskPlugin: NSObject, FlutterPlugin {
    var chatAPIConfig: ChatAPIConfiguration?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "zendesk", binaryMessenger: registrar.messenger())
        let instance = SwiftZendeskPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let dic = call.arguments as? Dictionary<String, Any>
        
        switch call.method {
        case "getPlatformVersion":
            result("iOS yo " + UIDevice.current.systemVersion)
        case "initialize":
            initialize(dictionary: dic!)
            result(true)
        case "setVisitorInfo":
            setVisitorInfo(dictionary: dic!)
            result(true)
        case "startChat":
            do {
                try startChat(dictionary: dic!)
            } catch _ {
                os_log("error:")
            }
            result(true)
        case "addTags":
            addTags(dictionary: dic!)
            result(true)
        case "removeTags":
            removeTags(dictionary: dic!)
            result(true)
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
    
    func initialize(dictionary: Dictionary<String, Any>) {
        guard let accountKey = dictionary["accountKey"] as? String,
              let appId = dictionary["appId"] as? String
        else { return }
        
        Chat.initialize(accountKey: accountKey, appId: appId)
        initChatConfig()
    }
    
    func setVisitorInfo(dictionary: Dictionary<String, Any>) {
        guard let name = dictionary["name"] as? String,
              let email = dictionary["email"] as? String,
              let phoneNumber = dictionary["phoneNumber"] as? String
        else { return }
        let department = dictionary["department"] as? String ?? ""
        chatAPIConfig?.departmentName = department
        chatAPIConfig?.visitorInfo = VisitorInfo(name: name, email: email, phoneNumber: phoneNumber)
        Chat.instance?.configuration = chatAPIConfig!
    }
    
    func addTags(dictionary: Dictionary<String, Any>) {
        let tags = dictionary["tags"] as? Array<String> ?? []
        chatAPIConfig?.tags.append(contentsOf: tags)
        Chat.instance?.configuration = chatAPIConfig!
    }
    
    func removeTags(dictionary: Dictionary<String, Any>) {
        let tags = dictionary["tags"] as? Array<String> ?? []
        chatAPIConfig?.tags.removeAll(where: { t  in return tags.contains(t) })
        Chat.instance?.configuration = chatAPIConfig!
    }
    
    func startChat(dictionary: Dictionary<String, Any>) throws {
        guard let isPreChatFormEnabled = dictionary["isPreChatFormEnabled"] as? Bool,
              let isAgentAvailabilityEnabled = dictionary["isAgentAvailabilityEnabled"] as? Bool,
              let isChatTranscriptPromptEnabled = dictionary["isChatTranscriptPromptEnabled"] as? Bool,
              let isOfflineFormEnabled = dictionary["isOfflineFormEnabled"] as? Bool
        else {return}
        
        // Set Color Chat SDK Zendesk
        if let primaryColor = dictionary["primaryColor"] as? Int {
            CommonTheme.currentTheme.primaryColor = uiColorFromHex(rgbValue: primaryColor)
        }
        
        // Set Back Button with Title
        let navigationBarController = UINavigationBar.appearance()
        if let iosNavigationBarColor = dictionary["iosNavigationBarColor"] as? Int{
            navigationBarController.barTintColor = uiColorFromHex(rgbValue: iosNavigationBarColor)
        }
        
        if let iosNavigationTitleColor = dictionary["iosNavigationTitleColor"] as? Int{
            let attributes = [NSAttributedString.Key.foregroundColor : uiColorFromHex(rgbValue: iosNavigationTitleColor)]
            navigationBarController.titleTextAttributes = attributes
        }
        
        let messagingConfiguration = MessagingConfiguration()
        
        // Name for Bot messages
        if let messagingName = dictionary["messagingName"] as? String{
            messagingConfiguration.name = messagingName
        }

        
        // Chat configuration
        let chatConfiguration = ChatConfiguration()
        chatConfiguration.isPreChatFormEnabled = isPreChatFormEnabled
        chatConfiguration.isAgentAvailabilityEnabled = isAgentAvailabilityEnabled
        chatConfiguration.isChatTranscriptPromptEnabled = isChatTranscriptPromptEnabled
        chatConfiguration.isOfflineFormEnabled = isOfflineFormEnabled
        
        
        // Build view controller
        let chatEngine = try ChatEngine.engine()
        let viewController = try Messaging.instance.buildUI(engines: [chatEngine], configs: [messagingConfiguration, chatConfiguration])
        viewController.title = "Chat With Us"
        
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.close))
        
        if let primaryColor = dictionary["iosBackButtonTitle"] as? Int {
            CommonTheme.currentTheme.primaryColor = uiColorFromHex(rgbValue: primaryColor)
        }
        
        
        // Present view controller
        let rootViewController = UIApplication.shared.windows.filter({ (w) -> Bool in
            return w.isHidden == false
        }).first?.rootViewController
        presentViewController(rootViewController: rootViewController, view: viewController);
    }
    
    
    func presentViewController(rootViewController: UIViewController?, view: UIViewController) {
        if (rootViewController is UINavigationController) {
            (rootViewController as! UINavigationController).pushViewController(view, animated: true)
        } else {
            let navigationController: UINavigationController! = UINavigationController(rootViewController: view)
            rootViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func uiColorFromHex(rgbValue: Int) -> UIColor {
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue =  CGFloat(rgbValue & 0x0000FF) / 255.0
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    @objc func close(_ sender: Any?) {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true)
    }
    
    func initChatConfig() {
        if (chatAPIConfig == nil) {
            chatAPIConfig = ChatAPIConfiguration()
        }
    }
}
