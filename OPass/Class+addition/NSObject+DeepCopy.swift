//
//  NSObject+DeepCopy.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/4.
//  2018 OPass.
//

import Foundation

// Deep -copy and -mutableCopy methods for NSArray and NSDictionary

@objc extension NSArray {
    @objc func deepCopy() -> NSArray {
        let count: UInt = UInt(self.count)
        var cArray = Array<Any>(repeating: 0, count: Int(count))

        for i in 0...count {
            if let obj = self.object(at: Int(i)) as? NSObject {
                if (obj.responds(to: #selector(deepCopy))) {
                    if let deep = obj.perform(#selector(deepCopy)) {
                        cArray[Int(i)] = deep
                    }
                } else {
                    cArray[Int(i)] = obj.copy()
                }
            }
        }
        let ret: NSArray = NSArray(array: cArray)
        return ret
    }

    @objc func mutableDeepCopy() -> NSMutableArray {
        let count: UInt = UInt(self.count)
        var cArray = Array<Any>(repeating: 0, count: Int(count))

        for i in 0...count {
            if let obj = self.object(at: Int(i)) as? NSObject {
                if (obj.responds(to: #selector(mutableDeepCopy))) {
                    // Try to do a deep mutable copy, if this object supports it
                    if let mutableDeep = obj.perform(#selector(mutableDeepCopy)) {
                        cArray[Int(i)] = mutableDeep
                    }
                } else if (obj.responds(to: NSSelectorFromString("mutableCopyWithZone:"))) {
                    // Then try a shallow mutable copy, if the object supports that
                    if let mutable = obj.perform(#selector(mutableCopy)) {
                        cArray[Int(i)] = mutable
                    }
                } else if (obj.responds(to: #selector(deepCopy))) {
                    // Next try to do a deep copy
                    if let deep = obj.perform(#selector(deepCopy)) {
                        cArray[Int(i)] = deep
                    }
                } else {
                    // If all else fails, fall back to an ordinary copy
                    cArray[Int(i)] = obj.copy()
                }
            }
        }
        let ret: NSMutableArray = NSMutableArray(array: cArray)
        return ret
    }
}

@objc extension NSDictionary {
    @nonobjc func ordinaryCopy(_ obj: Element, _ cKey: inout Any) {
        if let key = obj.key as? NSObject {
            if (key.responds(to: #selector(deepCopy))) {
                if let deep = key.perform(#selector(deepCopy)) {
                    cKey = deep
                }
            } else {
                cKey = key.copy()
            }
        }
    }

    @objc func deepCopy() -> NSDictionary {
        let count: UInt = UInt(self.count)
        let cDict = NSMutableDictionary(capacity: Int(count))

        for obj in self {
            var cKey: Any = {}
            var cObj: Any = {}
            if let value = obj.value as? NSObject {
                if (value.responds(to: #selector(deepCopy))) {
                    if let deep = value.perform(#selector(deepCopy)) {
                        cObj = deep
                    }
                } else {
                    cObj = value.copy()
                }
            }
            self.ordinaryCopy(obj, &cKey)
            cDict[cKey] = cObj
        }

        let ret = NSDictionary(dictionary: cDict)
        return ret
    }

    @objc func mutableDeepCopy() -> NSMutableDictionary {
        let count: UInt = UInt(self.count)
        let cDict = NSMutableDictionary(capacity: Int(count))

        for obj in self {
            var cKey: Any = {}
            var cObj: Any = {}
            if let value = obj.value as? NSObject {
                if (value.responds(to: #selector(mutableDeepCopy))) {
                    // Try to do a deep mutable copy, if this object supports it
                    if let mutableDeep = value.perform(#selector(mutableDeepCopy)) {
                        cObj = mutableDeep
                    }
                } else if (value.responds(to: #selector(mutableCopy))) {
                    // Then try a shallow mutable copy, if the object supports that
                    if let mutable = value.perform(#selector(mutableCopy)) {
                        cObj = mutable
                    }
                } else if (value.responds(to: #selector(deepCopy))) {
                    // Next try to do a deep copy
                    if let deep = value.perform(#selector(deepCopy)) {
                        cObj = deep
                    }
                } else {
                    // If all else fails, fall back to an ordinary copy
                    cObj = value.copy()
                }
            }
            // I don't think mutable keys make much sense, so just do an ordinary copy
            self.ordinaryCopy(obj, &cKey)
            cDict[cKey] = cObj
        }

        let ret = NSMutableDictionary(dictionary: cDict)
        return ret
    }
}
