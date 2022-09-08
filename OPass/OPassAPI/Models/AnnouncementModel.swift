//
//  AnnouncementModel.swift
//  OPass
//
//  Created by secminhr on 2022/3/5.
//  2022 OPass.
//

import Foundation
import SwiftDate

struct AnnouncementModel: Codable {
    @TransformWith<IntergerToDateTransform> var datetime: DateInRegion
    var msg_en: String
    var msg_zh: String
    var uri: String
    
    func localized() -> String {
        if Bundle.main.preferredLocalizations[0] ==  "zh-Hant" { return self.msg_zh }
        return self.msg_en
    }
}
