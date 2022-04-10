//
//  ScenarioStatusModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
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
    static func transform(_ scenarios: [RawScenarioModel]) -> ScenarioModel {
        let scenariosData = scenarios.sorted(by: {$0.order < $1.order})
        var data = ScenarioModel(), index = 3, sectionID = ""
        for scenario in scenariosData {
            index = 3
            let id = scenario.id
            if id.contains("day") {
                while(id[id.index(id.startIndex, offsetBy: index+1)].isNumber) { index += 1 }
                sectionID = String(id[...id.index(id.startIndex, offsetBy: index)])
                if !data.sectionID.contains(sectionID) {
                    data.sectionID.append(sectionID)
                }
                _ = data.sectionData.append(element: scenario, toValueOfKey: sectionID)
            } else if scenario.id.contains("kit") {
                if !data.sectionID.contains("kit") {
                    data.sectionID.append("kit")
                }
                _ = data.sectionData.append(element: scenario, toValueOfKey: "kit")
            } else {
                if !data.sectionID.contains(id) {
                    data.sectionID.append(id)
                }
                _ = data.sectionData.append(element: scenario, toValueOfKey: id)
            }
        }
        
        //changing section order by day sections first
        index = data.sectionID.lastIndex(where: { $0.contains("day") }) ?? 0
        for currentIndex in 0..<index {
            if !data.sectionID[currentIndex].contains("day") {
                data.sectionID.swapAt(currentIndex, index)
                index -= 1
            }
        }
        
        print(data.sectionData)
        
        return data
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
    var sectionData: [String : [RawScenarioModel]] = [:]
}

struct RawScenarioModel: Hashable, Decodable {
    var order: Int = 0
    var display_text = DisplayTextModel_CountryCode()
    @TransformWith<IntergerToDateTransform> var available_time: DateInRegion
    @TransformWith<IntergerToDateTransform> var expire_time: DateInRegion
    var disable: String? = nil
    var countdown: Int = 0
    var attr = AttrModel()
    var used: Int? = nil
    var id: String = ""
}

struct IntergerToDateTransform: TransformFunction {
    static func transform(_ time: Int) -> DateInRegion {
        return DateInRegion(milliseconds: time, region: Region.current)
    }
}
