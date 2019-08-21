//
//  UIAlertController+additional.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/10/7.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation
import UIKit

@objc extension UIAlertController {
    var titleLabel : UILabel {
        get {
            return self.viewArray(self.view)[0] as! UILabel
        }
    }
    var messageLabel : UILabel {
        get {
            return self.viewArray(self.view)[1] as! UILabel
        }
    }
    func viewArray(_ root: UIView) -> NSArray {
        var _subviews : NSArray? = nil
        for v : UIView in root.subviews {
            if (_subviews != nil) {
                break
            }
            if (v.isKind(of: UILabel.self)) {
                _subviews = root.subviews as NSArray
                return _subviews!
            }
            return self.viewArray(v)
        }
        return _subviews!
    }

    static func actionSheet(
        _ sender: Any,
        withTitle: String,
        andMessage: String
        ) -> UIAlertController {
        let ac : UIAlertController = self.init(title: withTitle, message: andMessage, preferredStyle: UIAlertController.Style.actionSheet)
        var sd : UIView? = sender as? UIView
        var frame : CGRect = sd!.frame
        frame.origin.x += frame.size.width / 2.0
        frame.origin.y += frame.size.height / 2.0
        frame.size.width = 1.0
        frame.size.height = 1.0
        sd = sd!.superview
        while (!sd.self!.description.hasSuffix("ViewController") && sd != nil) {
            let f : CGRect = sd!.frame
            sd = sd!.superview
            frame.origin.x += f.origin.x
            frame.origin.y += f.origin.y
        }
        ac.popoverPresentationController?.sourceView = UIApplication.getMostTopPresentedViewController()?.view
        ac.popoverPresentationController?.sourceRect = frame
        return ac
    }
    @objc static func alertOfTitle(
        _ title: String?,
        withMessage: String?,
        cancelButtonText: String,
        cancelStyle: UIAlertAction.Style,
        cancelAction: ((UIAlertAction) -> Void)?
        ) -> UIAlertController {
        let ac : UIAlertController = self.init(title: title, message: withMessage, preferredStyle: UIAlertController.Style.alert)
        ac.modalPresentationStyle = UIModalPresentationStyle.popover
        ac.addActionButton(cancelButtonText, style: cancelStyle, handler: cancelAction)
        return ac
    }
    func showAlert(
        _ completion: @escaping () -> Void
        ) {
        UIApplication.getMostTopPresentedViewController()?.present(self, animated: true, completion: completion)
    }
    func addActionButton(
        _ title: String,
        style: UIAlertAction.Style,
        handler: ((UIAlertAction) -> Void)?
        ) {
        let action : UIAlertAction = UIAlertAction.init(title: title, style: style, handler: handler)
        self.addAction(action)
    }
}
