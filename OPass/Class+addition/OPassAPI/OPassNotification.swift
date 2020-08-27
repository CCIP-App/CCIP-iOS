//
//  OPassNotification.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  2019 OPass.
//

import Foundation
import CoreLocation
import SwiftyJSON
import SwiftDate
import DLLocalNotifications

extension OPassAPI {
    static func RegisteringNotification(
        id: String,
        title: String,
        content: String,
        time: Date,
        isDisable: Bool = false
    ) {
        let notification = DLNotification(
            identifier: id,
            alertTitle: title,
            alertBody: content,
            date: time,
            repeats: .none,
            soundName: ""
        )
        let scheduler = DLNotificationScheduler()
        scheduler.scheduleNotification(notification: notification)
        scheduler.scheduleAllNotifications()
        if isDisable {
            scheduler.cancelNotification(notification: notification)
            scheduler.scheduleAllNotifications()
        }
        NSLog("Notification Registered: \(notification.debugDescription)")
        #if DEBUG
        scheduler.printAllNotifications()
        #endif
    }
}
