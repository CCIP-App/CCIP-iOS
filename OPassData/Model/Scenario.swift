//
//  Scenario.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/30.
//

import SwiftDate
import OrderedCollections

struct Scenario: Hashable, Codable, Identifiable {
    var id: String
    var order: Int
    var title: LocalizedCodeString
    var disabled: String?
    @Transform<IntToDate> var available: DateInRegion
    @Transform<IntToDate> var expire: DateInRegion
    var countdown: Int
    var attributes: Dictionary<String, String>
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
        self._available = try container.decode(Transform<IntToDate>.self, forKey: .available)
        self._expire = try container.decode(Transform<IntToDate>.self, forKey: .expire)
        self.countdown = try container.decode(Int.self, forKey: .countdown)
        self.attributes = try container.decode([String : String].self, forKey: .attributes)
        if let used = try? container.decode(Int.self, forKey: .used) {
            self.used = .init(seconds: .init(used), region: .current)
        } else if let used = try? container.decode(DateInRegion.self, forKey: .used) {
            self.used = used
        } else { self.used = nil }
    }
}

extension Scenario {
    @inline(__always)
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

extension Scenario: TransformFunction { //TODO: Optimize? CheckCheckChek!
    static func transform(_ scenarios: [Scenario]) -> OrderedDictionary<String, [Scenario]> {
        var result: OrderedDictionary<String, [Scenario]> = [:]
        let scenarios = scenarios.sorted { $0.order < $1.order }
        for scenario in scenarios {
            var index = 3, key = scenario.id
            if key.contains("day") {
                while(key[key.index(key.startIndex, offsetBy: index+1)].isNumber) { index += 1 }
                let range = ...key.index(key.startIndex, offsetBy: index)
                key = "\(key[range]) • \(scenario.available.month)/\(scenario.available.day)"
                key.insert(" ", at: key.index(key.startIndex, offsetBy: 3))
            } else if key.contains("kit") { key = "kit" }
            result.updateValue(forKey: key, default: []) { $0.append(scenario) }
        }
        var lastDayIndex = result.keys.lastIndex { $0.contains("day") } ?? 0
        for index in 0 ..< lastDayIndex {
            if !result.keys[index].contains("day") {
                result.swapAt(index, lastDayIndex)
                lastDayIndex = result.keys.lastIndex { $0.contains("day") } ?? 0
            }
        }
        return result
    }
}
