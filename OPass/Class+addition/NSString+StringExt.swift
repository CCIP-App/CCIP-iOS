//
//  NSString+StringExt.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/2/9.
//  2019 OPass.
//

import Foundation

extension String {
    func appendingPathComponent(_ string: String) -> String {
        return URL(fileURLWithPath: self).appendingPathComponent(string).path
    }
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = String.Index(utf16Offset: bounds.lowerBound, in: self)
        let end = String.Index(utf16Offset: bounds.upperBound, in: self)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = String.Index(utf16Offset: bounds.lowerBound, in: self)
        let end = String.Index(utf16Offset: bounds.upperBound, in: self)
        return String(self[start..<end])
    }

    subscript (bounds: NSRange) -> String {
        let start = bounds.location
        let end = bounds.location + bounds.length
        return String(self[start..<end])
    }
}

extension Substring {
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}

func + (left: String, right: NSAttributedString) -> NSAttributedString {
    let result = NSMutableAttributedString()
    result.append(NSAttributedString.init(string: left))
    result.append(right)
    return result
}

func + (left: NSAttributedString, right: String) -> NSAttributedString {
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(NSAttributedString.init(string: right))
    return result
}

func + (left: String, right: NSMutableAttributedString) -> NSMutableAttributedString {
    let result = NSMutableAttributedString()
    result.append(NSAttributedString.init(string: left))
    result.append(right)
    return result
}

func + (left: NSMutableAttributedString, right: String) -> NSMutableAttributedString {
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(NSAttributedString.init(string: right))
    return result
}

func += (left: inout NSMutableAttributedString, right: String) -> NSMutableAttributedString {
    return NSMutableAttributedString.init(attributedString: NSAttributedString.init(attributedString: left) + right)
}

func += (left: inout NSAttributedString, right: String) -> NSAttributedString {
    return left + right
}

func += (left: inout NSAttributedString, right: NSAttributedString) -> NSAttributedString {
    return left + right
}

func += (left: inout NSAttributedString, right: NSAttributedString?) -> NSAttributedString {
    guard let rhs = right else { return left }
    return left += rhs
}
