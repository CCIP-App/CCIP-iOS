//
//  UIApplication+Extension.swift
//  OPass
//
//  Created by 張智堯 on 2022/7/1.
//  2025 OPass.
//

import Foundation
import UIKit

extension UIApplication {
    static func currentUIWindow() -> UIWindow? {
        let scene = shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        return scene?.windows.first(where: { $0.isKeyWindow })
    }

    static func topViewController() -> UIViewController? {
        var presentedViewController: UIViewController? = nil
        let currentUIWindow = currentUIWindow()
        if var topController = currentUIWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            presentedViewController = topController
        }
        return presentedViewController
    }

    static func endEditing() {
        shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    static var size: CGSize {
        guard let windowScene = shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return UIScreen.main.bounds.size }
        return windowScene.screen.bounds.size
    }
}
