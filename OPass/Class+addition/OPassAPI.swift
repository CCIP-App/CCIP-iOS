//
//  OPassAPI.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/3/7.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import then
import AFNetworking
import SwiftyJSON
import SwiftDate
import DLLocalNotifications

internal typealias OPassErrorCallback = (
        (_ retryCount: UInt, _ retryMax: UInt, _ error: Error, _ responsed: URLResponse?) -> Void
    )?
internal typealias OPassCompletionCallback = (
        (_ success: Bool, _ data: Any?, _ error: Error) -> Void
    )?

let OPassSuccessError = NSError(domain: "", code: 0, userInfo: nil)

@objc class OPassNonSuccessDataResponse: NSObject {
    @objc public var Response: HTTPURLResponse?
    @objc public var Data: Data?
    @objc public var Obj: NSObject
    public var Json: JSON?
    init(_ response: HTTPURLResponse?, _ data: Data?, _ json: JSON?) {
        self.Response = response
        self.Data = data
        self.Json = json
        self.Obj = json?.object as! NSObject
    }
}

struct DisplayName {
    var _displayData: JSON
    var zh: String
    var en: String
    func Get(lang: String) -> String {
        return _displayData[lang].stringValue
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
    var DisplayName: DisplayName
    var Url: URL
}

struct EventInfo {
    var EventId: String
    var DisplayName: DisplayName
    var LogoUrl: URL
    var Publish: PublishDate
    var ServerBaseUrl: URL
    var ScheduleUrl: URL
    var Features: Features
    var CustomFeatures: Array<CustomFeatures>
}

struct EventShortInfo {
    var EventId: String
    var DisplayName: DisplayName
    var LogoUrl: URL
}

struct SpeakerInfo {
    var Id: String
    var Avatar: URL?
    var Title: String
    var Info: String
    var Name: DisplayName
    var Bio: DisplayName
}

struct TagInfo {
    var _tagData: JSON
    var Id: String
    var zh: String
    func Get(lang: String) -> String {
        return _tagData[lang].stringValue
    }
}

struct ScheduleInfo {
    var Id: String
    var ScheduleType: String
    var Room: String
    var Broadcast: [String]?
    var Start: Date
    var End: Date
    var QA: String
    var Slide: String
    var Title: DisplayName
    var Description: DisplayName
    var Speakers: [SpeakerInfo]
    var Tag: [TagInfo]
}

@objc class OPassAPI: NSObject {
    static var currentEvent: String = ""
    static var eventInfo: EventInfo? = nil
    static func InitializeRequest(_ url: String, maxRetry: UInt = 10, _ onceErrorCallback: OPassErrorCallback) -> Promise<Any?> {
        var retryCount: UInt = 0
        let e = Promise<Any?> { resolve, reject in
            let manager = AFHTTPSessionManager.init()
            manager.requestSerializer.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            manager.requestSerializer.timeoutInterval = 5
            manager.get(url, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
                NSLog("JSON: \(JSONSerialization.stringify(responseObject as Any)!)")
                if (responseObject != nil) {
                    resolve(responseObject)
                }
            }) { (operation: URLSessionDataTask?, error: Error) in
                NSLog("Error: \(error)")
                 let err = error as NSError
                // let systemMsg = err.userInfo["NSLocalizedDescription"] ?? ""
                let response = operation?.response as? HTTPURLResponse
                let data = err.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? Data
                if (response != nil) {
                    onceErrorCallback?(retryCount, maxRetry, error, response)
                    resolve(OPassNonSuccessDataResponse(response, data, JSON(data as Any)))
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        retryCount+=1
                        onceErrorCallback?(retryCount, maxRetry, error, response)
                        reject(error)
                    })
                }
            }
            }
        if maxRetry > 0 {
            return e.retry(maxRetry)
        } else {
            return e
        }
    }

    static func GetEvents(_ onceErrorCallback: OPassErrorCallback) -> Promise<Array<EventShortInfo>> {
        return OPassAPI.InitializeRequest("https://portal.opass.app/events/", onceErrorCallback)
            .then({ (infoObj: Any) -> Array<EventShortInfo> in
                let info = JSON(infoObj).arrayValue
                var infos = Array<EventShortInfo>()
                for i in info {
                    let eventId = i["event_id"].stringValue
                    let dn = i["display_name"]
                    let dnzh = dn["zh"].stringValue
                    let dnen = dn["en"].stringValue
                    let displayName = DisplayName(_displayData: dn, zh: dnzh, en: dnen)
                    let logoUrl = i["logo_url"].url!
                    let e = EventShortInfo(EventId: eventId, DisplayName: displayName, LogoUrl: logoUrl)
                    infos.append(e)
                }
                return infos
            })
    }

    static func SetEvent(_ eventId: String, _ onceErrorCallback: OPassErrorCallback) -> Promise<EventInfo> {
        return OPassAPI.InitializeRequest("https://portal.opass.app/events/\(eventId)/", onceErrorCallback)
            .then { (infoObj: Any) -> EventInfo in
                let info = JSON(infoObj)
                let eventId = info["event_id"].stringValue
                let dn = info["display_name"]
                let dnzh = dn["zh"].stringValue
                let dnen = dn["en"].stringValue
                let displayName = DisplayName(_displayData: dn, zh: dnzh, en: dnen)
                let logoUrl = info["logo_url"].url!
                let pub = info["publish"]
                let pubStart = Date.init(seconds: pub["start"].stringValue.toDate(style: .iso(.init()))!.timeIntervalSince1970)
                let pubEnd = Date.init(seconds: pub["end"].stringValue.toDate(style: .iso(.init()))!.timeIntervalSince1970)
                let publish = PublishDate(Start: pubStart, End: pubEnd)
                let serverUrl = info["server_base_url"].url!
                let scheduleUrl = info["schedule_url"].url!
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
                    let ftdn = ft["display_name"]
                    let ftdnzh = dn["zh"].stringValue
                    let ftdnen = dn["en"].stringValue
                    let ftDisplayName = DisplayName(_displayData: ftdn, zh: ftdnzh, en: ftdnen)
                    let ftUrl = ft["url"].url!
                    let f = CustomFeatures(IconUrl: ftIcon, DisplayName: ftDisplayName, Url: ftUrl)
                    customFeatures.append(f)
                }
                eventInfo = EventInfo(EventId: eventId, DisplayName: displayName, LogoUrl: logoUrl, Publish: publish, ServerBaseUrl: serverUrl, ScheduleUrl: scheduleUrl, Features: features, CustomFeatures: customFeatures)
                currentEvent = JSONSerialization.stringify(infoObj as Any)!
                return eventInfo!
        }
    }

    @objc static func CleanupEvents() {
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

    @objc static func RedeemCode(forEvent: String, withToken: String, completion: OPassCompletionCallback) {
        var event = forEvent
        if event == "" {
            event = OPassAPI.currentEvent
        }
        let token = withToken.trim()
        let allowedCharacters = NSMutableCharacterSet.init(charactersIn: "-_")
        allowedCharacters.formUnion(with: NSCharacterSet.alphanumerics)
        let nonAllowedCharacters = allowedCharacters.inverted
        if (token.count != 0 && token.rangeOfCharacter(from: nonAllowedCharacters) == nil) {
            OPassAPI.InitializeRequest(Constants.URL_LANDING(token: token)) { retryCount, retryMax, error, responsed in
                completion?(false, nil, error)
            }.then { (obj: Any?) -> Void in
                if obj != nil {
                    switch String(describing: type(of: obj!)) {
                    case OPassNonSuccessDataResponse.className:
                        let sr = obj as! OPassNonSuccessDataResponse
                        let response = sr.Response!
                        switch response.statusCode {
                        case 400:
                            completion?(false, sr, NSError(domain: "OPass Redeem Code Invalid", code: 4, userInfo: nil))
                            break
                        default:
                            completion?(false, sr, NSError(domain: "OPass Redeem Code Invalid", code: 4, userInfo: nil))
                        }
                        break
                    default:
                        let json = JSON(obj!)
                        if json["nickname"].stringValue != "" {
                            AppDelegate.setLoginSession(true)
                            AppDelegate.setAccessToken(token)
                            AppDelegate.delegateInstance().checkinView.reloadCard()
                            completion?(true, json, OPassSuccessError)
                        } else {
                            completion?(false, json, NSError(domain: "OPass Redeem Code Invalid", code: 3, userInfo: nil))
                        }
                    }
                } else {
                    completion?(false, obj, NSError(domain: "OPass Redeem Code Invalid", code: 2, userInfo: nil))
                }
            }
        } else {
            completion?(false, nil, NSError(domain: "OPass Redeem Code Invalid", code: 1, userInfo: nil))
        }
    }

    @objc static func GetCurrentStatus(_ completion: OPassCompletionCallback) {
        let event = OPassAPI.currentEvent
        let token = Constants.AccessToken
        if event.count > 0 && token.count > 0 {
            OPassAPI.InitializeRequest(Constants.URL_STATUS(token: token)) { retryCount, retryMax, error, responsed in
                completion?(false, nil, error)
            }.then { (obj: Any?) -> Void in
                completion?(true, obj, OPassSuccessError)
            }
        } else {
            completion?(false, nil, NSError(domain: "OPass Current Not in Event and No Valid Token", code: 1, userInfo: nil))
        }
    }

    @objc static func GetScheduleData(forEvent event: String, onCompletion completion: OPassCompletionCallback) {
        if event.count > 0 {
            OPassAPI.InitializeRequest(Constants.URL_SCHEDULE) { retryCount, retryMax, error, responsed in
                completion?(false, nil, error)
            }.then { (obj: Any?) -> Void in
                if obj != nil {
                    var schedules = [ScheduleInfo]()
                    for sch in JSON(obj!).arrayValue {
                        let zh = sch["zh"]
                        let en = sch["en"]
                        let title = DisplayName(_displayData: JSON(parseJSON: ""),zh: zh["title"].stringValue, en: en["title"].stringValue)
                        let description = DisplayName(_displayData: JSON(parseJSON: ""),zh: zh["description"].stringValue, en: en["description"].stringValue)
                        var speakers = [SpeakerInfo]()
                        for s in sch["speakers"].arrayValue {
                            let szh = s["zh"]
                            let sen = s["en"]
                            let name = DisplayName(_displayData: JSON(parseJSON: ""), zh: szh["name"].stringValue, en: sen["name"].stringValue)
                            let bio = DisplayName(_displayData: JSON(parseJSON: ""), zh: szh["bio"].stringValue, en: sen["bio"].stringValue)
                            let speaker = SpeakerInfo(
                                Id: s["id"].stringValue,
                                Avatar: s["avatar"].url,
                                Title: s["title"].stringValue,
                                Info: s["info"].stringValue,
                                Name: name,
                                Bio: bio
                            )
                            speakers.append(speaker)
                        }
                        var tags = [TagInfo]()
                        for t in sch["tag"].arrayValue {
                            let tag = TagInfo(
                                _tagData: t,
                                Id: t["id"].stringValue,
                                zh: t["zh"].stringValue
                            )
                            tags.append(tag)
                        }
                        let schedule = ScheduleInfo(
                            Id: sch["id"].stringValue,
                            ScheduleType: sch["type"].stringValue,
                            Room: sch["room"].stringValue,
                            Broadcast: sch["broadcast"].arrayObject as? [String],
                            Start: Date.init(seconds: sch["start"].stringValue.toDate()!.timeIntervalSince1970),
                            End: Date.init(seconds: sch["end"].stringValue.toDate()!.timeIntervalSince1970),
                            QA: sch["qa"].stringValue,
                            Slide: sch["slide"].stringValue,
                            Title: title,
                            Description: description,
                            Speakers: speakers,
                            Tag: tags
                        )
                        schedules.append(schedule)
                    }
                    completion?(true, schedules, OPassSuccessError)
                } else {
                    completion?(false, obj, NSError(domain: "OPass Schedule can not get by return unexcepted response", code: 2, userInfo: nil))
                }
            }
        } else {
            completion?(false, nil, NSError(domain: "OPass Schedule can not get, because event was not set", code: 1, userInfo: nil))
        }
    }

    private static func GetFavoritesStoreKey(
        _ event: String,
        _ token: String
        ) -> String {
        return "\(event)|\(token)|favorites"
    }

    private static func GetFavoritesStoreKey(
        _ event: String,
        _ token: String,
        _ schedule: String
        ) -> String {
        return "\(OPassAPI.GetFavoritesStoreKey(event, token))|\(schedule)"
    }

    @objc static func GetFavoritesList(
        forEvent: String,
        withToken: String
        ) -> [String] {
        let key = OPassAPI.GetFavoritesStoreKey(forEvent, withToken)
        let ud = UserDefaults.standard
        ud.register(defaults: [key: Array<String>()])
        ud.synchronize()

        return ud.stringArray(forKey: key)!
    }

    @objc static func RegisteringFavoriteSchedule(
        forEvent event: String,
        withToken token: String,
        toSchedule schedule: String,
        isDisable: Bool,
        completion: OPassCompletionCallback
    ) {
        let schedule = ""
        let title = ""
        let content = ""
        let time = 10.seconds.fromNow
        let notification = DLNotification(
            identifier: OPassAPI.GetFavoritesStoreKey(event, token, schedule),
            alertTitle: title,
            alertBody: content,
            date: time,
            repeats: .none,
            soundName: ""
        )
        let scheduler = DLNotificationScheduler()
        scheduler.scheduleNotification(notification: notification)
        scheduler.scheduleAllNotifications()
        if isDisable {
            scheduler.cancelNotification(notification: notification)
            scheduler.scheduleAllNotifications()
        }
        NSLog("\(notification)")
    }
}
