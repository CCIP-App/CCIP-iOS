//
//  OPassApp.swift
//  OPass
//
//  Created by 張智堯 on 2022/2/28.
//  2022 OPass.
//

import SwiftUI
import Firebase
import OneSignal
import FirebaseAnalytics

@main
struct OPassApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("appearance") var appearance: Appearance = .system
    @State var url: URL? = nil
    
    init() {
        FirebaseApp.configure()
        if appearance != .system {
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).overrideUserInterfaceStyle = appearance == .dark ? .dark : .light
        }
        Analytics.setAnalyticsCollectionEnabled(true)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(url: $url)
                .onOpenURL { url in
                    // We use the way to universal link here, guaranteed by the swiftui doc that the passed in url being a universal link
                    let handled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, _ in
                        if let url = dynamicLink?.url {
                            self.url = url
                        }
                    }
                    if !handled {
                        // Non Firbase Dynamic Link
                        self.url = url
                    }
                }
                .onReceive(appDelegate.$dynamicURL) { url = $0 }
                .preferredColorScheme(appearance == .system ? nil :
                                        appearance == .dark ? .dark : .light)
                .environmentObject(OPassAPIViewModel())
        }
    }
}

// Only use this as a last resort. Always try to use SwiftUI lifecycle
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // Use this published property to notify SwiftUI lifecycle
    @Published var dynamicURL: URL? = nil
    
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
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
           print("User accepted notifications: ", accepted)
        }, fallbackToSettings: false)
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        Analytics.logEvent("dynamic_link_appdelegate", parameters: ["entry": "user_activity"])
        if let url = userActivity.webpageURL {
            NSLog("Receieved Activity URL -> \(url)");
            let handled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, _ in
                if let url = dynamicLink?.url {
                    self.dynamicURL = url
                }
            }
            if !handled {
                // Non Firbase Dynamic Link
                dynamicURL = url
            }
            return true
        }
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Analytics.logEvent("dynamic_link_appdelegate", parameters: ["entry": "url"])
        let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)
        if let dynamicLink = dynamicLink {
            if let url = dynamicLink.url {
                dynamicURL = url
            }
        } else {
            dynamicURL = url
            return true
        }
        return false
    }
}

enum Appearance: String, Codable {
    case system
    case light
    case dark
}
