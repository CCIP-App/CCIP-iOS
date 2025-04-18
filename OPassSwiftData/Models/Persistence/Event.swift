//
//  Event.swift
//  OPass
//
//  Created by Brian Chang on 2025/4/17.
//  2025 OPass.
//

import Foundation
import SwiftData

@Model
final class Event: Decodable {
    @Attribute(.unique) var id: String
    var title: LocalizedString
    var logoURL: String
    var logoData: Data?
    var website: String?
    var date: TimeRange
    var publish: TimeRange
    
    @Relationship(deleteRule: .cascade) var features: [Feature] = []
    @Relationship(deleteRule: .cascade) var schedule: Schedule?
    @Relationship(deleteRule: .cascade) var attendee: Attendee?
    @Relationship(deleteRule: .cascade) var announcements: [Announcement]? = []
    
    var userID: String?
    var userRole: String?
    var likedSessions: [String] = []
    
    // MARK: - Decoding
    private enum CodingKeys: String, CodingKey {
        case id = "event_id"
        case title = "display_name"
        case logoURL = "logo_url"
        case website = "event_website"
        case date = "event_date"
        case publish
        case features
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(LocalizedString.self, forKey: .title)
        self.logoURL = try container.decode(String.self, forKey: .logoURL)
        self.website = try container.decodeIfPresent(String.self, forKey: .website)
        self.date = try container.decode(TimeRange.self, forKey: .date)
        self.publish = try container.decode(TimeRange.self, forKey: .publish)
        self.features = try container.decode([Feature].self, forKey: .features)
    }
}
