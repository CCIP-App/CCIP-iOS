//
//  Announcement.swift
//  OPass
//
//  Created by Brian Chang on 2025/4/17.
//  2025 OPass.
//

import Foundation
import SwiftData
import SwiftDate

@Model
final class Announcement: Decodable, Localizable {
    var datetime: DateInRegion
    var zh: String
    var en: String
    var uri: String

    @Relationship(inverse: \Event.announcements) var event: Event?
    
    // MARK: - Decoding
    private enum CodingKeys: String, CodingKey {
        case datetime
        case zh = "msg_zh"
        case en = "msg_en"
        case uri
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let seconds = try container.decode(Int.self, forKey: .datetime)
        self.datetime = .init(seconds: .init(seconds), region: .current)
        self.zh = try container.decode(String.self, forKey: .zh)
        self.en = try container.decode(String.self, forKey: .en)
        self.uri = try container.decode(String.self, forKey: .uri)
    }
}

extension Announcement {
    var url: URL? { URL(string: uri) }
}
