//
//  UNUserNotificationCenter+Extension.swift
//  OPass
//
//  Created by Brian Chang on 2026/9/26.
//  2026 OPass.
//

import UserNotifications

extension UNUserNotificationCenter {
    /// Removes an event's delivered notifications
    func removeAnnouncementNotifications(of eventId: String) async {
        let identifiers = await deliveredNotifications()
            .filter {
                let userInfo = $0.request.content.userInfo
                return userInfo["push_id"] is String && userInfo["event_id"] as? String == eventId
            }
            .map(\.request.identifier)
        removeDeliveredNotifications(withIdentifiers: identifiers)
    }
}
