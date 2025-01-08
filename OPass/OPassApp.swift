//
//  OPassApp.swift
//  OPass
//
//  Created by 張智堯 on 2022/2/28.
//  2023 OPass.
//

import FirebaseAnalytics
import FirebaseAppCheck
import FirebaseCore
import FirebaseDynamicLinks
import OSLog
import OneSignalFramework
import SwiftUI

@main
struct OPassApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage("UserInterfaceStyle") private var interfaceStyle = UIUserInterfaceStyle.unspecified
    @StateObject private var store = OPassStore()
    @State var url: URL? = nil

    init() {
        AppCheck.setAppCheckProviderFactory(OPassAppCheckProviderFactory())
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
            .overrideUserInterfaceStyle = interfaceStyle
        SoundManager.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(url: $url)
                .preferredColorScheme(.init(interfaceStyle))
                .environmentObject(store)
                .onOpenURL { url in
                    if DynamicLinks.dynamicLinks().handleUniversalLink(
                        url,
                        completion: { dynamicLink, _ in
                            if let url = dynamicLink?.url {
                                UIApplication.currentUIWindow()?.rootViewController?.dismiss(
                                    animated: true)
                                self.url = url
                            }
                        })
                    {
                        return
                    }
                    if let url = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)?
                        .url
                    {
                        UIApplication.currentUIWindow()?.rootViewController?.dismiss(animated: true)
                        self.url = url
                        return
                    }
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private let logger = Logger(subsystem: "OPassApp", category: "AppDelegate")

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // MARK: - Configure OneSignal
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        OneSignal.initialize(
            "b6213f49-e356-4b48-aa9d-7cf10ce1904d", withLaunchOptions: launchOptions)
        OneSignal.Notifications.requestPermission(
            { accepted in
                self.logger.info("User accepted notifications: \(accepted)")
            }, fallbackToSettings: false)
        return true
    }
}

class OPassAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if targetEnvironment(simulator)
            return AppCheckDebugProvider(app: app)
        #else
            return AppAttestProvider(app: app)
        #endif
    }
}
