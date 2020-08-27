//
//  UIView+addition.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  2018 OPass.
//

import Foundation
import UIKit

extension UIView {
    var ViewTopStart: CGFloat {
        return self.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
    var topGuideHeight: CGFloat {
        if let vc = self.next as? UIViewController {
            return vc.topGuideHeight
        }
        return 0
    }

    var bottomGuideHeight: CGFloat {
        if let vc = self.next as? UIViewController {
            return vc.bottomGuideHeight
        }
        return 0
    }
    // DashedLine and linear diagonal gradient
    static let DASHLINE_VIEW_ID: String = "DashedLine"
    func addDashedLine(_ color: UIColor) {
        for layer in self.layer.sublayers ?? [] {
            if (layer.name == UIView.DASHLINE_VIEW_ID) {
                layer.removeFromSuperlayer()
            }
        }
        self.backgroundColor = UIColor.clear

        let shapeLayer: CAShapeLayer = CAShapeLayer.init()
        shapeLayer.name = UIView.DASHLINE_VIEW_ID
        shapeLayer.bounds = self.bounds
        shapeLayer.position = CGPoint.init(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = self.frame.size.height
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [ 5, 5 ]

        let transform: CGAffineTransform = self.transform
        let path: CGMutablePath = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0), transform: transform)
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0), transform: transform)
        shapeLayer.path = path

        self.layer.addSublayer(shapeLayer)
    }

    @objc func setGradientColor(from: UIColor?, to: UIColor?, startPoint: CGPoint = CGPoint.zero, toPoint: CGPoint = CGPoint.zero) {
        let name: String = "GradientBackground"
        // Set view background linear diagonal gradient
        //   Create the gradient
        var theViewGradient: CAGradientLayer? = nil
        for layer in self.layer.sublayers ?? [] {
            if (layer.name == name) {
                theViewGradient = layer as? CAGradientLayer
                layer.removeFromSuperlayer()
                break
            }
        }
        if (theViewGradient == nil) {
            theViewGradient = CAGradientLayer.init()
            theViewGradient?.name = name
            theViewGradient?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        }
        if (from != nil && to != nil && CGPoint.zero != startPoint && CGPoint.zero != toPoint) {
            if let from = from, let to = to {
                theViewGradient?.colors = [ from.cgColor, to.cgColor ]
            }
            theViewGradient?.startPoint = startPoint
            theViewGradient?.endPoint = toPoint
        } else {
            theViewGradient?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        }
        if let theViewGradient = theViewGradient {
            self.layer.insertSublayer(theViewGradient, at: 0)
        }
    }

    @objc func sizeGradientToFit() {
        self.setGradientColor(from: nil, to: nil, startPoint: CGPoint.zero, toPoint: CGPoint.zero)
    }
}
