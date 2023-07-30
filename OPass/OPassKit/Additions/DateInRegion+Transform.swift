//
//  DateInRegion+Transform.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/30.
//  2023 OPass.
//

import SwiftDate

extension DateInRegion: TransformFunction {
    static func transform(_ date: String) -> DateInRegion {
        return date.toISODate()!
    }
}
