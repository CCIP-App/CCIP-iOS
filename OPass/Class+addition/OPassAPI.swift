//
//  OPassAPI.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/3/7.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import CoreLocation
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
    var DisplayName: DisplayName
    var Url: URL
}

struct EventInfo {
    var EventId: String
    var DisplayName: DisplayName
    var LogoUrl: URL
    var Publish: PublishDate
    var ServerBaseUrl: URL
    var SessionUrl: URL
    var Features: Features
    var CustomFeatures: Array<CustomFeatures>
}

struct EventShortInfo {
    var EventId: String
    var DisplayName: DisplayName
    var LogoUrl: URL
}

struct Programs: Codable {
    var Sessions: [ProgramSession]
    var Speakers: [ProgramSpeaker]
    var SessionTypes: [ProgramSessionType]
    var Rooms: [ProgramRoom]
    var Tags: [ProgramsTag]
    init(_ data: JSON) {
        self.Sessions = data["sessions"].arrayValue.map { obj -> ProgramSession in
            return ProgramSession(obj)
        }
        self.Speakers = data["speakers"].arrayValue.map { obj -> ProgramSpeaker in
            return ProgramSpeaker(obj)
        }
        self.SessionTypes = data["session_types"].arrayValue.map { obj -> ProgramSessionType in
            return ProgramSessionType(obj)
        }
        self.Rooms = data["rooms"].arrayValue.map { obj -> ProgramRoom in
            return ProgramRoom(obj)
        }
        self.Tags = data["tags"].arrayValue.map { obj -> ProgramsTag in
            return ProgramsTag(obj)
        }
    }

    func GetSession(_ sessionId: String) -> SessionInfo? {
        guard let session = (self.Sessions.filter { $0.Id == sessionId }.first) else { return nil }
        let type = self.SessionTypes.filter { $0.Id == session.Type }.first
        let speakers = self.Speakers.filter { session.Speakers.contains($0.Id) }
        let tags = self.Tags.filter { session.Tags.contains($0.Id) }
        return SessionInfo(session, type, speakers, tags)
    }

    func GetSessionIds(byDateString: String) -> Array<String> {
        return self.Sessions.filter { Constants.DateToDisplayDateString(Constants.DateFromString($0.Start)) == byDateString }.map { $0.Id }
    }
}

struct SessionInfo: Codable {
    var _sessionData: ProgramSession
    var Id: String
    var `Type`: String?
    var Room: String?
    var Broadcast: String?
    var Start: String
    var End: String
    var QA: String?
    var Slide: String?
    var Live: String?
    var Record: String?
    var Speakers: [ProgramSpeaker]
    var Tags: [ProgramsTag]
    init(_ data: ProgramSession, _ type: ProgramSessionType?, _ speakers: [ProgramSpeaker], _ tags: [ProgramsTag]) {
        self._sessionData = data
        self.Id = self._sessionData.Id
        self.Type = type?.Name
        self.Room = self._sessionData.Room
        self.Broadcast = self._sessionData.Broadcast
        self.Start = self._sessionData.Start
        self.End = self._sessionData.End
        self.QA = self._sessionData.QA
        self.Slide = self._sessionData.Slide
        self.Live = self._sessionData.Live
        self.Record = self._sessionData.Record
        self.Speakers = speakers
        self.Tags = tags
    }
    subscript(_ member: String) -> String {
        return self._sessionData[member]
    }
}

struct ProgramSession: Codable {
    var _sessionData: JSON
    var Id: String
    var `Type`: String?
    var Room: String?
    var Broadcast: String?
    var Start: String
    var End: String
    var QA: String?
    var Slide: String?
    var Live: String?
    var Record: String?
    var Speakers: [String?]
    var Tags: [String?]
    init(_ data: JSON) {
        self._sessionData = data
        self.Id = data["id"].stringValue
        self.Type = data["type"].stringValue
        self.Room = data["room"].string
        self.Broadcast = data["broadcast"].string
        self.Start = data["start"].stringValue
        self.End = data["end"].stringValue
        self.QA = data["qa"].string
        self.Slide = data["slide"].string
        self.Live = data["live"].string
        self.Record = data["record"].string
        self.Speakers = data["speakers"].arrayValue.map({ obj -> String? in
            return obj.string
        })
        self.Tags = data["tags"].arrayValue.map({ obj -> String? in
            return obj.string
        })
    }
    subscript(_ member: String) -> String {
        if member == "Id" {
            return Id
        }
        if member == "_sessionData" {
            return ""
        }
        let name = member.lowercased()
        switch name {
        case "title", "description":
            return _sessionData[AppDelegate.shortLangUI()].dictionaryValue[name]?.stringValue ?? ""
        default:
            return ""
        }
    }
}

struct ProgramSpeaker: Codable {
    var _speakerData: JSON
    var Id: String
    var Avatar: URL?
    init(_ data: JSON) {
        self._speakerData = data
        self.Id = data["id"].stringValue
        self.Avatar = data["avatar"].url
    }
    subscript(_ member: String) -> String {
        if member == "Id" {
            return Id
        }
        if member == "_speakerData" {
            return ""
        }
        let name = member.lowercased()
        switch name {
        case "name", "bio":
            return _speakerData[AppDelegate.shortLangUI()].dictionaryValue[name]?.stringValue ?? ""
        default:
            return ""
        }
    }
}

struct ProgramSessionType: Codable {
    var _sessionData: JSON
    var Id: String
    var Name: String {
        return _sessionData[AppDelegate.shortLangUI()].dictionaryValue["name"]?.stringValue ?? ""
    }
    init(_ data: JSON) {
        self._sessionData = data
        self.Id = data["id"].stringValue
    }
}

struct ProgramRoom: Codable {
    var _roomData: JSON
    var Id: String
    var Name: String {
        return _roomData[AppDelegate.shortLangUI()].dictionaryValue["name"]?.stringValue ?? ""
    }
    init(_ data: JSON) {
        self._roomData = data
        self.Id = data["id"].stringValue
    }
}

struct ProgramsTag: Codable {
    var _tagData: JSON
    var Id: String
    var Name: String {
        return _tagData[AppDelegate.shortLangUI()].dictionaryValue["name"]?.stringValue ?? ""
    }
    init(_ data: JSON) {
        self._tagData = data
        self.Id = data["id"].stringValue
    }
}

struct AnnouncementInfo {
    var DateTime: Date
    var MsgZh: String
    var MsgEn: String
    var URI: String
}

@objc class OPassAPI: NSObject {
    static var currentEvent: String = ""
    static var eventInfo: EventInfo? = nil
    private static var NextAcceptedBeaconScanMessageTime: Date {
        get {
            let ud = UserDefaults.standard;
            ud.synchronize()
            let lastMsgTime = ud.double(forKey: "NextAcceptedBeaconScanMessageTime")
            if lastMsgTime == 0 {
                return 0.minutes.fromNow
            } else {
                return Date.init(timeIntervalSince1970: lastMsgTime)
            }
        }
        set {
            let ud = UserDefaults.standard;
            ud.synchronize()
            ud.set(newValue.timeIntervalSince1970, forKey: "NextAcceptedBeaconScanMessageTime")
            ud.synchronize()
        }
    }

    private static func RegisteringNotification(
        id: String,
        title: String,
        content: String,
        time: Date,
        isDisable: Bool = false
    ) {
        let notification = DLNotification(
            identifier: id,
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
        NSLog("Notification Registered: \(notification)")
    }

    static func RangeBeacon(_ beacon: CLBeacon? = nil) {
        if 1.seconds.fromNow.isBeforeDate(OPassAPI.NextAcceptedBeaconScanMessageTime, granularity: .minute) {
            return
        } else {
            OPassAPI.NextAcceptedBeaconScanMessageTime = 1.minutes.fromNow
        }
        let beaconWelcome = "BeaconWelcomeMessage_\(beacon == nil ? "Out" : "In")"
        let time = 30.seconds.fromNow
        if (beacon == nil) {
//            OPassAPI.RegisteringNotification(
//                id: beaconWelcome,
//                title: NSLocalizedString("\(beaconWelcome)_Title", comment: ""),
//                content: NSLocalizedString("\(beaconWelcome)_Content", comment: ""),
//                time: time
//            )
        } else {
            OPassAPI.GetCurrentStatus() { (success: Bool, obj: Any?, error: Error) in
                if success && obj != nil {
                    for scenario in JSON(obj!)["scenarios"].arrayValue {
                        let id = scenario["id"].stringValue
                        if id.hasPrefix("day") && id.hasSuffix("checkin") && scenario["used"].double == nil {
                            let available = Date.init(timeIntervalSince1970: scenario["available_time"].doubleValue)
                            let expire = Date.init(timeIntervalSince1970: scenario["expire_time"].doubleValue)
                            if 0.seconds.fromNow.isInRange(date: available, and: expire, orEqual: true, granularity: .day) {
                                OPassAPI.RegisteringNotification(
                                    id: beaconWelcome,
                                    title: NSLocalizedString("\(beaconWelcome)_Title", comment: ""),
                                    content: NSLocalizedString("\(beaconWelcome)_Content", comment: ""),
                                    time: time
                                )
                                OPassAPI.NextAcceptedBeaconScanMessageTime = 30.minutes.fromNow
                            }
                        }
                    }
                }
            }
        }
    }

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
                    let displayName = DisplayName(_displayData: i["display_name"])
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
                let displayName = DisplayName(_displayData: info["display_name"])
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
                    let ftDisplayName = DisplayName(_displayData: ft["display_name"])
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
                            completion?(true, json.dictionaryObject, OPassSuccessError)
                        } else {
                            completion?(false, json.dictionaryObject, NSError(domain: "OPass Redeem Code Invalid", code: 3, userInfo: nil))
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
                if obj != nil {
                    switch String(describing: type(of: obj!)) {
                    case OPassNonSuccessDataResponse.className:
                        let sr = obj as! OPassNonSuccessDataResponse
                        completion?(false, sr, NSError(domain: "OPass Current Not in Event or Not a Valid Token", code: 4, userInfo: nil))
                    default:
                        let json = JSON(obj!)
                        if json["user_id"].stringValue != "" {
                            completion?(true, json.dictionaryObject, OPassSuccessError)
                        } else {
                            completion?(false, json.dictionaryObject, NSError(domain: "OPass Current Not in Event or Not a Valid Token", code: 3, userInfo: nil))
                        }
                    }
                } else {
                    completion?(false, obj, NSError(domain: "OPass Current Not in Event or Not a Valid Token", code: 2, userInfo: nil))
                }
            }
        } else {
            completion?(false, nil, NSError(domain: "OPass Current Not in Event or Not a Valid Token", code: 1, userInfo: nil))
        }
    }

    @objc static func GetSessionData(forEvent event: String, onCompletion completion: OPassCompletionCallback) {
        if event.count > 0 {
            OPassAPI.InitializeRequest(Constants.URL_SESSION) { retryCount, retryMax, error, responsed in
                completion?(false, nil, error)
            }.then { (obj: Any?) -> Void in
                if obj != nil {
                    let prog = Programs(JSON(obj!))
                    completion?(true, prog, OPassSuccessError)
                } else {
                    completion?(false, obj, NSError(domain: "OPass Session can not get by return unexcepted response", code: 2, userInfo: nil))
                }
            }
        } else {
            completion?(false, nil, NSError(domain: "OPass Session can not get, because event was not set", code: 1, userInfo: nil))
        }
    }

    private static func GetFavoritesStoreKey(
        _ event: String,
        _ token: String
        ) -> String {
        return "\(event)|\(token)|favorites"
    }

    static func GetFavoritesList(
        forEvent event: String,
        withToken token: String
        ) -> [String] {
        let key = OPassAPI.GetFavoritesStoreKey(event, token)
        let ud = UserDefaults.standard
        ud.register(defaults: [key: Array<String>()])
        ud.synchronize()

        return ud.stringArray(forKey: key)!
    }

    static func PutFavoritesList(
        forEvent event: String,
        withToken token: String,
        byNewList: [String]
    ) {
        let key = OPassAPI.GetFavoritesStoreKey(event, token)
        let ud = UserDefaults.standard
        ud.set(byNewList, forKey: key)
        ud.synchronize()
    }

    static func CheckFavoriteState(
        forEvent event: String,
        withToken token: String,
        toSession session: String
    ) -> Bool {
        let favList = OPassAPI.GetFavoritesList(forEvent: event, withToken: token)
        return favList.contains(session)
    }

    static func TriggerFavoriteSession(
        forEvent event: String,
        withToken token: String,
        toSession session: String
    ) {
        let title = ""
        let content = ""
        let time = 10.seconds.fromNow
        var favList = OPassAPI.GetFavoritesList(forEvent: event, withToken: token)
        let isDisable = favList.contains(session)
        OPassAPI.RegisteringNotification(
            id: "\(OPassAPI.GetFavoritesStoreKey(event, token))|\(session)",
            title: title,
            content: content,
            time: time,
            isDisable: isDisable
        )
        if !isDisable {
            favList += [ session ]
        } else {
            favList = favList.filter { $0 != session }
        }
        OPassAPI.PutFavoritesList(forEvent: event, withToken: token, byNewList: favList)
    }

    static func GetAnnouncement(forEvent event: String, onCompletion completion: OPassCompletionCallback) {
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
