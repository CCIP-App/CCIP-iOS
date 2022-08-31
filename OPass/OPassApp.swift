//
//  OPassApp.swift
//  OPass
//
//  Created by 張智堯 on 2022/2/28.
//  2022 OPass.
//

import SwiftUI
import OneSignal
import Firebase
import FirebaseAnalytics

@main
struct OPassApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("UserInterfaceStyle") var interfaceStyle: UIUserInterfaceStyle = .unspecified
    @State var url: URL? = nil
    
    init() {
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).overrideUserInterfaceStyle = interfaceStyle
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(url: $url)
                .onOpenURL { url in
                    //It seems that both universal link and custom schemed url from firebase are received via onOpenURL, so we must try parse it in both ways.
                    if DynamicLinks.dynamicLinks().handleUniversalLink(url, completion: { dynamicLink, _ in
                        if let url = dynamicLink?.url {
                            UIApplication.currentUIWindow()?.rootViewController?.dismiss(animated: true)
                            self.url = url
                        }
                    }) { return }
                    
                    if let url = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)?.url {
                        UIApplication.currentUIWindow()?.rootViewController?.dismiss(animated: true)
                        self.url = url
                        return
                    }
                }
                .preferredColorScheme(.init(interfaceStyle))
        }
    }
}

// Only use this as a last resort. Always try to use SwiftUI lifecycle
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure OneSignal
        let notificationReceiverBlock: OSNotificationWillShowInForegroundBlock = { notification,_  in
            print("Received Notification - \(notification.notificationId ?? "")")
        }
        
        let notificationOpenedBlock: OSNotificationOpenedBlock = { result in
            // This block gets called when the user reacts to a notification received
            let notification: OSNotification = result.notification
            
            var messageTitle = "OneSignal Message"
            var fullMessage = notification.body?.copy() as? String ?? ""
            
            if notification.additionalData != nil {
                if notification.title != nil {
                    messageTitle = notification.title ?? ""
                }

                if let additionData = notification.additionalData as? Dictionary<String, String> {
                    if let actionSelected = additionData["actionSelected"] {
                        fullMessage = "\(fullMessage)\nPressed ButtonId:\(actionSelected)"
                    }
                }
            }
            print("OneSignal Notification \(messageTitle): \(fullMessage)")
        }
        
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("b6213f49-e356-4b48-aa9d-7cf10ce1904d")
        OneSignal.setNotificationWillShowInForegroundHandler(notificationReceiverBlock)
        OneSignal.setNotificationOpenedHandler(notificationOpenedBlock)
        OneSignal.setLocationShared(false)
        
        return true
    }
}
