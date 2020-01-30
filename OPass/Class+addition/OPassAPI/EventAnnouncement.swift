//
//  EventAnnouncement.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import SwiftyJSON

struct AnnouncementInfo: OPassData {
    var _data: JSON
    var DateTime: Date
    var MsgZh: String
    var MsgEn: String
    var URI: String
    init(_ data: JSON) {
        self._data = data
        self.DateTime = Constants.DateFromUnix(self._data["datetime"].intValue)
        self.MsgZh = self._data["msg_zh"].stringValue
        self.MsgEn = self._data["msg_en"].stringValue
        self.URI = self._data["uri"].stringValue
    }
}

extension OPassAPI {
    static func GetAnnouncement(_ event: String, _ completion: OPassCompletionArrayCallback) {
        if event.count > 0 {
            OPassAPI.InitializeRequest(Constants.URL_ANNOUNCEMENT) { _, _, error, _ in
                completion?(false, nil, error)
                }.then { (obj: Any?) -> Void in
                    if obj != nil {
                        let announces = JSON(obj!).arrayValue.map { ann -> AnnouncementInfo in
                            return AnnouncementInfo(ann)
                        }
                        completion?(true, announces, OPassSuccessError)
                    } else {
                        completion?(false, [RawOPassData(obj!)], NSError(domain: "OPass can not get announcement", code: 2, userInfo: nil))
                    }
            }
        } else {
            completion?(false, nil, NSError(domain: "OPass can not get announcement, because event was not set", code: 1, userInfo: nil))
        }
    }
}
