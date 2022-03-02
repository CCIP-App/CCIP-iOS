//
//  EventSettingsModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//

import Foundation

struct EventSettingsModel: Hashable, Codable {
    var event_id = ""
    var display_name = DisplayTextModel()
    var logo_url = ""
    var event_date = Start_EndModel()
    var publish = Start_EndModel()
    var features = [FeatureDetailModel()]
}

struct WiFiModel: Hashable, Codable {
    var SSID = ""
    var password = ""
}

struct Start_EndModel: Hashable, Codable {
    var start = ""
    var end = ""
}

struct FeatureDetailModel: Hashable, Codable {
    var feature = ""
    var icon: String?
    var display_text = DisplayTextModel()
    var wifi: [WiFiModel]?
    var url: String?
}
