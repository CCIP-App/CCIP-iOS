//
//  Session.swift
//  OPass
//
//  Created by Brian Chang on 2025/4/17.
//

import SwiftData
import SwiftDate

@Model
final class Session: Decodable, Localizable {
    @Attribute(.unique) var id: String
    var type: String?
    var room: String
    var broadcast: [String]?
    var start: DateInRegion
    var end: DateInRegion
    var coWrite: String?
    var qa: String?
    var slide: String?
    var live: String?
    var record: String?
    var language: String?
    var uri: String?
    var zh: TitleDescription
    var en: TitleDescription
    var speakers: [String]
    var tags: [String]

    @Relationship(inverse: \ScheduleTimeSlot.sessions) var timeSlot: ScheduleTimeSlot?
    
    struct TitleDescription: Hashable, Codable {
        var title: String
        var description: String
    }

    // MARK: - Decoding
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case room
        case broadcast
        case start
        case end
        case coWrite = "co_write"
        case qa
        case slide
        case live
        case record
        case language
        case uri
        case zh
        case en
        case speakers
        case tags
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.room = try container.decode(String.self, forKey: .room)
        self.broadcast = try container.decodeIfPresent([String].self, forKey: .broadcast)
        let startString = try container.decode(String.self, forKey: .start)
        self.start = try .init(startString)
        let endString = try container.decode(String.self, forKey: .end)
        self.end = try .init(endString)
        self.coWrite = try container.decodeIfPresent(String.self, forKey: .coWrite)
        self.qa = try container.decodeIfPresent(String.self, forKey: .qa)
        self.slide = try container.decodeIfPresent(String.self, forKey: .slide)
        self.live = try container.decodeIfPresent(String.self, forKey: .live)
        self.record = try container.decodeIfPresent(String.self, forKey: .record)
        self.language = try container .decodeIfPresent(String.self, forKey: .language)
        self.uri = try container.decodeIfPresent(String.self, forKey: .uri)
        self.zh = try container.decode(TitleDescription.self, forKey: .zh)
        self.en = try container.decode(TitleDescription.self, forKey: .en)
        self.speakers = try container.decode([String].self, forKey: .speakers)
        self.tags = try container.decode([String].self, forKey: .tags)
    }
}

@Model
final class SessionType: Decodable, Localizable {
    @Attribute(.unique) var id: String
    var zh: NameDescription
    var en: NameDescription

    @Relationship(inverse: \Schedule.tags) var scheduleForTags: Schedule?

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
