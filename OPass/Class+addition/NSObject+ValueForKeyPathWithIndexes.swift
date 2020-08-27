//
//  NSObject+ValueForKeyPathWithIndexes.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  2018 OPass.
//

import Foundation

extension NSObject {
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
        var currentObj: NSObject? = self
        for part in parts {
            let range1 = part.range(of: "[")
            if (range1 == nil) {
                if let cObj = currentObj {
                    if let value = cObj.value(forKey: part) as? NSObject {
                        currentObj = cObj.responds(to: Selector(part)) ? value : nil
                    }
                }
                if (currentObj == nil) {
                    return currentObj
                }
            } else {
                if let range1 = range1, let cObj = currentObj {
                    let range1End = String.Index(utf16Offset: range1.lowerBound.utf16Offset(in: part), in: part)
                    let range1Start = String.Index(utf16Offset: 0, in: part)
                    let arrayKey = String(part[range1Start..<range1End])
                    let start = String.Index(utf16Offset: range1.lowerBound.utf16Offset(in: part) + 1, in: part)
                    let end = String.Index(utf16Offset: part.count - 1, in: part)
                    let index = Int(String(part[start..<end])) ?? 0
                    if let value = cObj.value(forKey: arrayKey) as? NSArray {
                        if let obj = value.object(at: index) as? NSObject {
                            currentObj = cObj.responds(to: Selector(arrayKey)) ? obj : nil
                        }
                    }
                }
                if (currentObj == nil) {
                    return currentObj
                }
            }
        }
        return currentObj
    }
}

extension Array {
    func mapToDict<T>(by block: (Element) -> T ) -> [T: Element] where T: Hashable {
        var map = [T: Element]()
        self.forEach{ map[block($0)] = $0 }
        return map
    }
}
