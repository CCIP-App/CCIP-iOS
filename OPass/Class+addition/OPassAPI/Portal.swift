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

struct EventDisplayName: Codable {
    var _displayData: JSON
    init(_ data: JSON) {
        self._displayData = data
    }
    subscript(_ member: String) -> String {
        if member == "_displayData" {
            return ""
        }
        return _displayData[member].stringValue
    }
}

struct PublishDate {
    var Start: Date
    var End: Date
}

struct Features {
    var IRC: URL?
    var Telegram: URL?
    var Puzzle: URL?
    var Staffs: URL?
    var Venue: URL?
    var Sponsors: URL?
    var Partners: URL?
}

struct CustomFeatures {
    var IconUrl: URL?
    var DisplayName: EventDisplayName
    var Url: URL
}

struct EventInfo {
    var EventId: String
    var DisplayName: EventDisplayName
    var LogoUrl: URL
    var Publish: PublishDate
    var ServerBaseUrl: URL
    var SessionUrl: URL
    var Features: Features
    var CustomFeatures: Array<CustomFeatures>
}

struct EventShortInfo: Codable {
    var EventId: String
    var DisplayName: EventDisplayName
    var LogoUrl: URL
    init(_ data: JSON) {
        self.EventId = data["event_id"].stringValue
        self.DisplayName = EventDisplayName(data["display_name"])
        self.LogoUrl = data["logo_url"].url!
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
                let info = JSON(infoObj)
                let eventId = info["event_id"].stringValue
                let displayName = EventDisplayName(info["display_name"])
                let logoUrl = info["logo_url"].url!
                let pub = info["publish"]
                let pubStart = Date.init(seconds: pub["start"].stringValue.toDate(style: .iso(.init()))!.timeIntervalSince1970)
                let pubEnd = Date.init(seconds: pub["end"].stringValue.toDate(style: .iso(.init()))!.timeIntervalSince1970)
                let publish = PublishDate(Start: pubStart, End: pubEnd)
                let serverUrl = info["server_base_url"].url!
                let sessionUrl = info["schedule_url"].url!
                let fts = info["features"]
                let irc = fts["irc"].url
                let telegram = fts["telegram"].url
                let puzzle = fts["puzzle"].url
                let staffs = fts["staffs"].url
                let venue = fts["venus"].url
                let sponsors = fts["sponsors"].url
                let partners = fts["partners"].url
                let features = Features(IRC: irc, Telegram: telegram, Puzzle: puzzle, Staffs: staffs, Venue: venue, Sponsors: sponsors, Partners: partners)
                var customFeatures = Array<CustomFeatures>()
                let cf = info["custom_features"].arrayValue
                for ft in cf {
                    let ftIcon = ft["icon"].url
                    let ftDisplayName = EventDisplayName(ft["display_name"])
                    let ftUrl = ft["url"].url!
                    let f = CustomFeatures(IconUrl: ftIcon, DisplayName: ftDisplayName, Url: ftUrl)
                    customFeatures.append(f)
                }
                eventInfo = EventInfo(EventId: eventId, DisplayName: displayName, LogoUrl: logoUrl, Publish: publish, ServerBaseUrl: serverUrl, SessionUrl: sessionUrl, Features: features, CustomFeatures: customFeatures)
                currentEvent = JSONSerialization.stringify(infoObj as Any)!
                return eventInfo!
        }
    }

    static func CleanupEvents() {
        eventInfo = nil
        currentEvent = ""
    }

    @objc static func DoLogin(byEventId eventId: String, withToken token: String, onCompletion completion: OPassCompletionCallback) {
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
                            AppDelegate.setLoginSession(false)
                            AppDelegate.setAccessToken("")
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
                    OPassAPI.RedeemCode(forEvent: eventId, withToken: token, completion: completion)
                }
            }
        }
    }
}
