//
//  Attendee.swift
//  OPass
//
//  Created by Brian Chang on 2025/4/17.
//  2025 OPass.
//

import Foundation
import OrderedCollections
import SwiftData
import SwiftDate

@Model
final class Attendee: Decodable {
    @Attribute(.unique) var id: String
    var eventId: String
    var userId: String?
    var token: String
    var role: String
    var attributes: [String: String]
    var firstUse: DateInRegion

    @Relationship(deleteRule: .cascade) var scenarioSections: [ScenarioSection] = []

    @Relationship(inverse: \Event.attendee) var event: Event?

    // MARK: - Decoding
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case eventId = "event_id"
        case userId = "user_id"
        case token
        case role
        case attributes = "attr"
        case firstUse = "first_use"
        case scenarios
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try container.decode([String: String].self, forKey: .id))["$oid"]!
        self.eventId = try container.decode(String.self, forKey: .eventId)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
        self.token = try container.decode(String.self, forKey: .token)
        self.role = try container.decode(String.self, forKey: .role)
        self.attributes = try container.decode([String: String].self, forKey: .attributes)
        let seconds = try container.decode(Int.self, forKey: .firstUse)
        self.firstUse = .init(seconds: .init(seconds), region: .current)
        let rawScenarios = try container.decode([RawScenario].self, forKey: .scenarios)
        self.scenarioSections = processScenarios(rawScenarios)
    }

    private struct RawScenario: Decodable {
        var id: String
        var order: Int
        var title: LocalizedCodeString
        var disabled: String?
        var available: DateInRegion
        var expire: DateInRegion
        var countdown: Int
        var attributes: [String: String]
        var used: DateInRegion?

        private enum CodingKeys: String, CodingKey {
            case id
            case order
            case title = "display_text"
            case disabled
            case available = "available_time"
            case expire = "expire_time"
            case countdown
            case attributes = "attr"
            case used
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.order = try container.decode(Int.self, forKey: .order)
            self.title = try container.decode(LocalizedCodeString.self, forKey: .title)
            self.disabled = try container.decodeIfPresent(String.self, forKey: .disabled)
            let availableSeconds = try container.decode(Int.self, forKey: .available)
            self.available = .init(seconds: .init(availableSeconds), region: .current)
            let expireSeconds = try container.decode(Int.self, forKey: .expire)
            self.expire = .init(seconds: .init(expireSeconds), region: .current)
            self.countdown = try container.decode(Int.self, forKey: .countdown)
            self.attributes = try container.decode([String: String].self, forKey: .attributes)
            let usedSeconds = try container.decode(Int.self, forKey: .used)
            self.used = .init(seconds: .init(usedSeconds), region: .current)
        }
    }

    private func processScenarios(_ scenarios: [RawScenario]) -> [ScenarioSection] {
        // TODO: The following is extended from original's method. Should be custom rewrite.
        var scenarioDic: OrderedDictionary<String, [RawScenario]> = [:]
        let scenarios = scenarios.sorted { $0.order < $1.order }
        for scenario in scenarios {
            var index = 3
            var key = scenario.id
            if key.contains("day") {
                while key[key.index(key.startIndex, offsetBy: index + 1)].isNumber { index += 1 }
                let range = ...key.index(key.startIndex, offsetBy: index)
                key = "\(key[range]) • \(scenario.available.month)/\(scenario.available.day)"
                key.insert(" ", at: key.index(key.startIndex, offsetBy: 3))
            } else if key.contains("kit") {
                key = "kit"
            }
            scenarioDic.updateValue(forKey: key, default: []) { $0.append(scenario) }
        }
        var lastDayIndex = scenarioDic.keys.lastIndex { $0.contains("day") } ?? 0
        for index in 0..<lastDayIndex {
            if !scenarioDic.keys[index].contains("day") {
                scenarioDic.swapAt(index, lastDayIndex)
                lastDayIndex = scenarioDic.keys.lastIndex { $0.contains("day") } ?? 0
            }
        }
        var result: [ScenarioSection] = []
        for (index, (key, scenarios)) in scenarioDic.enumerated() {
            let section = ScenarioSection(order: index, title: key)
            for scenario in scenarios {
                section.scenarios.append(
                    .init(
                        id: scenario.id,
                        order: scenario.order,
                        title: scenario.title,
                        available: scenario.available,
                        expire: scenario.expire,
                        countdown: scenario.countdown,
                        attributes: scenario.attributes,
                        used: scenario.used
                    )
                )
            }
            result.append(section)
        }
        return result
    }
}
