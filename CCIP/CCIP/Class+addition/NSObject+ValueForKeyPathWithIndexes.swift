//
//  NSObject+ValueForKeyPathWithIndexes.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation

@objc extension NSObject {
    func valueForKeyPathWithIndexes(_ fullPath: String) -> Any {
        let testRange = fullPath.range(of: "[");
        if (testRange == nil) {
            return self.value(forKeyPath: fullPath) as Any;
        }
        let parts = fullPath.components(separatedBy: ".");
        var currentObj = self;
        for part in parts {
            let range1 = part.range(of: "[");
            if (range1 == nil) {
                currentObj = currentObj.value(forKey: part) as! NSObject;
            } else {
                let range1End = String.Index(encodedOffset: range1!.lowerBound.encodedOffset);
                let arrayKey = String(part[String.Index(encodedOffset: 0)..<range1End]);
                let start = String.Index(encodedOffset: range1!.lowerBound.encodedOffset + 1)
                let end = String.Index(encodedOffset: part.count - 1)
                let index = Int(String(part[start..<end]));
                currentObj = (currentObj.value(forKey: arrayKey) as! NSArray).object(at: index!) as! NSObject;
            }
        }
        return currentObj;
    }
}
