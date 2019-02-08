//
//  NSObject+DeepCopy.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation

// Deep -copy and -mutableCopy methods for NSArray and NSDictionary

@objc extension NSArray {
    func deepCopy() -> NSArray {
        let count : UInt = UInt(self.count);
        var cArray = Array<Any>(repeating: 0, count: Int(count));

        for i in 0...count {
            let obj = self.object(at: Int(i)) as! NSObject;
            if (obj.responds(to: #selector(deepCopy))) {
                cArray[Int(i)] = obj.perform(#selector(deepCopy))!;
            } else {
                cArray[Int(i)] = obj.copy();
            }
        }
        let ret : NSArray = NSArray(array: cArray);
        return ret;
    }

    func mutableDeepCopy() -> NSMutableArray {
        let count : UInt = UInt(self.count);
        var cArray = Array<Any>(repeating: 0, count: Int(count));

        for i in 0...count {
            let obj = self.object(at: Int(i)) as! NSObject;
            if (obj.responds(to: #selector(mutableDeepCopy))) {
                // Try to do a deep mutable copy, if this object supports it
                cArray[Int(i)] = obj.perform(#selector(mutableDeepCopy))!;
            } else if (obj.responds(to: NSSelectorFromString("mutableCopyWithZone:"))) {
                // Then try a shallow mutable copy, if the object supports that
                cArray[Int(i)] = obj.perform(#selector(mutableCopy))!;
            } else if (obj.responds(to: #selector(deepCopy))) {
                // Next try to do a deep copy
                cArray[Int(i)] = obj.perform(#selector(deepCopy))!;
            } else {
                // If all else fails, fall back to an ordinary copy
                cArray[Int(i)] = obj.copy();
            }
        }
        let ret : NSMutableArray = NSMutableArray(array: cArray);
        return ret;
    }
}

@objc extension NSDictionary {
    func deepCopy() -> NSDictionary {
        let count : UInt = UInt(self.count);
        let cDict = NSMutableDictionary(capacity: Int(count))

        for obj in self {
            var cKey : Any;
            var cObj : Any;
            if ((obj.value as! NSObject).responds(to: #selector(deepCopy))) {
                cObj = (obj.value as! NSObject).perform(#selector(deepCopy))!;
            } else {
                cObj = (obj.value as! NSObject).copy();
            }
            if ((obj.key as! NSObject).responds(to: #selector(deepCopy))) {
                cKey = (obj.key as! NSObject).perform(#selector(deepCopy))!;
            } else {
                cKey = (obj.key as! NSObject).copy();
            }
            cDict[cKey] = cObj;
        }

        let ret = NSDictionary(dictionary: cDict);
        return ret;
    }

    func mutableDeepCopy() -> NSMutableDictionary {
        let count : UInt = UInt(self.count);
        let cDict = NSMutableDictionary(capacity: Int(count))

        for obj in self {
            var cKey : Any;
            var cObj : Any;
            if ((obj.value as! NSObject).responds(to: #selector(mutableDeepCopy))) {
                // Try to do a deep mutable copy, if this object supports it
                cObj = (obj.value as! NSObject).perform(#selector(mutableDeepCopy))!;
            } else if ((obj.value as! NSObject).responds(to: #selector(mutableCopy))) {
                // Then try a shallow mutable copy, if the object supports that
                cObj = (obj.value as! NSObject).perform(#selector(mutableCopy))!;
            } else if ((obj.value as! NSObject).responds(to: #selector(deepCopy))) {
                // Next try to do a deep copy
                cObj = (obj.value as! NSObject).perform(#selector(deepCopy))!;
            } else {
                // If all else fails, fall back to an ordinary copy
                cObj = (obj.value as! NSObject).copy();
            }
            // I don't think mutable keys make much sense, so just do an ordinary copy
            if ((obj.key as! NSObject).responds(to: #selector(deepCopy))) {
                cKey = (obj.key as! NSObject).perform(#selector(deepCopy))!;
            } else {
                cKey = (obj.key as! NSObject).copy();
            }
            cDict[cKey] = cObj;
        }

        let ret = NSMutableDictionary(dictionary: cDict);
        return ret;
    }
}
