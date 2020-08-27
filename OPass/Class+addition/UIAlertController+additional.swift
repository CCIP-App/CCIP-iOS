//
//  UIAlertController+additional.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/10/7.
//  2018 OPass.
//

import Foundation
import UIKit

@objc extension UIAlertController {
    var titleLabel: UILabel {
        get {
            if let lb = self.viewArray(self.view)[0] as? UILabel {
                return lb
            }
            return UILabel.init()
        }
    }
    var messageLabel: UILabel {
        get {
            if let lb = self.viewArray(self.view)[1] as? UILabel {
                return lb
            }
            return UILabel.init()
        }
    }
    func viewArray(_ root: UIView) -> NSArray {
        let _subviews: NSArray? = nil
        for v: UIView in root.subviews {
            if (_subviews != nil) {
                break
            }
            if (v.isKind(of: UILabel.self)) {
                return root.subviews as NSArray
            }
            return self.viewArray(v)
        }
        if let sv = _subviews {
            return sv
        }
        return []
    }

    static func actionSheet(
        _ sender: Any,
        withTitle: String,
        andMessage: String
    ) -> UIAlertController {
        let ac: UIAlertController = self.init(title: withTitle, message: andMessage, preferredStyle: UIAlertController.Style.actionSheet)
        guard var sd = sender as? UIView else { return ac }
        var frame: CGRect = sd.frame
        frame.origin.x += frame.size.width / 2.0
        frame.origin.y += frame.size.height / 2.0
        frame.size.width = 1.0
        frame.size.height = 1.0
        if let _sd = sd.superview { sd = _sd }
        while (!sd.self.description.hasSuffix("ViewController")) {
            let f: CGRect = sd.frame
            if let _sd = sd.superview { sd = _sd }
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
        let ac: UIAlertController = self.init(title: title, message: withMessage, preferredStyle: UIAlertController.Style.alert)
        ac.modalPresentationStyle = UIModalPresentationStyle.popover
        ac.addActionButton(cancelButtonText, style: cancelStyle, handler: cancelAction)
        return ac
    }
    func showAlert(_ completion: @escaping () -> Void) {
        UIApplication.getMostTopPresentedViewController()?.present(self, animated: true, completion: completion)
    }
    func addActionButton(
        _ title: String,
        style: UIAlertAction.Style,
        handler: ((UIAlertAction) -> Void)?
    ) {
        let action: UIAlertAction = UIAlertAction.init(title: title, style: style, handler: handler)
        self.addAction(action)
    }
}
