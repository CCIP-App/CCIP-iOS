//
//  Speaker.swift
//  OPass
//
//  Created by Brian Chang on 2025/4/17.
//

import Foundation
import SwiftData

@Model
final class Speaker: Decodable, Localizable {
    @Attribute(.unique) var id: String
    var avatar: String
    var zh: NameBio
    var en: NameBio
    
    @Relationship(inverse: \Schedule.speakers) var schedule: Schedule?
    
    struct NameBio: Hashable, Codable {
        var name: String
        var bio: String
    }
    
    // MARK: - Decoding
    private enum CodingKeys: String, CodingKey {
        case id, avatar, zh, en
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.avatar = try container.decode(String.self, forKey: .avatar)
        self.zh = try container.decode(NameBio.self, forKey: .zh)
        self.en = try container.decode(NameBio.self, forKey: .en)
    }
}
