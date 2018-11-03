//
//  UIApplication+addition.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation

@objc extension UIApplication {
    static func getMostTopPresentedViewController() -> UIViewController? {
        var vc : UIViewController? = UIApplication.shared.keyWindow?.rootViewController;
        while (vc!.presentedViewController != nil) {
            vc = vc!.presentedViewController;
        }
        return vc;
    }
}
