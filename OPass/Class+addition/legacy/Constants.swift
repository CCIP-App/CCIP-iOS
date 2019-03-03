//
//  Constants.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/5.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation
import FontAwesome_swift
import SwiftDate
import then
import AFNetworking
import SwiftyJSON
import SDWebImage

@objc enum fontAwesomeStyle: Int {
    case solid
    case regular
    case brands
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

extension Constants {
    static var currentEvent: String = ""
    static var eventInfo: EventInfo? = nil
    @objc public static var HasSetEvent: Bool {
        return currentEvent.count > 0
    }
    @objc public static var AccessToken: String {
        return AppDelegate.accessToken()
    }
    @objc public static var AccessTokenSHA1: String {
        return AppDelegate.accessTokenSHA1()
    }
    @objc public static var URL_SERVER_BASE: String {
        return eventInfo?.ServerBaseUrl.absoluteString ?? ""
    }
    @objc public static var URL_LOG_BOT: String {
        return eventInfo?.Features.IRC!.absoluteString ?? ""
    };
    @objc public static var URL_VENUE: String {
        return eventInfo?.Features.Venue!.absoluteString ?? ""
    }
    @objc public static var URL_TELEGRAM_GROUP: String {
        return eventInfo?.Features.Telegram!.absoluteString ?? ""
    }
    @objc public static var URL_STAFF_WEB: String {
        return eventInfo?.Features.Staffs!.absoluteString ?? ""
    }
    @objc public static var URL_SPONSOR_WEB: String {
        return eventInfo?.Features.Sponsors!.absoluteString ?? ""
    }
    @objc public static var URL_PARTNERS_WEB: String {
        return eventInfo?.Features.Partners!.absoluteString ?? ""
    }
    @objc public static var URL_GAME: String {
        return eventInfo?.Features.Puzzle!.absoluteString ?? ""
    }
    @objc public static func GitHubRepo(_ repo: String) -> String {
        return String(format: "https://github.com/\(repo)")
    }
    @objc public static func GitHubAvatar(_ user: String) -> String {
        return String(format: "https://avatars.githubusercontent.com/\(user)?s=86&v=3")
    }
    @objc public static func GravatarAvatar(_ hash: String) -> String {
        return String(format: "https://www.gravatar.com/avatar/\(hash)?s=86&\(hash.count > 0 ? "r=x" : "f=y&d=mm")")
    }
    @objc static func ConfLogo() -> UIImage {
        let ig = Promise<UIImage> { resolve, reject in
            let option: SDWebImageOptions = [ .allowInvalidSSLCertificates, .continueInBackground, .highPriority, .queryDiskSync, .retryFailed ]
            UIImageView.init().sd_setImage(with: eventInfo?.LogoUrl, placeholderImage: nil, options: option, completed: {
                (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                resolve(image!)
            })
        }
        let img = try! await(ig)
        return img
    }
    @objc static func AssertImage(name: String, InBundleName: String) -> UIImage? {
        return AssertImage(InBundleName, name)
    }
    @objc public static func AssertImage(_ bundleName: String, _ imageName: String ) -> UIImage? {
        let bundlePath = Bundle.main.bundlePath.appendingPathComponent("\(bundleName).bundle")
        let bundle = Bundle.init(path: bundlePath)!
        return UIImage.init(named: imageName, in: bundle, compatibleWith: nil)
    }
    @objc static func fontAwesome(code: String) -> String? {
        return String.fontAwesomeIcon(code: code)
    }
    @objc static func fontOfAwesome(withSize: CGFloat, inStyle: fontAwesomeStyle) -> UIFont {
        var style: FontAwesomeStyle = FontAwesomeStyle.regular
        switch inStyle {
            case .brands:
                style = .brands
            case .regular:
                style = .regular
            case .solid:
                style = .solid
        }
        return UIFont.fontAwesome(ofSize: withSize, style: style)
    }
    @objc static var tintColor : UIColor {
        return UIView().tintColor!
    }
    @objc static func GetScheduleTypeName(_ namePrefix: Any) -> String {
        // TODO: mapping from define file from event config
        return namePrefix as? String ?? ""
    }
    @objc static func DateFromString(_ dateString: String) -> Date {
        let local = Region(calendar: Calendars.republicOfChina, zone: Zones.asiaTaipei, locale: Locales.chineseTaiwan)
        let isodate = dateString.toISODate(region: local)?.timeIntervalSince1970 ?? 0
        let date = Date(seconds: isodate, region: Region.local)
        return date
    }
    @objc static func DateToDisplayDateString(_ date: Date) -> String {
        let local = Region(calendar: Calendars.republicOfChina, zone: Zones.asiaTaipei, locale: Locales.chineseTaiwan)
        return DateInRegion(date, region: local).toFormat(AppDelegate.appConfig("DisplayDateFormat") as! String)
    }
    @objc static func DateToDisplayTimeString(_ date: Date) -> String {
        let local = Region(calendar: Calendars.republicOfChina, zone: Zones.asiaTaipei, locale: Locales.chineseTaiwan)
        return DateInRegion(date, region: local).toFormat(AppDelegate.appConfig("DisplayTimeFormat") as! String)
    }
    @objc static func DateToDisplayDateTimeString(_ date: Date) -> String {
        let local = Region(calendar: Calendars.republicOfChina, zone: Zones.asiaTaipei, locale: Locales.chineseTaiwan)
        let format = String.init(format: "%@ %@", AppDelegate.appConfig("DisplayDateFormat") as! String, AppDelegate.appConfig("DisplayTimeFormat") as! String)
        return DateInRegion(date, region: local).toFormat(format)
    }
    static func GetEvents() -> Promise<Array<EventShortInfo>> {
        return Promise { resolve, reject in
            let manager = AFHTTPSessionManager.init()
            manager.get("https://portal.opass.app/events/", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
                NSLog("JSON: \(JSONSerialization.stringify(responseObject as Any)!)")
                if (responseObject != nil) {
                    resolve(responseObject!)
                }
            }) { (operation: URLSessionDataTask?, error: Error) in
                NSLog("Error: \(error)")
                reject(error)
            }
        }.then({ (infoObj: Any) -> Array<EventShortInfo> in
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
    static func SetEvent(_ eventId: String) -> Promise<EventInfo> {
        return Promise { resolve, reject in
            let manager = AFHTTPSessionManager.init()
            manager.completionQueue = DispatchQueue(label: "SetEvent")
            manager.get("https://portal.opass.app/events/\(eventId)/", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
                NSLog("JSON: \(JSONSerialization.stringify(responseObject as Any)!)")
                if (responseObject != nil) {
                    resolve(responseObject!)
                }
            }) { (operation: URLSessionDataTask?, error: Error) in
                NSLog("Error: \(error)")
                reject(error)
            }
        }.then { (infoObj: Any) -> EventInfo in
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
}
