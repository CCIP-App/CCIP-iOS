//
//  Constants.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/5.
//  Copyright © 2018 OPass. All rights reserved.
//

import Foundation
import FontAwesome_swift

@objc enum fontAwesomeStyle: Int {
    case solid
    case regular
    case brands
}

@objc extension Constants {
    public static var AccessToken : String {
        get {
            return AppDelegate.accessToken();
        }
    }
    public static var AccessTokenSHA1 : String {
        get {
            return AppDelegate.accessTokenSHA1();
        }
    }
    public static var URL_LOG_BOT : String {
        get {
            return Constants.urlLogBot();
        }
    };
    public static var URL_VENUE : String {
        get {
            return AppDelegate.appConfigURL("VenuePath");
        }
    }
    public static var URL_TELEGRAM_GROUP : String {
        get {
            return Constants.urlTelegramGroup();
        }
    }
    public static var URL_STAFF_WEB : String {
        get {
            return AppDelegate.appConfigURL("StaffPath")
        }
    }
    public static var URL_SPONSOR_WEB : String {
        get {
            return AppDelegate.appConfigURL("SponsorPath")
        }
    }
    public static var URL_GAME : String {
        get {
            return AppDelegate.appConfigURL("GamePath")
        }
    }
    public static func GitHubRepo(_ repo: String) -> String {
        return String(format: "https://github.com/\(repo)")
    }
    public static func GitHubAvatar(_ user: String) -> String {
        return String(format: "https://avatars.githubusercontent.com/\(user)?s=86&v=3")
    }
    public static func GravatarAvatar(_ hash: String) -> String {
        return String(format: "https://www.gravatar.com/avatar/\(hash)?s=86&\(hash.count > 0 ? "r=x" : "f=y&d=mm")")
    }
    @objc static func AssertImage(name: String, InBundleName: String) -> UIImage? {
        return AssertImage(InBundleName, name)
    }
    public static func AssertImage(_ bundleName: String, _ imageName: String ) -> UIImage? {
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
        get {
            return UIView().tintColor!
        }
    }
    @objc static func GetScheduleTypeName(_ namePrefix: Any) -> String {
        // TODO: mapping from define file from event config
        return namePrefix as? String ?? ""
    }
}
