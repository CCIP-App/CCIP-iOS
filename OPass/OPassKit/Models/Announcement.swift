//
//  Announcement.swift
//  OPass
//
//  Created by secminhr on 2022/3/5.
//  2023 OPass.
//

import Foundation
import SwiftDate

struct Announcement: Hashable, Codable, Localizable {
    @Transform<IntergerToDateTransform> var datetime: DateInRegion
    var zh: String
    var en: String
    var uri: String

    enum CodingKeys: String, CodingKey {
        case datetime
        case zh = "msg_zh"
        case en = "msg_en"
        case uri
    }
}

extension Announcement {
    var url: URL? { URL(string: uri) }
}
