//
//  OPassEventsController.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/3/2.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import then

class OPassEventsController : UIViewController {
    var progress: MBProgressHUD = MBProgressHUD.init()
    var opassEvents: Array<EventShortInfo> = Array<EventShortInfo>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.progress.mode = .indeterminate
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Constants.GetEvents().then { (events: Array<EventShortInfo>) in
            self.opassEvents = events
        }.then {
            NSLog("TODO: display events")
        }.then {
            self.progress.hide(animated: true)
        }.then {
            if self.opassEvents.count == 1 {
                self.LoadEvent(self.opassEvents.first!.EventId)
            }
        }
    }
    func LoadEvent(_ eventId: String) {
        Constants.SetEvent(eventId).then { (event: EventInfo) in
            if Constants.HasSetEvent {
                self.performSegue(withIdentifier: "OPassTabView", sender: event)
            }
        }
    }
}
