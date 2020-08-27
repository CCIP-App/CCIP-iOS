//
//  UIColor+addition.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  2018 OPass.
//

import Foundation
import UIKit

public enum UIColorByteMark: Int {
    case Alpha = 0
    case Red = 1
    case Green = 2
    case Blue = 3
}

extension UIColor {
    @objc static func colorFrom(_ from: UIColor, to: UIColor, at: Double) -> UIColor {
        let f: CIColor = CIColor.init(cgColor: from.cgColor)
        let t: CIColor = CIColor.init(cgColor: to.cgColor)
        let resultRed = f.red + CGFloat(at) * (t.red - f.red)
        let resultGreen = f.green + CGFloat(at) * (t.green - f.green)
        let resultBlue = f.blue + CGFloat(at) * (t.blue - f.blue)
        let resultAlpha = f.alpha + CGFloat(at) * (t.alpha - f.alpha)
        return UIColor.init(red: resultRed, green: resultGreen, blue: resultBlue, alpha: resultAlpha)
    }

    static func getColorByteFromHtmlColor(_ htmlColorString: String, forByte: UIColorByteMark) -> CGFloat {
        assert(htmlColorString.hasPrefix("#"), "Must prefix begin with '#'")
        let length = htmlColorString.count
        let hasAlpha = length == 9 || length == 5
        let isSingleByte = hasAlpha ? length == 5 : length == 4

        let byteLength = isSingleByte ? 1 : 2
        let startOffset = 1 + forByte.rawValue * byteLength - (hasAlpha ? 0 : forByte != .Alpha ? byteLength : 0)
        let endOffset = startOffset + byteLength
        let startRange = String.Index(utf16Offset: startOffset, in: htmlColorString)
        let endRange = String.Index(utf16Offset: endOffset, in: htmlColorString)
        let byteString = String(htmlColorString[startRange..<endRange])
        if (!hasAlpha && forByte == .Alpha) {
            return CGFloat(self.hexToIntColor(String(repeating: "f", count: byteLength), isSingleByteOnly: isSingleByte))
        }
        return CGFloat(self.hexToIntColor(byteString, isSingleByteOnly: isSingleByte))
    }

    @objc static func colorFromHtmlColor(_ htmlColorString: String) -> UIColor {
        let r = self.getColorByteFromHtmlColor(htmlColorString, forByte: .Red)
        let g = self.getColorByteFromHtmlColor(htmlColorString, forByte: .Green)
        let b = self.getColorByteFromHtmlColor(htmlColorString, forByte: .Blue)
        let a = self.getColorByteFromHtmlColor(htmlColorString, forByte: .Alpha)
        return UIColor.init(red: r, green: g, blue: b, alpha: a)
    }

    static func hexToIntColor(_ hex: String, isSingleByteOnly: Bool) -> Float {
        var h: String = hex
        if (isSingleByteOnly) {
            h = h.appending(hex)
        }
        var result: CUnsignedLongLong = 0
        let scanner: Scanner = Scanner(string: h)
        scanner.scanHexInt64(&result)
        return Float(result) / 255.0
    }
}
