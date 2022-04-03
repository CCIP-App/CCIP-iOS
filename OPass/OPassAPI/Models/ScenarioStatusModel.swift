//
//  ScenarioStatusModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
//

import Foundation

struct ScenarioStatusModel: Hashable, Decodable {
    @TransformWith<OidTransform> var _id = ""
    var event_id: String = ""
    var token: String = ""
    var user_id: String = ""
    var attr = AttrModel()
    @TransformWith<IntergerToDateTransform> var first_use = Date()
    var role: String = ""
    @TransformWith<ScenarioModelsTransform> var scenarios = [ScenarioModel()]
}

struct OidTransform: TransformFunction {
    static func transform(_ dictionary: [String : String]) -> String {
        return dictionary["$oid"]!
    }
}

struct ScenarioModelsTransform: TransformFunction {
    static func transform(_ scenarios: [ScenarioModel]) -> [ScenarioModel] {
        return scenarios
            .sorted { $0.order < $1.order } //sort by order
    }
}

struct AttrModel: Hashable, Codable {
    var diet: String? = nil
}

struct ScenarioModel: Hashable, Decodable {
    var order: Int = 0
    var display_text = DisplayTextModel_CountryCode()
    @TransformWith<IntergerToDateTransform> var available_time = Date()
    @TransformWith<IntergerToDateTransform> var expire_time = Date()
    var disable: String? = nil
    var countdown: Int = 0
    var attr = AttrModel()
    var used: Int? = nil
    var id: String = ""
}

struct IntergerToDateTransform: TransformFunction {
    static func transform(_ time: Int) -> Date {
        return Date.init(timeIntervalSince1970: TimeInterval(time))
    }
}
