//
//  EmbeddedTabBarControllerSegue.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/10/7.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation
import UIKit

class EmbeddedTabBarControllerSegue : UIStoryboardSegue {
    override func perform() {
        let sourceView : UIView = self.source.view
        let destinationView : UIView = self.destination.view
        var frame : CGRect = sourceView.frame
        frame.size.height -= self.source.view.safeAreaInsets.bottom
        self.source.present(self.destination, animated: true) {
            destinationView.superview!.frame = frame
            destinationView.superview!.clipsToBounds = true
        }
    }
}
