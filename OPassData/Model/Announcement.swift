//
//  Announcement.swift
//  OPass
//
//  Created by secminhr on 2022/3/5.
//  2025 OPass.
//

import Foundation
import SwiftDate

struct Announcement: Hashable, Codable, Localizable {
    @Transform<IntToDate> var datetime: DateInRegion
    var zh: String
    var en: String
    var uri: String

    private enum CodingKeys: String, CodingKey {
        case datetime
        case zh = "msg_zh"
        case en = "msg_en"
        case uri
    }
}

extension Announcement {
    @inline(__always)
    var url: URL? { URL(string: uri) }
}
