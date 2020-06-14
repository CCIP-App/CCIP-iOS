//
//  iBeaconNotification.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON
import SwiftDate
import DLLocalNotifications

extension OPassAPI {
    static var NextAcceptedBeaconScanMessageTime: Date {
        get {
            let ud = UserDefaults.standard;
            ud.synchronize()
            let lastMsgTime = ud.double(forKey: "NextAcceptedBeaconScanMessageTime")
            if lastMsgTime == 0 {
                return 0.minutes.fromNow
            } else {
                return Date.init(timeIntervalSince1970: lastMsgTime)
            }
        }
        set {
            let ud = UserDefaults.standard;
            ud.synchronize()
            ud.set(newValue.timeIntervalSince1970, forKey: "NextAcceptedBeaconScanMessageTime")
            ud.synchronize()
        }
    }

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
