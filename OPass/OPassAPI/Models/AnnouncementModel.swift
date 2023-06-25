//
//  AnnouncementModel.swift
//  OPass
//
//  Created by secminhr on 2022/3/5.
//  2023 OPass.
//

import Foundation
import SwiftDate

struct AnnouncementModel: Codable {
    @TransformWith<IntergerToDateTransform> var datetime: DateInRegion
    var msg_en: String
    var msg_zh: String
    var uri: String
    var url: URL? {
        URL(string: uri)
    }
    
    func localized() -> String {
        if Bundle.main.preferredLocalizations[0] ==  "zh-Hant" { return self.msg_zh }
        return self.msg_en
    }
}
