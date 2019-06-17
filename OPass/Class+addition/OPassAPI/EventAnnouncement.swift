//
//  EventAnnouncement.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import SwiftyJSON

struct AnnouncementInfo {
    var DateTime: Date
    var MsgZh: String
    var MsgEn: String
    var URI: String
}

extension OPassAPI {
    static func GetAnnouncement(_ event: String, _ completion: OPassCompletionCallback) {
        if event.count > 0 {
            OPassAPI.InitializeRequest(Constants.URL_ANNOUNCEMENT) { retryCount, retryMax, error, responsed in
                completion?(false, nil, error)
                }.then { (obj: Any?) -> Void in
                    if obj != nil {
                        var announces = [AnnouncementInfo]()
                        for ann in JSON(obj!).arrayValue {
                            let dt = Constants.DateFromUnix(ann["datetime"].intValue)
                            let announce = AnnouncementInfo(
                                DateTime: dt,
                                MsgZh: ann["msg_zh"].stringValue,
                                MsgEn: ann["msg_en"].stringValue,
                                URI: ann["uri"].stringValue
                            )
                            announces.append(announce)
                        }
                        completion?(true, announces, OPassSuccessError)
                    } else {
                        completion?(false, obj, NSError(domain: "OPass can not get announcement", code: 2, userInfo: nil))
                    }
            }
        } else {
            completion?(false, nil, NSError(domain: "OPass can not get announcement, because event was not set", code: 1, userInfo: nil))
        }
    }
}
