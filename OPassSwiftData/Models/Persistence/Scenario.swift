//
//  Scenario.swift
//  OPass
//
//  Created by Brian Chang on 2025/4/17.
//  2025 OPass.
//

import Foundation
import SwiftData
import SwiftDate

@Model
final class ScenarioSection {
    @Attribute(.unique) var order: Int
    var title: String
    
    @Relationship(deleteRule: .cascade) var scenarios: [Scenario] = []
    
    @Relationship(inverse: \Attendee.scenarioSections) var attendee: Attendee?
    
    init(order: Int, title: String) {
        self.order = order
        self.title = title
    }
}

@Model
final class Scenario {
    @Attribute(.unique) var id: String
    var order: Int
    var title: LocalizedCodeString
    var disabled: String?
    var available: DateInRegion
    var expire: DateInRegion
    var countdown: Int
    var attributes: [String: String]
    var used: DateInRegion?
    
    @Relationship(inverse: \ScenarioSection.scenarios) var section: ScenarioSection?
    
    init(
        id: String,
        order: Int,
        title: LocalizedCodeString,
        disabled: String? = nil,
        available: DateInRegion,
        expire: DateInRegion,
        countdown: Int,
        attributes: [String: String],
        used: DateInRegion? = nil
    ) {
        self.id = id
        self.order = order
        self.title = title
        self.disabled = disabled
        self.available = available
        self.expire = expire
        self.countdown = countdown
        self.attributes = attributes
        self.used = used
    }
}

extension Scenario {
    var symbol: String {
        switch id {
        case _ where id.contains("breakfast") || id.contains("lunch") || id.contains("dinner"):
            return "takeoutbag.and.cup.and.straw"
        case _ where id.contains("checkin") || id.contains("checkout"):
            return "pencil"
        case _ where id.contains("vipkit"):
            return "gift"
        case _ where id.contains("kit"):
            return "bag"
        default:
            return "squareshape.squareshape.dashed"
        }
    }
}
