//
//  NotificationController.swift
//  OPass-Watch Extension
//
//  Created by 腹黒い茶 on 2019/3/2.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import WatchKit

class NotificationController: WKUserNotificationInterfaceController {
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    override func didReceive(_ localNotification: UILocalNotification, withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Void) {
        // This method is called when a notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        completionHandler(.custom);
    }
}
