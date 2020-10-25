//
//  Constants.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/5.
//  2018 OPass.
//

import Foundation
import FontAwesome_swift
import SwiftDate
import Then
import AFNetworking
import SwiftyJSON
import Nuke
import SafariServices
import UICKeyChainStore
import FirebaseAnalytics
import CryptoSwift

enum FontStyleForAwesome: Int {
    case solid
    case regular
    case brands
}

@dynamicMemberLookup
class AppConfig {
    var prependPath = ""
    init() {
        self.prependPath = ""
    }
    init(_ prependPath: String) {
        self.prependPath = prependPath
    }
    subscript(dynamicMember path: String) -> Any? {
        return self.config(path)
    }
    func config(_ path: String) -> Any? {
        let p = (self.prependPath.count > 0 ? "\(self.prependPath)." : "") + path
        guard let configPlist = Bundle.main.url(forResource: "config", withExtension: "plist") else { return nil }
        guard var config = NSDictionary.init(contentsOf: configPlist) else { return nil }
        if let configDist = config.value(forKey: Constants.appName()) as? NSDictionary { config = configDist }
        let value = config.value(forKeyPath: p)
        return value
    }
    func colorConfig(_ path: String) -> UIColor {
        var color = UIColor.clear
        let colorString = self.config(path) as? String
        if (colorString ?? "").count == 0 {
            NSLog("[WARN] Config Color `\(path)` is empty")
        } else if (colorString ?? "").count > 0 {
            color = UIColor.colorFromHtmlColor(colorString ?? "")
        }
        return color
    }
}

@dynamicMemberLookup
class AppConfigColor: AppConfig {
    override init() {
        super.init("Themes")
    }
    subscript(dynamicMember path: String) -> UIColor {
        return self.colorConfig(path)
    }
}

extension Constants {
    static func SendFib(
        _ _name: Any,
        WithEvents _events: Any? = nil,
        Func _func: String = #function,
        File _file: String = #file,
        Line _line: Int = #line,
        Col _col: Int = #column
    ) {
        let __file = _file.replacingOccurrences(of: self.sourceRoot(), with: "")
        NSLog("Send FIB: \(_name)(\(String(describing: _events))) @ \(_func)\t\(__file):\(_line):\(_col)");
        if ((_name as? String) != "" && _events == nil) {
            Analytics.setScreenName(_name as? String, screenClass: _func)
        }
        if (_events != nil) {
            Analytics.logEvent(_name as? String ?? "", parameters: _events as? [String: Any])
        }
    }
    static var appConfig = AppConfig()
    static var appConfigColor = AppConfigColor()
    static var AcknowledgementsRepo: String {
        get {
            return (Constants.appConfig.AcknowledgementsRepo as? String) ?? "CCIP-App/CCIP-iOS"
        }
    }
    static var HasSetEvent: Bool {
        return OPassAPI.currentEvent.count > 0
    }
    static var EventId: String {
        return OPassAPI.eventInfo?.EventId ?? ""
    }
    static var accessToken: String? {
        get {
            var token = UICKeyChainStore.string(forKey: "\(OPassAPI.eventInfo?.EventId ?? "")|token")
            if (token == nil) {
                token = UICKeyChainStore.string(forKey: "token")
            }
            return token ?? ""
        }
        set {
            let accessToken = newValue
            UICKeyChainStore.removeItem(forKey: "\(OPassAPI.eventInfo?.EventId ?? "")|token")
            UICKeyChainStore.setString(accessToken, forKey: "\(OPassAPI.eventInfo?.EventId ?? "")|token")
            AppDelegate.delegateInstance.setDefaultShortcutItems()
        }
    }
    static var haveAccessToken: Bool {
        return (self.accessToken ?? "").count > 0
    }
    static var accessTokenSHA1: String {
        if self.haveAccessToken {
            guard let token = self.accessToken else { return "" }
            return token.sha1()
        }
        return ""
    }
    static var isDevMode: Bool {
        get {
            UserDefaults.standard.synchronize()
            return UserDefaults.standard.bool(forKey: "DEV_MODE")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "DEV_MODE")
            UserDefaults.standard.synchronize()
        }
    }
    static var currentLangUI: String {
        return NSLocalizedString("CurrentLang", comment: "")
    }
    private static let regex = try? NSRegularExpression.init(pattern: "^(?<major>[\\w]{2})(-(?<minor>[\\w]{2,4}))?$", options: [ .anchorsMatchLines, .caseInsensitive ])
    static var shortLangUI: String {
        let lang = self.currentLangUI
        let matches = self.regex?.matches(in: lang, options: .withTransparentBounds, range: NSRange.init(location: 0, length: lang.count))
        guard let langRange = matches?.first?.range(at: 1) else { return "" }
        return lang[langRange.location..<langRange.length]
    }
    static var longLangUI: String? {
        let shortLang = self.shortLangUI
        let langMap = [
            "en": "en-US",
            "zh": "zh-TW"
        ]
        return langMap.keys.contains(shortLang) ? langMap[shortLang] : nil
    }
    static var URL_BASE_FASTPASS: String {
        return OPassAPI.eventInfo?.Features[OPassKnownFeatures.FastPass]?.Url?.absoluteString ?? ""
    }
    static var URL_BASE_ANNOUNCEMENT: String {
        return OPassAPI.eventInfo?.Features[OPassKnownFeatures.Announcement]?.Url?.absoluteString ?? ""
    }
    static func URL_STATUS(token: String) -> String {
        return self.URL_BASE_FASTPASS.appending("/status?token=\(token)")
    }
    static func URL_USE(token: String, scenario: String) -> String {
        return self.URL_BASE_FASTPASS.appending("/use/\(scenario)?token=\(token)")
    }
    static var URL_ANNOUNCEMENT: String {
        return self.URL_BASE_ANNOUNCEMENT.appending("/announcement")
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
    static var URL_LOGO_IMG: String {
        return OPassAPI.eventInfo?.LogoUrl.absoluteString ?? ""
    }
    static func URL_SESSION(_ sessionKey: String) -> String {
        return self.OPassURL(OPassAPI.eventInfo?.Features[OPassKnownFeatures(rawValue: sessionKey.lowercased()) ?? OPassKnownFeatures.Schedule]?.Url?.absoluteString  ?? "")
    }
    static var URL_LOG_BOT: String {
        return self.OPassURL(OPassAPI.eventInfo?.Features[OPassKnownFeatures.IM]?.Url?.absoluteString ?? "")
    }
    static var URL_VENUE: String {
        return self.OPassURL(OPassAPI.eventInfo?.Features[OPassKnownFeatures.Venue]?.Url?.absoluteString ?? "")
    }
    static var URL_TELEGRAM_GROUP: String {
        return self.OPassURL(OPassAPI.eventInfo?.Features[OPassKnownFeatures.Telegram]?.Url?.absoluteString ?? "")
    }
    static var URL_STAFF_WEB: String {
        return self.OPassURL(OPassAPI.eventInfo?.Features[OPassKnownFeatures.Staffs]?.Url?.absoluteString ?? "")
    }
    static var URL_SPONSOR_WEB: String {
        return self.OPassURL(OPassAPI.eventInfo?.Features[OPassKnownFeatures.Sponsors]?.Url?.absoluteString ?? "")
    }
    static var URL_PARTNERS_WEB: String {
        return self.OPassURL(OPassAPI.eventInfo?.Features[OPassKnownFeatures.Partners]?.Url?.absoluteString ?? "")
    }
    static var URL_GAME: String {
        return self.OPassURL(OPassAPI.eventInfo?.Features[OPassKnownFeatures.Puzzle]?.Url?.absoluteString ?? "")
    }
    static func GitHubRepo(_ repo: String) -> String {
        return String(format: "https://github.com/\(repo)")
    }
    static func GitHubAvatar(_ user: String) -> String {
        return String(format: "https://avatars.githubusercontent.com/\(user)?s=86&v=3")
    }
    static func GravatarAvatar(_ hash: String) -> String {
        return String(format: "https://www.gravatar.com/avatar/\(hash)?s=86&\(hash.count > 0 ? "r=x" : "f=y&d=mm")")
    }
    static func OpenInAppSafari(forPath url: String) {
        if let url = URL.init(string: url) {
            self.OpenInAppSafari(forURL: url)
        }
    }
    static func OpenInAppSafari(forURL url: URL) {
        if (SFSafariViewController.className != "" && ((url.scheme?.contains("http")) ?? false)) {
            // Open in SFSafariViewController
            let safariViewController = SFSafariViewController.init(url: url)

            // SFSafariViewController Toolbar TintColor
            // [safariViewController.view setTintColor:[UIColor colorWithRed:61/255.0 green:152/255.0 blue:60/255.0 alpha:1]];
            // or http://stackoverflow.com/a/35524808/1751900

            // ProgressBar Color Not Found
            // ...

            if let topMost = UIApplication.getMostTopPresentedViewController() {
                topMost.present(safariViewController, animated: true, completion: nil)
            }
        } else {
            // Open in Mobile Safari
            UIApplication.shared.open(url, options: [:]) { (success: Bool) in
                if !success {
                    NSLog("Failed to open url: \(String(describing: url))")
                }
            }
        }
    }
    static func LoadDevLogoTo(view: FBShimmeringView) {
        let isDevMode = self.isDevMode
        let setDevLogo = { (resp: ImageResponse?) in
            let image = resp?.image
            if image != nil {
                if var img = image {
                    if isDevMode {
                        img = img.imageWithColor(self.appConfigColor.DevelopingLogoMaskColor)
                    }
                    if resp != nil {
                        if view.contentView == nil {
                            view.contentView = UIImageView.init(image: img)
                        } else {
                            if let iv = view.contentView as? UIImageView {
                                iv.image = img
                            }
                        }
                        view.contentView.contentMode = .scaleAspectFit
                    }
                }
            }
        }
        if let logoUrl = URL.init(string: self.URL_LOGO_IMG) {
            ImagePipeline.shared.loadImage(
                with: logoUrl,
                progress: { response, _, _ in
                    setDevLogo(response)
                },
                completion: { (result: Result<ImageResponse, ImagePipeline.Error>) in
                    setDevLogo(try? result.get())
                }
            )
        }
        view.shimmeringSpeed = 115
        view.isShimmering = isDevMode
    }
    static func LoadInto(view: UIImageView, forURL url: URL, withPlaceholder placeholder: UIImage) {
        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions(
                placeholder: placeholder,
                transition: .fadeIn(duration: 0.33)
            ),
            into: view
        )
    }
    static func AssertImage(name: String, InBundleName: String) -> UIImage? {
        return AssertImage(InBundleName, name)
    }
    static func AssertImage(_ bundleName: String, _ imageName: String ) -> UIImage? {
        let bundlePath = Bundle.main.bundlePath.appendingPathComponent("\(bundleName).bundle")
        guard let bundle = Bundle.init(path: bundlePath) else { return nil }
        return UIImage.init(named: imageName, in: bundle, compatibleWith: nil)
    }
    static func fontAwesome(code: String) -> String? {
        return String.fontAwesomeIcon(code: code)
    }
    static func fontOfAwesome(withSize: CGFloat, inStyle: FontStyleForAwesome) -> UIFont {
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
    static func attributedFontAwesome(
        ofCode: String,
        withSize: CGFloat,
        inStyle: FontStyleForAwesome,
        forColor: UIColor
    ) -> NSAttributedString {
        let fontAttribute = [
            NSAttributedString.Key.font: self.fontOfAwesome(withSize: withSize, inStyle: inStyle),
            NSAttributedString.Key.foregroundColor: forColor
        ]
        guard let fontAwesome = self.fontAwesome(code: ofCode) else { return NSAttributedString.init() }
        return NSAttributedString.init(string: fontAwesome, attributes: fontAttribute)
    }
    static var tintColor: UIColor {
        guard let tint = UIView().tintColor else { return UIColor.init() }
        return tint
    }
    static func DateFromUnix(_ unixInt: Int) -> Date {
        return Date(seconds: TimeInterval(unixInt), region: Region.local)
    }
    static func DateFromString(_ dateString: String) -> Date {
        let local = Region(calendar: Calendars.republicOfChina, zone: Zones.asiaTaipei, locale: Locales.chineseTaiwan)
        let isodate = dateString.toISODate(region: local)?.timeIntervalSince1970 ?? 0
        let date = Date(seconds: isodate, region: Region.local)
        return date
    }
    static func DateToDisplayDateString(_ date: Date) -> String {
        let local = Region(calendar: Calendars.republicOfChina, zone: Zones.asiaTaipei, locale: Locales.chineseTaiwan)
        return DateInRegion(date, region: local).toFormat(self.appConfig.DisplayDateFormat as? String ?? "")
    }
    static func DateToDisplayTimeString(_ date: Date) -> String {
        let local = Region(calendar: Calendars.republicOfChina, zone: Zones.asiaTaipei, locale: Locales.chineseTaiwan)
        return DateInRegion(date, region: local).toFormat(self.appConfig.DisplayTimeFormat as? String ?? "")
    }
    static func DateToDisplayDateTimeString(_ date: Date) -> String {
        let local = Region(calendar: Calendars.republicOfChina, zone: Zones.asiaTaipei, locale: Locales.chineseTaiwan)
        let format = String.init(format: "%@ %@", self.appConfig.DisplayDateFormat as? String ?? "", self.appConfig.DisplayTimeFormat as? String ?? "")
        return DateInRegion(date, region: local).toFormat(format)
    }
    static func DateToDisplayDateAndTimeString(_ date: Date) -> String {
        let local = Region(calendar: Calendars.republicOfChina, zone: Zones.asiaTaipei, locale: Locales.chineseTaiwan)
        return DateInRegion(date, region: local).toFormat(self.appConfig.DisplayDateTimeFormat as? String ?? "")
    }

    static var INIT_SESSION_DETAIL_VIEW_STORYBOARD_ID: String {
        return "SessionDetail"
    }
    static var SESSION_DETAIL_VIEW_STORYBOARD_ID: String {
        return "ShowSessionDetail"
    }
    static var SESSION_CACHE_CLEAR: String {
        return "ClearSessionContentCache"
    }
    static func SESSION_CACHE_KEY(_ sessionKey: String?) -> String {
        return "\(OPassAPI.currentEvent)|\(sessionKey ?? "")|SessionContentCache"
    }
    static func SESSION_FAV_KEY(_ sessionKey: String?) -> String {
        return "\(OPassAPI.currentEvent)|\(sessionKey ?? "")|FavoriteSession"
    }

    // MARK: - Math

    static func NEAR_ZERO(_ A: Double, _ B: Double) -> Double {
        return min(abs(A), abs(B)) == abs(A) ? A : B
    }
}
