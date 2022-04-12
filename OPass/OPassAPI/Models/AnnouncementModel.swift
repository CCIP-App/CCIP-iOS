//
//  AnnouncementModel.swift
//  OPass
//
//  Created by secminhr on 2022/3/5.
//  2022 OPass.
//

import Foundation

struct AnnouncementModel: Decodable {
    var datetime: Date
    var msg_en: String
    var msg_zh: String
    var url: String?
}
