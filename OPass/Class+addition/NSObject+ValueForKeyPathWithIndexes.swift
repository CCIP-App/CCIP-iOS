//
//  NSObject+ValueForKeyPathWithIndexes.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation

@objc extension NSObject {
    func valueForKeyPathWithIndexes(_ fullPath: String) -> Any? {
        return self.valueForKeyPaths(fullPath)
    }
    func valueForKeyPaths(_ fullPath: String) -> Any? {
        let testRange = fullPath.range(of: "[")
        if (testRange == nil) {
            if self.responds(to: Selector(fullPath)) {
                return self.value(forKeyPath: fullPath) as Any
            } else {
                let mirror = Mirror(reflecting: self)
                for child in mirror.children {
                    if child.label == fullPath {
                        NSLog("\(String(describing: child.label)): \(child.value)")
                        return child.value
                    }
                }
                return nil
            }
        }
        let parts = fullPath.components(separatedBy: ".")
        var currentObj : NSObject? = self
        for part in parts {
            let range1 = part.range(of: "[")
            if (range1 == nil) {
                currentObj = currentObj!.responds(to: Selector(part)) ? (currentObj!.value(forKey: part) as! NSObject) : nil
                if (currentObj == nil) {
                    return currentObj
                }
            } else {
                let range1End = String.Index(utf16Offset: range1!.lowerBound.utf16Offset(in: part), in: part)
                let arrayKey = String(part[String.Index.init(utf16Offset: 0, in: "")..<range1End])
                let start = String.Index(utf16Offset: range1!.lowerBound.utf16Offset(in: part) + 1, in: part)
                let end = String.Index(utf16Offset: part.count - 1, in: part)
                let index = Int(String(part[start..<end]))
                currentObj = currentObj!.responds(to: Selector(arrayKey)) ? ((currentObj!.value(forKey: arrayKey) as! NSArray).object(at: index!) as! NSObject) : nil
                if (currentObj == nil) {
                    return currentObj
                }
            }
        }
        return currentObj
    }
}
