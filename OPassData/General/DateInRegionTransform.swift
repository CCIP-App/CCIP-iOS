//
//  DateInRegion+Transform.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/30.
//  2025 OPass.
//

import Foundation
import SwiftDate

struct StringToDate: TransformFunction {
    static func transform(_ string: String) -> DateInRegion {
        return string.toISODate(region: .current)!
    }
}

struct IntToDate: TransformFunction {
    static func transform(_ time: Int) -> DateInRegion {
        return DateInRegion(seconds: .init(time), region: .current)
    }
}
