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
import Nuke
import SafariServices

@objc enum fontAwesomeStyle: Int {
    case solid
    case regular
    case brands
}

extension Constants {
    @objc public static func SendFib(
        _ _name: Any,
        WithEvents _events: Any? = nil,
        Func _func: String = #function,
        File _file: String = #file,
        Line _line: Int = #line,
        Col _col: Int = #column
    ) {
        let __file = _file.replacingOccurrences(of: Constants.sourceRoot(), with: "")

        NSLog("Send FIB: \(_name)(\(String(describing: _events))) @ \(_func)\t\(__file):\(_line):\(_col)");

        //    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        if ((_name as? String) != "" && _events == nil) {
            //        [tracker set:kGAIScreenName
            //               value:_name];
            Analytics.setScreenName(_name as? String, screenClass: _func)
        }
        if (_events != nil) {
            Analytics.logEvent(_name as! String, parameters: _events as? [String : Any])
        }
    }
    private static var iBeacon: Dictionary<String, String> {
        return AppDelegate.appConfig("iBeacon") as! Dictionary<String, String>
    }
    @objc public static var beaconUUID: String {
        return self.iBeacon["UUID"]!
    }
    @objc public static var beaconID: String {
        return self.iBeacon["ID"]!
    }
    @objc public static var HasSetEvent: Bool {
        return OPassAPI.currentEvent.count > 0
    }
    @objc public static var EventId: String {
        return OPassAPI.eventInfo?.EventId ?? ""
    }
    @objc public static var AccessToken: String {
        return AppDelegate.accessToken()
    }
    @objc public static var AccessTokenSHA1: String {
        return AppDelegate.accessTokenSHA1()
    }
    @objc public static var URL_SERVER_BASE: String {
        return OPassAPI.eventInfo?.ServerBaseUrl.absoluteString ?? ""
    }
    @objc public static func URL_LANDING(token: String) -> String {
        return Constants.URL_SERVER_BASE.appending("/landing?token=\(token)")
    }
    @objc public static func URL_STATUS(token: String) -> String {
        return Constants.URL_SERVER_BASE.appending("/status?token=\(token)")
    }
    @objc public static func URL_USE(token: String, scenario: String) -> String {
        return Constants.URL_SERVER_BASE.appending("/use/\(scenario)?token=\(token)")
    }
    public static var URL_ANNOUNCEMENT: String {
        return Constants.URL_SERVER_BASE.appending("/announcement")
    }
    private static func OPassURL(_ url: String) -> String {
        let opassTime = "__opass=\(0.seconds.fromNow.timeIntervalSince1970)"
        var opassUrl = url.replacingOccurrences(of: "__opass=##random##", with: opassTime)
        if (url == opassUrl) {
            if url.contains("?") {
                opassUrl = "\(opassUrl)&\(opassTime)"
            } else {
                opassUrl = "\(opassUrl)?\(opassTime)"
            }
        }
        NSLog("Add OPass timestamp: \(url) -> \(opassUrl)");
        return opassUrl
    }
    @objc public static var URL_LOGO_IMG: String {
        return OPassAPI.eventInfo?.LogoUrl.absoluteString ?? ""
    }
    @objc public static var URL_SESSION: String {
        return Constants.OPassURL(OPassAPI.eventInfo?.SessionUrl.absoluteString ?? "")
    }
    @objc public static var URL_LOG_BOT: String {
        return Constants.OPassURL(OPassAPI.eventInfo?.Features.IRC!.absoluteString ?? "")
    }
    @objc public static var URL_VENUE: String {
        return Constants.OPassURL(OPassAPI.eventInfo?.Features.Venue!.absoluteString ?? "")
    }
    @objc public static var URL_TELEGRAM_GROUP: String {
        return Constants.OPassURL(OPassAPI.eventInfo?.Features.Telegram!.absoluteString ?? "")
    }
    @objc public static var URL_STAFF_WEB: String {
        return Constants.OPassURL(OPassAPI.eventInfo?.Features.Staffs!.absoluteString ?? "")
    }
    @objc public static var URL_SPONSOR_WEB: String {
        return Constants.OPassURL(OPassAPI.eventInfo?.Features.Sponsors!.absoluteString ?? "")
    }
    @objc public static var URL_PARTNERS_WEB: String {
        return Constants.OPassURL(OPassAPI.eventInfo?.Features.Partners!.absoluteString ?? "")
    }
    @objc public static func URL_GAME(token: String) -> String {
        var url = OPassAPI.eventInfo?.Features.Puzzle!.absoluteString ?? ""
        if url.count > 0 {
            url = url + token
        }
        return Constants.OPassURL(url)
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
    @objc public static func OpenInAppSafari(forPath url: String) {
        Constants.OpenInAppSafari(forURL: URL.init(string: url)!)
    }
    @objc public static func OpenInAppSafari(forURL url: URL) {
        if (SFSafariViewController.className != "" && (url.scheme?.contains("http"))!) {
            // Open in SFSafariViewController
            let safariViewController = SFSafariViewController.init(url: url)

            // SFSafariViewController Toolbar TintColor
            // [safariViewController.view setTintColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
            // or http://stackoverflow.com/a/35524808/1751900

            // ProgressBar Color Not Found
            // ...

            UIApplication.getMostTopPresentedViewController()!.present(safariViewController, animated: true, completion: nil)
        } else {
            // Open in Mobile Safari
            UIApplication.shared.open(url, options: [:]) { (success: Bool) in
                if !success {
                    NSLog("Failed to open url: \(String(describing: url))")
                }
            }
        }
    }
    @objc static func LoadDevLogoTo(view: FBShimmeringView) {
        let isDevMode = AppDelegate.isDevMode()
        let setDevLogo = { (resp: ImageResponse?) in
            let image = resp?.image
            if image != nil {
                var img = image!
                if isDevMode {
                    img = img.imageWithColor(AppDelegate.appConfigColor("DevelopingLogoMaskColor"))
                }
                if resp != nil {
                    if view.contentView == nil {
                        view.contentView = UIImageView.init(image: img)
                    } else {
                        (view.contentView as! UIImageView).image = img
                    }
                    view.contentView.contentMode = .scaleAspectFit
                }
            }
        }
        ImagePipeline.shared.loadImage(
            with: URL.init(string: Constants.URL_LOGO_IMG)!,
            progress: { response, _, _ in
                setDevLogo(response)
            },
            completion: { response, _ in
                setDevLogo(response)
            }
        )
        view.shimmeringSpeed = 115
        view.isShimmering = isDevMode
    }
    @objc static func LoadInto(view: UIImageView, forURL url: URL, withPlaceholder placeholder: UIImage) {
        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions(
                placeholder: placeholder,
                transition: .fadeIn(duration: 0.33)
            ),
            into: view
        )
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
    @objc static func DateFromUnix(_ unixInt: Int) -> Date {
        return Date(seconds: TimeInterval(unixInt), region: Region.local)
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
    @objc static func DateToDisplayDateAndTimeString(_ date: Date) -> String {
        let local = Region(calendar: Calendars.republicOfChina, zone: Zones.asiaTaipei, locale: Locales.chineseTaiwan)
        return DateInRegion(date, region: local).toFormat(AppDelegate.appConfig("DisplayDateTimeFormat") as! String)
    }

    @objc public static var INIT_SESSION_DETAIL_VIEW_STORYBOARD_ID: String {
        return "SessionDetail"
    }
    @objc public static var SESSION_DETAIL_VIEW_STORYBOARD_ID: String {
        return "ShowSessionDetail"
    }
    @objc public static var SESSION_FAV_KEY: String {
        return "favoriteSession"
    }
    @objc public static var SESSION_CACHE_CLEAR: String {
        return "ClearSessionContentCache"
    }
    @objc public static var SESSION_CACHE_KEY: String {
        return "SessionContentCache"
    }

    // MARK: - Math

    @objc public static func NEAR_ZERO(_ A: Double, _ B: Double) -> Double {
        return min(abs(A), abs(B)) == abs(A) ? A : B
    }
}
