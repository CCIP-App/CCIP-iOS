//
//  Session.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/29.
//  2023 OPass.
//

import OrderedCollections
import SwiftDate

struct Session: Hashable, Codable, Identifiable, Localizable {
    var id: String
    var type: String?
    var room: String
    var broadcast: [String]?
    @Transform<StringToDate> var start: DateInRegion
    @Transform<StringToDate> var end: DateInRegion
    var co_write: String?
    var qa: String?
    var slide: String?
    var live: String?
    var record: String?
    var language: String?
    var uri: String?
    var zh: SessionDetail
    var en: SessionDetail
    var speakers: [String]
    var tags: [String]
}

struct SessionDetail: Hashable, Codable {
    var title: String
    var description: String
}

extension Session: TransformFunction {
    static func transform(_ sessions: [Session]) -> [OrderedDictionary<DateInRegion, [Session]>] {
        return Dictionary(grouping: sessions) { $0.start.dateTruncated(from: .hour)! }
            .sorted { $0.key < $1.key }
            .map { $0.value.sorted { $0.start < $1.start } }
            .map { OrderedDictionary(grouping: $0, by: \.start) }
            .map { $0.mapValues { $0.sorted { $0.end < $1.end } } }
    }
}
