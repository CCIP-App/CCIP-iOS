//
//  UIViewController+addition.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation
import UIKit

@objc extension UIViewController {
    var ViewTopStart: CGFloat {
        return self.view.ViewTopStart
    }
    var topGuideHeight: CGFloat {
        var guide : CGFloat = 0.0;
        if (self.navigationController!.navigationBar.isTranslucent) {
            if (self.prefersStatusBarHidden == false) {
                guide += 20;
            }
            if (self.navigationController!.isNavigationBarHidden == false) {
                guide += self.navigationController!.navigationBar.bounds.size.height;
            }
        }
        return guide;
    }

    var bottomGuideHeight: CGFloat {
        var guide : CGFloat = 0.0;
        if (self.tabBarController!.tabBar.isHidden == false) {
            guide += self.tabBarController!.tabBar.bounds.size.height;
        }
        return guide;
    }

    var isVisible: Bool {
        return self.isViewLoaded && (self.view!.window != nil);
    }
}
