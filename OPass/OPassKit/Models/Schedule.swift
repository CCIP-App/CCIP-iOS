//
//  Schedule.swift
//  OPass
//
//  Created by Brian Chang on 2022/3/2.
//  2023 OPass.
//

import SwiftDate
import OrderedCollections

struct Schedule: Hashable, Codable {
    @Transform<Session> var sessions: [OrderedDictionary<DateInRegion, [Session]>]
    @Transform<Speaker> var speakers: OrderedDictionary<String, Speaker>
    @Transform<Tag> var types: OrderedDictionary<String, Tag>
    @Transform<Tag> var rooms: OrderedDictionary<String, Tag>
    @Transform<Tag> var tags: OrderedDictionary<String, Tag>
    
    enum CodingKeys: String, CodingKey {
        case sessions
        case speakers
        case types = "session_types"
        case rooms
        case tags
    }
}
