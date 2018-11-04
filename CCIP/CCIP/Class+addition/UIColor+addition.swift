//
//  UIColor+addition.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation
import UIKit

@objc extension UIColor {
    static func colorFrom(_ from: UIColor, to: UIColor, at:Double) -> UIColor {
        let f : CIColor = CIColor.init(cgColor: from.cgColor);
        let t : CIColor = CIColor.init(cgColor: to.cgColor);
        let resultRed = f.red + CGFloat(at) * (t.red - f.red);
        let resultGreen = f.green + CGFloat(at) * (t.green - f.green);
        let resultBlue = f.blue + CGFloat(at) * (t.blue - f.blue);
        let resultAlpha = f.alpha + CGFloat(at) * (t.alpha - f.alpha);
        return UIColor.init(red: resultRed,
                            green: resultGreen,
                            blue: resultBlue,
                            alpha: resultAlpha
        );
    }

    static func colorFromHtmlColor(_ htmlColorString: String) -> UIColor {
        assert(htmlColorString.hasPrefix("#"), "Must prefix begin with '#'");
        let length = htmlColorString.count;
        let hasAlpha = length == 9 || length == 5;
        let singleByteColor = hasAlpha ? length == 5 : length == 4;
        let r = String(htmlColorString[String.Index(encodedOffset: 1 + ((singleByteColor ? 1 : 2) * (hasAlpha ? 1 : 0)))..<String.Index(encodedOffset: singleByteColor ? 1 : 2)]);
        let g = String(htmlColorString[String.Index(encodedOffset: 1 + ((singleByteColor ? 1 : 2) * (hasAlpha ? 1 : 0)) + (singleByteColor ? 1 : 2))..<String.Index(encodedOffset: singleByteColor ? 1 : 2)]);
        let b = String(htmlColorString[String.Index(encodedOffset: 1 + ((singleByteColor ? 1 : 2) * (hasAlpha ? 1 : 0)) + (singleByteColor ? 2 : 4))..<String.Index(encodedOffset: singleByteColor ? 1 : 2)]);
        let a = hasAlpha ? String(htmlColorString[String.Index(encodedOffset: 1)..<String.Index(encodedOffset: singleByteColor ? 1 : 2)]) : (singleByteColor ? "f" : "ff");
        return UIColor.init(red: CGFloat(self.HexToIntColor(r, isSingleByteOnly: singleByteColor)),
                            green: CGFloat(self.HexToIntColor(g, isSingleByteOnly: singleByteColor)),
                            blue: CGFloat(self.HexToIntColor(b, isSingleByteOnly: singleByteColor)),
                            alpha: CGFloat(self.HexToIntColor(a, isSingleByteOnly: singleByteColor))
        );
    }

    static func HexToIntColor(_ hex : String, isSingleByteOnly:Bool) -> Float {
        var h : String = hex;
        if (isSingleByteOnly) {
            h = h.appending(hex);
        }
        var result : CUnsignedInt = 0;
        let scanner : Scanner = Scanner(string: h);
        scanner.scanHexInt32(&result);
        return Float(result) / 255.0;
    }
}
