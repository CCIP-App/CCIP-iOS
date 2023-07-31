//
//  Attendee.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
//  2023 OPass.
//

import SwiftDate
import OrderedCollections

struct Attendee: Hashable, Codable, Identifiable {
    @Transform<Oid> internal var id: String
    var eventId: String
    var userId: String?
    var token: String
    var role: String
    var attributes: Dictionary<String, String>
    @Transform<IntToDate> var firstUse: DateInRegion
    @Transform<Scenario> var scenarios: OrderedDictionary<String, [Scenario]>

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case userId = "user_id"
        case token
        case role
        case attributes = "attr"
        case firstUse = "first_use"
        case scenarios
    }
}

struct Oid: TransformFunction {
    static func transform(_ dictionary: [String : String]) -> String {
        return dictionary["$oid"]!
    }
}
