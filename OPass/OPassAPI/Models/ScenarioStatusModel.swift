//
//  ScenarioStatusModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
//  2022 OPass.
//

import Foundation
import SwiftDate

struct ScenarioStatusModel: Hashable, Decodable {
    @TransformWith<OidTransform> var _id = ""
    var event_id: String = ""
    var token: String = ""
    var user_id: String = ""
    var attr = AttrModel()
    @TransformWith<IntergerToDateTransform> var first_use: DateInRegion
    var role: String = ""
    @TransformWith<ScenarioModelsTransform> var scenarios: ScenarioModel
}

struct OidTransform: TransformFunction {
    static func transform(_ dictionary: [String : String]) -> String {
        return dictionary["$oid"]!
    }
}

struct ScenarioModelsTransform: TransformFunction {
    static func transform(_ scenarios: [RawScenarioDataModel]) -> ScenarioModel {
        let scenariosData = scenarios.sorted(by: {$0.order < $1.order})
        var data = ScenarioModel(), index = 3
        for scenario in scenariosData {
            index = 3
            var id = scenario.id
            if id.contains("day") {
                while(id[id.index(id.startIndex, offsetBy: index+1)].isNumber) { index += 1 }
                id = String(id[...id.index(id.startIndex, offsetBy: index)])
                id.insert(" ", at: id.index(id.startIndex, offsetBy: 3))
            } else if scenario.id.contains("kit") { id = "kit" }
            id += String(format: " • %d/%d", scenario.available_time.month, scenario.available_time.day)
            if !data.sectionID.contains(id) { data.sectionID.append(id) }
            _ = data.sectionData.append(element: toScenarioData(from: scenario), toValueOfKey: id)
        }
        
        //changing section order by day sections first
        index = data.sectionID.lastIndex(where: { $0.contains("day") }) ?? 0
        for currentIndex in 0..<index {
            if !data.sectionID[currentIndex].contains("day") {
                data.sectionID.swapAt(currentIndex, index)
                index = data.sectionID.lastIndex(where: { $0.contains("day") }) ?? 0
            }
        }
        return data
    }
    
    private static func toScenarioData(from data: RawScenarioDataModel) -> ScenarioDataModel {
        var symbolName = "squareshape.squareshape.dashed" //default value
        if data.id.contains("checkin") { symbolName = "pencil" }
        else if data.id.contains("breakfast") || data.id.contains("lunch") || data.id.contains("dinner") { symbolName = "takeoutbag.and.cup.and.straw" }
        else if data.id.contains("vipkit") { symbolName = "gift" }
        else if data.id.contains("kit") { symbolName = "bag" }
        
        return ScenarioDataModel(
            order: data.order,
            display_text: data.display_text,
            available_time: data.available_time,
            expire_time: data.expire_time,
            disable: data.disable,
            countdown: data.countdown,
            attr: data.attr,
            used: data.used == nil ? nil : DateInRegion(seconds: TimeInterval(data.used!), region: Region.current),
            symbolName: symbolName,
            id: data.id)
    }
}

extension Dictionary where Value: RangeReplaceableCollection {
    public mutating func append(element: Value.Iterator.Element, toValueOfKey key: Key) -> Value? {
        var value: Value = self[key] ?? Value()
        value.append(element)
        self[key] = value
        return value
    }
}

struct AttrModel: Hashable, Codable {
    var diet: String? = nil
}

struct ScenarioModel: Hashable, Decodable {
    var sectionID: [String] = []
    var sectionData: [String : [ScenarioDataModel]] = [:]
}

struct ScenarioDataModel: Hashable, Decodable, Identifiable {
    var order: Int = 0
    var display_text = DisplayTextModel_CountryCode()
    var available_time: DateInRegion
    var expire_time: DateInRegion
    var disable: String? = nil
    var countdown: Int = 0
    var attr = AttrModel()
    var used: DateInRegion?
    var symbolName: String = ""
    var id: String = ""
}

struct RawScenarioDataModel: Hashable, Decodable {
    var order: Int = 0
    var display_text = DisplayTextModel_CountryCode()
    @TransformWith<IntergerToDateTransform> var available_time: DateInRegion
    @TransformWith<IntergerToDateTransform> var expire_time: DateInRegion
    var disable: String? = nil
    var countdown: Int = 0
    var attr = AttrModel()
    var used: Int?
    var id: String = ""
}

struct IntergerToDateTransform: TransformFunction {
    static func transform(_ time: Int) -> DateInRegion {
        return DateInRegion(seconds: TimeInterval(time), region: Region.current)
    }
}
