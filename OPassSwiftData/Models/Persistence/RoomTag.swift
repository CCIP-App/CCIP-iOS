//
//  RoomTag.swift
//  OPassSwiftData
//
//  Created by Brian Chang on 2025/4/18.
//

import SwiftData

@Model
final class Room: Decodable, Localizable {
    @Attribute(.unique) var id: String
    var zh: NameDescription
    var en: NameDescription
    
    @Relationship(inverse: \Schedule.tags) var schedule: Schedule?
    
    // MARK: - Decoding
    private enum CodingKeys: String, CodingKey {
        case id, zh, en
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.zh = try container.decode(NameDescription.self, forKey: .zh)
        self.en = try container.decode(NameDescription.self, forKey: .en)
    }
}

@Model
final class Tag: Decodable, Localizable {
    @Attribute(.unique) var id: String
    var zh: NameDescription
    var en: NameDescription
    
    @Relationship(inverse: \Schedule.tags) var schedule: Schedule?
    
    // MARK: - Decoding
    private enum CodingKeys: String, CodingKey {
        case id, zh, en
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.zh = try container.decode(NameDescription.self, forKey: .zh)
        self.en = try container.decode(NameDescription.self, forKey: .en)
    }
}
