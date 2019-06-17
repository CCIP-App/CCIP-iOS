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
        NSLog("Notification Registered: \(notification)")
    }

    static func RangeBeacon(_ beacon: CLBeacon? = nil) {
        if 1.seconds.fromNow.isBeforeDate(OPassAPI.NextAcceptedBeaconScanMessageTime, granularity: .minute) {
            return
        } else {
            OPassAPI.NextAcceptedBeaconScanMessageTime = 1.minutes.fromNow
        }
        let beaconWelcome = "BeaconWelcomeMessage_\(beacon == nil ? "Out" : "In")"
        let time = 30.seconds.fromNow
        if beacon != nil {
            OPassAPI.GetCurrentStatus() { (success: Bool, obj: Any?, error: Error) in
                if success && obj != nil {
                    for scenario in JSON(obj!)["scenarios"].arrayValue {
                        let id = scenario["id"].stringValue
                        if id.hasPrefix("day") && id.hasSuffix("checkin") && scenario["used"].double == nil {
                            let available = Date.init(timeIntervalSince1970: scenario["available_time"].doubleValue)
                            let expire = Date.init(timeIntervalSince1970: scenario["expire_time"].doubleValue)
                            if 0.seconds.fromNow.isInRange(date: available, and: expire, orEqual: true, granularity: .day) {
                                OPassAPI.RegisteringNotification(
                                    id: beaconWelcome,
                                    title: NSLocalizedString("\(beaconWelcome)_Title", comment: ""),
                                    content: NSLocalizedString("\(beaconWelcome)_Content", comment: ""),
                                    time: time
                                )
                                OPassAPI.NextAcceptedBeaconScanMessageTime = 30.minutes.fromNow
                            }
                        }
                    }
                }
            }
        }
    }

}
