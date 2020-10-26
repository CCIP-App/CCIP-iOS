//
//  Portal.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  2019 OPass.
//

import Foundation
import Then
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
    case WiFiConnect = "wifi"
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
        self.Start = Date.init()
        self.End = Date.init()
        if let start = self._data["start"].stringValue.toDate(style: .iso(.init())) {
            self.Start = Date.init(seconds: start.timeIntervalSince1970)
        }
        if let end = self._data["end"].stringValue.toDate(style: .iso(.init())) {
            self.End = Date.init(seconds: end.timeIntervalSince1970)
        }
    }
}

struct EventWiFi: OPassData {
    var _data: JSON
    var SSID: String
    var Password: String
    init(_ data: JSON) {
        self._data = data
        self.SSID = self._data["SSID"].stringValue
        self.Password = self._data["password"].stringValue
    }
}

struct EventFeatures: OPassData {
    var _data: JSON
    var Feature: String
    var Icon: URL?
    var DisplayText: EventDisplayName
    var WiFi: [EventWiFi]
    var _url: String?
    var Url: URL? {
        get {
            if var newUrl = _url {
                guard let paramsRegex = try? NSRegularExpression.init(pattern: "(\\{[^\\}]+\\})", options: .caseInsensitive) else { return nil }
                let matches = paramsRegex.matches(in: newUrl, options: .reportProgress, range: NSRange(location: 0, length: newUrl.count))
                for m in stride(from: matches.count, to: 0, by: -1) {
                    let range = matches[m - 1].range(at: 1)
                    let param = newUrl[range]
                    switch param {
                    case "{token}":
                        newUrl = newUrl.replacingOccurrences(of: param, with: Constants.accessToken ?? "")
                    case "{public_token}":
                        newUrl = newUrl.replacingOccurrences(of: param, with: Constants.accessTokenSHA1)
                    case "{role}":
                        newUrl = newUrl.replacingOccurrences(of: param, with: OPassAPI.userInfo?.Role ?? "")
                    default:
                        newUrl = newUrl.replacingOccurrences(of: param, with: "")
                    }
                }
                return URL(string: newUrl)
            } else {
                return nil
            }
        }
    }

    var VisibleRoles: [String]?
    init(_ data: JSON) {
        self._data = data
        self.Feature = self._data["feature"].stringValue
        self.Icon = self._data["icon"].url
        self.DisplayText = EventDisplayName(self._data["display_text"])
        self.WiFi = self._data["wifi"].arrayValue.map({ wifi -> EventWiFi in
            return EventWiFi(wifi)
        })
        self._url = self._data["url"].string
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
    var Features: Array<EventFeatures>
    init(_ data: JSON) {
        self._data = data
        self.EventId = self._data["event_id"].stringValue
        self.DisplayName = EventDisplayName(self._data["display_name"])
        self.LogoUrl = URL.init(fileURLWithPath: "")
        if let logoUrl = self._data["logo_url"].url {
            self.LogoUrl = logoUrl
        }
        self.Publish = PublishDate(self._data["publish"])
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
        self.LogoUrl = URL.init(fileURLWithPath: "")
        if let logoUrl = self._data["logo_url"].url {
            self.LogoUrl = logoUrl
        }
    }
}

extension OPassAPI {
    static func GetEvents(_ onceErrorCallback: OPassErrorCallback) -> Promise<Array<EventShortInfo>> {
        return OPassAPI.InitializeRequest("https://\(OPassAPI.PORTAL_DOMAIN)/events/", onceErrorCallback)
            .then({ (infoObj: Any) -> Array<EventShortInfo> in
                return JSON(infoObj).arrayValue.map { info -> EventShortInfo in
                    return EventShortInfo(info)
                }
            })
    }

    static func SetEvent(_ eventId: String, _ onceErrorCallback: OPassErrorCallback) -> Promise<EventInfo> {
        return OPassAPI.InitializeRequest("https://\(OPassAPI.PORTAL_DOMAIN)/events/\(eventId)/", onceErrorCallback)
            .then { (infoObj: Any) -> EventInfo in
                OPassAPI.eventInfo = EventInfo(JSON(infoObj))
                OPassAPI.currentEvent = ""
                OPassAPI.lastEventId = ""
                if let eventJson = JSONSerialization.stringify(infoObj as Any) {
                    OPassAPI.currentEvent = eventJson
                }
                if let eventInfo = OPassAPI.eventInfo {
                    OPassAPI.lastEventId = eventInfo.EventId
                    return eventInfo
                }
                return EventInfo(JSON(parseJSON: "{}"))
        }
    }

    static func CleanupEvents() {
        OPassAPI.currentEvent = ""
        OPassAPI.eventInfo = nil
        OPassAPI.userInfo = nil
        OPassAPI.scenarios = []
        OPassAPI.isLoginSession = false
        AppDelegate.delegateInstance.checkinView = nil
    }

    static func DoLogin(_ eventId: String, _ token: String, _ completion: OPassCompletionCallback) {
        async {
            while true {
                var vc: UIViewController? = nil
                DispatchQueue.main.sync {
                    if let topMost = UIApplication.getMostTopPresentedViewController() {
                        vc = topMost
                    }
                }
                guard let vcName = vc?.className else { return }
                var done = false
                try? await(Promise{ resolve, _ in
                    switch vcName {
                    case OPassEventsController.className:
                        DispatchQueue.main.sync {
                            OPassAPI.isLoginSession = false
                            OPassAPI.userInfo = nil
                            Constants.accessToken = ""
                        }
                        done = true
                        resolve()
                        break
                    default:
                        DispatchQueue.main.async {
                            if let vc = vc {
                                vc.dismiss(animated: true, completion: {
                                    resolve()
                                })
                            }
                        }
                    }
                })
                if done {
                    break
                }
            }
            DispatchQueue.main.sync {
                if let opec = UIApplication.getMostTopPresentedViewController() as? OPassEventsController {
                    opec.LoadEvent(eventId).then { _ in
                        OPassAPI.RedeemCode(eventId, token, completion)
                    }
                }
            }
        }
    }
}
