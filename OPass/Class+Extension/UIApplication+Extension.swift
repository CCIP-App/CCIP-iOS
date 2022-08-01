//
//  UIApplication+Extension.swift
//  OPass
//
//  Created by 張智堯 on 2022/7/1.
//  2022 OPass.
//

import Foundation
import UIKit

extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
    }
}
