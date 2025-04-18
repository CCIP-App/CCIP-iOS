//
//  TimeRange.swift
//  OPassSwiftData
//
//  Created by Brian Chang on 2025/4/18.
//  2025 OPass.
//

import SwiftDate

struct TimeRange: Hashable, Codable {
    var start: DateInRegion
    var end: DateInRegion
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let string = try? container.decode(String.self, forKey: .start) {
            self.start = try .init(string)
        } else {
            self.start = try container.decode(DateInRegion.self, forKey: .start)
        }
        if let string = try? container.decode(String.self, forKey: .end) {
            self.end = try .init(string)
        } else {
            self.end = try container.decode(DateInRegion.self, forKey: .end)
        }
    }
}
