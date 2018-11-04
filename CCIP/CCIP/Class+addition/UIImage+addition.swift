//
//  UIView+addition.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation
import UIKit

@objc extension UIImage {
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

@objc extension UIView {
    func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0);
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true);
        let snapshotImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return snapshotImage;
    }
}

@objc extension CALayer {
    func toImage() -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size);
        self.render(in: UIGraphicsGetCurrentContext()!);
        let snapshotImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return snapshotImage;
    }
}
