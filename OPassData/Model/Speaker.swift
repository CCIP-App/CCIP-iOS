//
//  Speaker.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/29.
//  2024 OPass.
//

import OrderedCollections

struct Speaker: Hashable, Codable, Identifiable, Localizable {
    internal var id: String?
    var avatar: String
    var zh: SpeakerDetail
    var en: SpeakerDetail
}

struct SpeakerDetail: Hashable, Codable {
    var name: String
    var bio: String
}

extension Speaker: TransformFunction {
    static func transform(_ speakers: [Speaker]) -> OrderedDictionary<String, Speaker> {
        return OrderedDictionary(uniqueKeysWithValues: speakers.compactMap {
            return $0.id == nil ? nil : ($0.id!, $0)
        })
    }
}
