//
//  UIApplication+Extension.swift
//  OPass
//
//  Created by 張智堯 on 2022/7/1.
//  2023 OPass.
//

import Foundation
import UIKit

extension UIApplication {
    static func currentUIWindow() -> UIWindow? {
        let connectedScenes = self.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }
        
        return window
    }
    static func topViewController() -> UIViewController? {
        var presentedViewController: UIViewController? = nil
        let currentUIWindow = self.currentUIWindow()
        if var topController = currentUIWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            presentedViewController = topController
        }
        return presentedViewController
    }
    static func endEditing() {
        self.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
