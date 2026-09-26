//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Brian Chang on 2026/9/25.
//  2026 OPass.
//

import FirebaseMessaging
import UserNotifications

/// Shows the notification unchanged and exports its delivery for FCM reporting.
class NotificationService: UNNotificationServiceExtension {
    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var content: UNNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        self.content = request.content
        
        Messaging.serviceExtension().exportDeliveryMetricsToBigQuery(withMessageInfo: request.content.userInfo)
        deliver()
    }

    override func serviceExtensionTimeWillExpire() {
        deliver()
    }

    private func deliver() {
        guard let contentHandler, let content else { return }
        self.contentHandler = nil
        contentHandler(content)
    }
}
