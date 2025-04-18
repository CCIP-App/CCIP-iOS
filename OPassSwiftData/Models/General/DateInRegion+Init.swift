//
//  DateInRegion+Init.swift
//  OPassSwiftData
//
//  Created by Brian Chang on 2025/4/17.
//  2025 OPass.
//

import SwiftDate

extension DateInRegion {
    init(_ string: String) throws {
        guard let date = string.toISODate(region: .current) else {
            throw DecodingError.typeMismatch(
                DateInRegion.self,
                .init(
                    codingPath: [],
                    debugDescription: "String: \"\(string)\" can't be decoded to DateInRegion"
                )
            )
        }
        self = date
    }
}
