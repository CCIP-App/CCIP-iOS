//
//  EventSettingsModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//

import Foundation

struct EventSettingsModel: Hashable, Codable {
    var event_id: String = ""
    var display_name = DisplayTextModel()
    var logo_url: String = ""
    var event_date = Start_EndModel()
    var publish = Start_EndModel()
    var features: [FeatureDetailModel] = []
}

struct WiFiModel: Hashable, Codable {
    var SSID: String = ""
    var password: String = ""
}

struct Start_EndModel: Hashable, Codable {
    var start: String = ""
    var end: String = ""
}

struct FeatureDetailModel: Hashable, Codable {
    var feature: FeatureType
    var icon: String? = nil
    var display_text = DisplayTextModel()
    var wifi: [WiFiModel]? = nil
    var url: String? = nil
}

enum FeatureType: String, Hashable, Codable {
    case fastpass, ticket, schedule, announcement, wifi, telegram, im, puzzle, venue, sponsors, staffs, webview
}
