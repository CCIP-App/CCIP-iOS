//
//  UNUserNotification.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/8.
//  2022 OPass.
//

import Foundation
import UserNotifications
import SwiftDate
import OSLog

class UNUserNotification {
    private static let logger = Logger(subsystem: "app.opass.ccip", category: "UNUserNotification")
    static func registeringNotification(
        id: String,
        title: String,
        content: String,
        rawTime: DateInRegion,
        cancel: Bool = false
    ) {
        let NotificationCenter = UNUserNotificationCenter.current()
        
        if !cancel {
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = title
            notificationContent.body = content
            notificationContent.sound = .default
            
            let time = rawTime - 5.minutes // T minus 5 minutes to trigger
            var dateComp = DateComponents()
            dateComp.month = time.month
            dateComp.day = time.day
            dateComp.hour = time.hour
            dateComp.minute = time.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: notificationContent, trigger: trigger)
            NotificationCenter.add(request) { (error : Error?) in
                if let theError = error {
                    logger.error("Error: \(theError as NSObject)")
                }
            }
        } else {
            NotificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        }
        logger.info("Notification Registered: \(NotificationCenter.debugDescription)")
#if DEBUG
        NotificationCenter.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print(request)
            }
        })
#endif
    }
}
