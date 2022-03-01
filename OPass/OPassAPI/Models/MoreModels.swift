//
//  Structs.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//

import Foundation

struct EventModel: Hashable, Codable {
    var event_id: String
    var display_name: DisplayTextModel
    var logo_url: String
}

struct DisplayTextModel: Hashable, Codable {
    var en: String
    var zh: String
}
