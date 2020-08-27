//
//  UIApplication+addition.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  2018 OPass.
//

import Foundation

extension UIApplication {
    static func getMostTopPresentedViewController() -> UIViewController? {
        var presentedViewController: UIViewController? = nil
        let keyWindow = UIApplication.shared.windows.filter{ $0.isKeyWindow }.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            presentedViewController = topController
            // topController should now be your topmost view controller
        }
        return presentedViewController
    }
}
