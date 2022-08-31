//
//  SettingsModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//  2022 OPass.
//

import Foundation
import SwiftDate

struct SettingsModel: Hashable, Codable {
    var event_id: String = ""
    var display_name = DisplayTextModel()
    var logo_url: String = ""
    var event_date = Start_EndModel()
    var publish = Start_EndModel()
    var features: [FeatureModel] = []
}

struct WiFiModel: Hashable, Codable {
    var SSID: String = ""
    var password: String = ""
}

struct Start_EndModel: Hashable, Codable {
    @TransformWith<StringToDateTransform> var start = DateInRegion()
    @TransformWith<StringToDateTransform> var end = DateInRegion()
}

struct FeatureModel: Hashable, Codable {
    let feature: FeatureType
    var icon: String? = nil
    var iconData: Data? = nil
    var display_text = DisplayTextModel()
    var visible_roles: [String]? = nil
    var wifi: [WiFiModel]? = nil
    var url: String? = nil
}

enum FeatureType: String, Hashable, Codable {
    case fastpass, ticket, schedule, announcement, wifi, telegram, im, puzzle, venue, sponsors, staffs, webview
}


extension SettingsModel {
    func feature(ofType type: FeatureType) -> FeatureModel? {
        return features.first { $0.feature == type }
    }
}
