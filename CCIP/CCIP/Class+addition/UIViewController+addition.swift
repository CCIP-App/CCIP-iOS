//
//  UIViewController+addition.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation
import UIKit

@objc extension UIView {
    func topGuideHeight() -> CGFloat {
        return (self.next as! UIViewController).topGuideHeight();
    }

    func bottomGuideHeight() -> CGFloat {
        return (self.next as! UIViewController).bottomGuideHeight();
    }
}

@objc extension UIViewController {
    func topGuideHeight() -> CGFloat {
        var guide : CGFloat = 0.0;
        if (self.navigationController.navigationBar.translucent) {
            if (self.prefersStatusBarHidden == false) {
                guide += 20;
            }
            if (self.navigationController.navigationBarHidden == false) {
                guide += self.navigationController.navigationBar.bounds.size.height;
            }
        }
        return guide;
    }

    func bottomGuideHeight() -> CGFloat {
        var guide : CGFloat = 0.0;
        if (self.tabBarController.tabBar.hidden == false) {
            guide += self.tabBarController.tabBar.bounds.size.height;
        }
        return guide;
    }

    func isVisible() -> Bool {
        return self.isViewLoaded && self.view.window;
    }
}
