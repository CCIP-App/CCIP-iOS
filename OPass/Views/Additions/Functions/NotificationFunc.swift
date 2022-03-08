//
//  Notifications.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/8.
//

import Foundation
import UserNotifications
import SwiftDate

func requestNotificationAuthorization() {
    // Request Authorization
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { ( _ , error) in
        if let error = error {
            print("Request Authorization Failed (\(error), \(error.localizedDescription))")
        }
    }
}

func registeringNotification(
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
                print(theError)
            }
        }
    } else {
        NotificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    NotificationCenter.getPendingNotificationRequests(completionHandler: { requests in
        for request in requests {
            print(request)
        }
    })
}
