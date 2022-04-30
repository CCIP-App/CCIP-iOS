//
//  EventTitleModel.swift
//  OPass
//
//  Created by secminhr on 2022/4/26.
//  2022 OPass.
//

import Foundation

struct EventTitleModel: Codable {
    let event_id: String
    let display_name: DisplayTextModel
    let logo_url: String
}
