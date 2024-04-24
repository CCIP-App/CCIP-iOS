//
//  DateInRegion+Transform.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/30.
//  2024 OPass.
//

import Foundation
import SwiftDate

struct StringToDate: TransformFunction {
    static func transform(_ string: String) throws -> DateInRegion {
        guard let date = string.toISODate(region: .current) else {
            throw DecodingError.typeMismatch(
                DateInRegion.self, .init(
                    codingPath: [],
                    debugDescription: "String: \"\(string)\" can't be decoded to DateInRegion"
                )
            )
        }
        return date
    }
}

struct IntToDate: TransformFunction {
    static func transform(_ time: Int) -> DateInRegion {
        return DateInRegion(seconds: .init(time), region: .current)
    }
}
