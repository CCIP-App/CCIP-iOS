//
//  EventConfig.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//  2025 OPass.
//

import SwiftDate

struct EventConfig: Hashable, Codable, Identifiable {
    var id: String
    var title: LocalizedString
    var logoUrl: String
    var website: String?
    var date: TimeRange
    var publish: TimeRange
    var features: [Feature]

    private enum CodingKeys: String, CodingKey {
        case id = "event_id"
        case title = "display_name"
        case logoUrl = "logo_url"
        case website = "event_website"
        case date = "event_date"
        case publish
        case features
    }
}

struct TimeRange: Hashable, Codable {
    @Transform<StringToDate> var start: DateInRegion
    @Transform<StringToDate> var end: DateInRegion
}

extension EventConfig {
    @inline(__always)
    func feature(_ type: FeatureType) -> Feature? {
        return features.first { $0.feature == type }
    }
}
