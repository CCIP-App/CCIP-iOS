//
//  Portal.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import then
import SwiftyJSON
import SwiftDate

enum OPassKnownFeatures: String {
    case FastPass = "fastpass"
    case Schedule = "schedule"
    case Announcement = "announcement"
    case Puzzle = "puzzle"
    case Ticket = "ticket"
    case Telegram = "telegram"
    case IM = "im"
    case Venue = "venue"
    case Sponsors = "sponsors"
    case Partners = "partners"
    case Staffs = "staffs"
    case WebView = "webview"
}

struct EventDisplayName: OPassData {
    var _data: JSON
    init(_ data: JSON) {
        self._data = data
    }
    subscript(_ member: String) -> String {
        if member == "_displayData" {
            return ""
        }
        return self._data[member].stringValue
    }
}

struct PublishDate: OPassData {
    var _data: JSON
    var Start: Date
    var End: Date
    init(_ data: JSON) {
        self._data = data
        self.Start = Date.init(seconds: self._data["start"].stringValue.toDate(style: .iso(.init()))!.timeIntervalSince1970)
        self.End = Date.init(seconds: self._data["end"].stringValue.toDate(style: .iso(.init()))!.timeIntervalSince1970)
    }
}

struct EventFeatures: OPassData {
    var _data: JSON
    var Feature: String
    var Icon: URL?
    var DisplayText: EventDisplayName
    var Url: URL?
    var VisibleRoles: [String]?
    init(_ data: JSON) {
        self._data = data
        self.Feature = self._data["feature"].stringValue
        self.Icon = self._data["icon"].url
        self.DisplayText = EventDisplayName(self._data["display_text"])
        var url = self._data["url"].string
        if (url != nil) {
            let paramsRegex = try? NSRegularExpression.init(pattern: "(\\{[^\\}]+\\})", options: .caseInsensitive)
            let matches = paramsRegex!.matches(in: url!, options: .reportProgress, range: NSMakeRange(0, url!.count))
            for m in stride(from: matches.count, to: 0, by: -1) {
                let range = matches[m - 1].range(at: 1)
                let param = url![range]
                switch param {
                case "{token}":
                    url = url?.replacingOccurrences(of: param, with: Constants.accessToken ?? "")
                default:
                    url = url?.replacingOccurrences(of: param, with: "")
                }
            }
            self.Url = URL(string: url!)
        }
        self.VisibleRoles = self._data["visible_roles"].arrayObject as? [String]
    }
}

extension Array where Element == EventFeatures {
    subscript(_ feature: OPassKnownFeatures) -> EventFeatures? {
        return self.first { ft -> Bool in
            if OPassKnownFeatures(rawValue: ft.Feature) == feature {
                return true
            }
            return false
        }
    }
}

struct EventInfo: OPassData {
    var _data: JSON
    var EventId: String
    var DisplayName: EventDisplayName
    var LogoUrl: URL
    var Publish: PublishDate
    var ServerBaseUrl: URL
    var SessionUrl: URL
    var Features: Array<EventFeatures>
    init(_ data: JSON) {
        self._data = data
        self.EventId = self._data["event_id"].stringValue
        self.DisplayName = EventDisplayName(self._data["display_name"])
        self.LogoUrl = self._data["logo_url"].url!
        self.Publish = PublishDate(self._data["publish"])
        self.ServerBaseUrl = self._data["server_base_url"].url!
        self.SessionUrl = self._data["schedule_url"].url!
        self.Features = self._data["features"].arrayValue.map { ft -> EventFeatures in
            return EventFeatures(ft)
        }
    }
}

struct EventShortInfo: Codable {
    var _data: JSON
    var EventId: String
    var DisplayName: EventDisplayName
    var LogoUrl: URL
    init(_ data: JSON) {
        self._data = data
        self.EventId = self._data["event_id"].stringValue
        self.DisplayName = EventDisplayName(self._data["display_name"])
        self.LogoUrl = self._data["logo_url"].url!
    }
}

extension OPassAPI {
    static func GetEvents(_ onceErrorCallback: OPassErrorCallback) -> Promise<Array<EventShortInfo>> {
        return OPassAPI.InitializeRequest("https://portal.opass.app/events/", onceErrorCallback)
            .then({ (infoObj: Any) -> Array<EventShortInfo> in
                return JSON(infoObj).arrayValue.map { info -> EventShortInfo in
                    return EventShortInfo(info)
                }
            })
    }

    static func SetEvent(_ eventId: String, _ onceErrorCallback: OPassErrorCallback) -> Promise<EventInfo> {
        return OPassAPI.InitializeRequest("https://portal.opass.app/events/\(eventId)/", onceErrorCallback)
            .then { (infoObj: Any) -> EventInfo in
                OPassAPI.eventInfo = EventInfo(JSON(infoObj))
                OPassAPI.currentEvent = JSONSerialization.stringify(infoObj as Any)!
                return OPassAPI.eventInfo!
        }
    }

    static func CleanupEvents() {
        OPassAPI.eventInfo = nil
        OPassAPI.currentEvent = ""
    }

    static func DoLogin(_ eventId: String, _ token: String, _ completion: OPassCompletionCallback) {
        async {
            while true {
                var vc: UIViewController? = nil
                DispatchQueue.main.sync {
                    vc = UIApplication.getMostTopPresentedViewController()!
                }
                let vcName = vc!.className
                var done = false
                try? await(Promise{ resolve, reject in
                    switch vcName {
                    case OPassEventsController.className:
                        DispatchQueue.main.sync {
                            Constants.isLoginSession = false
                            Constants.accessToken = ""
                        }
                        done = true
                        resolve()
                        break
                    default:
                        DispatchQueue.main.async {
                            vc!.dismiss(animated: true, completion: {
                                resolve()
                            })
                        }
                    }
                })
                if done {
                    break
                }
            }
            DispatchQueue.main.sync {
                let opec = UIApplication.getMostTopPresentedViewController() as! OPassEventsController
                opec.LoadEvent(eventId).then { _ in
                    OPassAPI.RedeemCode(eventId, token, completion)
                }
            }
        }
    }
}
