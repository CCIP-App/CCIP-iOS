//
//  Schedule.swift
//  OPass
//
//  Created by Brian Chang on 2025/4/17.
//  2025 OPass.
//

import OrderedCollections
import SwiftData
import SwiftDate

@Model
final class Schedule: Decodable {
    @Relationship(deleteRule: .cascade) var days: [ScheduleDay] = []
    @Relationship(deleteRule: .cascade) var speakers: [Speaker] = []
    @Relationship(deleteRule: .cascade) var types: [SessionType] = []
    @Relationship(deleteRule: .cascade) var rooms: [Room] = []
    @Relationship(deleteRule: .cascade) var tags: [Tag] = []
    
    @Relationship(inverse: \Event.schedule) var event: Event?
    
    // MARK: - Decoding
    private enum CodingKeys: String, CodingKey {
        case sessions
        case speakers
        case types = "session_types"
        case rooms
        case tags
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.speakers = try container.decode([Speaker].self, forKey: .speakers)
        self.types = try container.decode([SessionType].self, forKey: .types)
        self.rooms = try container.decode([Room].self, forKey: .rooms)
        self.tags = try container.decode([Tag].self, forKey: .tags)
        let sessions = try container.decode([Session].self, forKey: .sessions)
        self.days = processSessions(sessions)
    }
    
    private func processSessions(_ sessions: [Session]) -> [ScheduleDay] {
        return Dictionary(grouping: sessions) { $0.start.dateTruncated(from: .hour)! }
            .sorted { $0.key < $1.key }
            .map { $0.value.sorted { $0.start < $1.start } }
            .map { OrderedDictionary(grouping: $0, by: \.start) }
            .map { $0.mapValues { $0.sorted { $0.end < $1.end } } }
            .map {
                let day = ScheduleDay(date: $0.keys[0])
                for (index, (startTime, sessions)) in $0.enumerated() {
                    let timeSlot = ScheduleTimeSlot(order: index, startTime: startTime)
                    timeSlot.sessions = sessions
                    day.append(timeSlot)
                }
                return day
            }
    }
}

@Model
final class ScheduleDay {
    var date: DateInRegion
    
    @Relationship(deleteRule: .cascade) var timeSlots: [ScheduleTimeSlot] = []
    
    @Relationship(inverse: \Schedule.days) var schedule: Schedule?
    
    init(date: DateInRegion) {
        self.date = date
    }
}

@Model
final class ScheduleTimeSlot {
    var order: Int
    var startTime: DateInRegion
    
    @Relationship(deleteRule: .cascade) var sessions: [Session] = []
    
    @Relationship(inverse: \ScheduleDay.timeSlots) var day: ScheduleDay?
    
    init(order: Int, startTime: DateInRegion) {
        self.order = order
        self.startTime = startTime
    }
}
