//
//  UIImpactFeedbackType.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/3/17.
//  2019 OPass.
//

import Foundation
import UIKit

@objc enum UIImpactFeedbackType: Int {
    case impactFeedbackHeavy = 0x00000001
    case impactFeedbackLight = 0x00000010
    case impactFeedbackMedium = 0x00000100
    case notificationFeedbackSuccess = 0x00001000
    case notificationFeedbackWarning = 0x00010000
    case notificationFeedbackError = 0x00100000
    case selectionFeedback = 0x01000000
}

class UIImpactFeedback: NSObject { }

@objc extension UIImpactFeedback {
    @objc static func triggerFeedback(_ feedbackType: UIImpactFeedbackType) {
        var generator: UIFeedbackGenerator
        if (feedbackType.rawValue < 0x00001000) {
            // ImpactFeedback
            var impactFeedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle
            switch (feedbackType) {
            case .impactFeedbackHeavy:
                impactFeedbackStyle = .heavy
                break
            case .impactFeedbackMedium:
                impactFeedbackStyle = .medium
                break
            case .impactFeedbackLight:
                impactFeedbackStyle = .light
                break
            default:
                return
            }
            generator = UIImpactFeedbackGenerator.init(style: impactFeedbackStyle)
            generator.prepare()
            (generator as? UIImpactFeedbackGenerator)?.impactOccurred()
        } else if (feedbackType.rawValue > 0x00000100 && feedbackType.rawValue < 0x01000000) {
            // NotificationFeedback
            var notificationFeedbackType: UINotificationFeedbackGenerator.FeedbackType
            switch (feedbackType) {
            case .notificationFeedbackSuccess:
                notificationFeedbackType = .success
                break
            case .notificationFeedbackWarning:
                notificationFeedbackType = .warning
                break
            case .notificationFeedbackError:
                notificationFeedbackType = .error
                break
            default:
                return
            }
            generator = UINotificationFeedbackGenerator.init()
            generator.prepare()
            (generator as? UINotificationFeedbackGenerator)?.notificationOccurred(notificationFeedbackType)
        } else {
            // SelectionFeedback
            generator = UISelectionFeedbackGenerator.init()
            generator.prepare()
            (generator as? UISelectionFeedbackGenerator)?.selectionChanged()
        }
    }
}
