//
//  UIViewController+addition.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  2018 OPass.
//

import Foundation
import UIKit

extension UIViewController {
    @objc var ViewTopStart: CGFloat {
        return self.view.ViewTopStart
    }
    var topGuideHeight: CGFloat {
        var guide: CGFloat = 0.0
        if let navController = self.navigationController {
            if (navController.navigationBar.isTranslucent) {
                if (self.prefersStatusBarHidden == false) {
                    guide += 20
                }
                if (navController.isNavigationBarHidden == false) {
                    guide += navController.navigationBar.bounds.size.height
                }
            }
        }
        return guide
    }

    var bottomGuideHeight: CGFloat {
        var guide: CGFloat = 0.0
        if let tabBarController = self.tabBarController {
            if (tabBarController.tabBar.isHidden == false) {
                guide += tabBarController.tabBar.bounds.size.height
            }
        }
        return guide
    }

    @objc var isVisible: Bool {
        return self.isViewLoaded && (self.view?.window != nil)
    }
}
