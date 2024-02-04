//
//  Tag.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/29.
//  2024 OPass.
//

import OrderedCollections

struct Tag: Hashable, Codable, Identifiable, Localizable {
    var id: String
    var zh: TagDetail
    var en: TagDetail
}

struct TagDetail: Hashable, Codable {
    var name: String
    var description: String?
}

extension Tag: TransformFunction {
    static func transform(_ tags: [Tag]) -> OrderedDictionary<String, Tag> {
        return OrderedDictionary(uniqueKeysWithValues: tags.map { ($0.id, $0) })
    }
}
