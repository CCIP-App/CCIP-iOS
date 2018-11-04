//
//  UIView+addition.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation
import UIKit

@objc extension UIView { // DashedLine and linear diagonal gradient
    func addDashedLine(_ color : UIColor) {
        for layer in self.layer.sublayers! {
            if (layer.name == Constants.DashlineViewId) {
                layer.removeFromSuperlayer();
            }
        }
        self.backgroundColor = UIColor.clear;

        let shapeLayer : CAShapeLayer = CAShapeLayer.init();
        shapeLayer.name = Constants.DashlineViewId;
        shapeLayer.bounds = self.bounds;
        shapeLayer.position = CGPoint.init(x: self.frame.size.width / 2, y: self.frame.size.height / 2);
        shapeLayer.fillColor = UIColor.clear.cgColor;
        shapeLayer.strokeColor = color.cgColor;
        shapeLayer.lineWidth = self.frame.size.height;
        shapeLayer.lineJoin = .round;
        shapeLayer.lineDashPattern = [ 5, 5 ];

        let transform : CGAffineTransform = self.transform;
        let path : CGMutablePathRef = CGPathCreateMutable();
        CGPathMoveToPoint(path, &transform, 0, 0);
        CGPathAddLineToPoint(path, &transform, self.frame.size.width, 0);
        shapeLayer.path = path;

        self.layer.addSublayer(shapeLayer);
    }

    func setGradientColor(_ from : UIColor, to: UIColor, startPoint:CGPoint, toPoint:CGPoint) {
        var name : String = "GradientBackground";
        // Set view background linear diagonal gradient
        //   Create the gradient
        let theViewGradient : CAGradientLayer? = nil;
        for layer in self.layer.sublayers! {
            if (layer.name == name) {
                theViewGradient = layer as CAGradientLayer;
                layer.removeFromSuperlayer();
                break;
            }
        }
        if (theViewGradient == nil) {
            theViewGradient = CAGradientLayer.layer;
            theViewGradient.name = name;
            theViewGradient.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height);
        }
        if (from != nil && to != nil && CGPointZero != startPoint && CGPointZero != toPoint) {
            theViewGradient.colors = [ from.CGColor, to.CGColor ];
            theViewGradient.startPoint = startPoint;
            theViewGradient.endPoint = toPoint;
        } else {
            theViewGradient.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height);
        }
        self.layer.insertSublayer(theViewGradient, at: 0);
    }

    func sizeGradientToFit() {
        self.setGradientColor(nil, to: nil, startPoint: CGPoint.zero, toPoint: CGPoint.zero);
    }
}
