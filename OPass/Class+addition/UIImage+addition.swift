//
//  UIImage+addition.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func imageWithColor(_ color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        let context : CGContext = UIGraphicsGetCurrentContext()!;
        context.translateBy(x: 0, y: self.size.height);
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(CGBlendMode.normal);
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height);
        context.clip(to: rect, mask: self.cgImage!);
        color1.setFill();
        context.fill(rect);
        let newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return newImage;
    }
}

extension UIView {
    func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0);
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true);
        let snapshotImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return snapshotImage;
    }
}

extension CALayer {
    func toImage() -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size);
        self.render(in: UIGraphicsGetCurrentContext()!);
        let snapshotImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return snapshotImage;
    }
}

extension UIImage {
    static func imageWithSize(size : CGSize, color : UIColor = UIColor.clear) -> UIImage? {
        var image:UIImage? = nil
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.addRect(CGRect(origin: CGPoint.zero, size: size));
            context.drawPath(using: .fill)
            image = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext()
        return image
    }
}
