//
//  AppDelegate.swift
//  OPass
//
//  Created by Brian Chang on 2026/9/25.
//  2026 OPass.
//

import FirebaseAnalytics
import FirebaseAppCheck
import FirebaseCore
import FirebaseMessaging
import OSLog
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate, ObservableObject {
    /// Event whose announcements to open after the user tapped one of its push notifications.
    @Published var announcementEventId: String?

    private let logger = Logger(subsystem: "OPassApp", category: "AppDelegate")

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppCheck.setAppCheckProviderFactory(OPassAppCheckProviderFactory())  // Must be set before configure()
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        // Topics are subscribed even if the user declines, so pushes arrive once allowed in Settings.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { accepted, _ in
            self.logger.info("User accepted notifications: \(accepted)")
        }
        application.registerForRemoteNotifications()
        return true
    }

    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        // Analytics uploads through a background URL session and needs its events forwarded.
        Analytics.handleEvents(forBackgroundURLSession: identifier, completionHandler: completionHandler)
    }

    // MARK: - APNs & FCM Registration
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.error("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func messaging(_ messaging: Messaging, didReceiveRegistration installationId: String?) {
        guard installationId != nil else { return }
        PushTopicManager.shared.registrationDidUpdate()
    }

    // MARK: - Notifications
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Messaging.messaging().appDidReceiveMessage(notification.request.content.userInfo)
        completionHandler([.list, .banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        openGatewayNotification(userInfo)
        completionHandler()
    }

    /// Opens the HTTPS link of a Push Gateway notification, or else the announcements of its event.
    private func openGatewayNotification(_ userInfo: [AnyHashable: Any]) {
        guard userInfo["push_id"] is String, let eventId = userInfo["event_id"] as? String else { return }
        if let uri = userInfo["uri"] as? String {
            if let url = URL(string: uri), url.scheme?.lowercased() == "https" {
                UIApplication.shared.open(url)
            }
        } else {
            announcementEventId = eventId
        }
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
