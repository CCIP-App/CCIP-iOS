//
//  Constants.swift
//  OPass
//
//  Created by 張智堯 on 2022/8/2.
//  2022 OPass.
//

import SwiftUI
import OneSignal
import Foundation
import SafariServices

final class Constants {
    ///Use this method to open the specified resource. If the specified URL scheme is handled by another app, OS launches that app and passes the URL to it.
    static func OpenInOS(forURL url: URL) {
        UIApplication.shared.open(url)
    }
    ///Use this method to try open URL in SFSafariViewController or will passes the URL to operating system.
    static func OpenInAppSafari(forURL url: URL, style: ColorScheme? = nil) {
        OpenInAppSafari(forURL: url, style: UIUserInterfaceStyle(style))
    }
    ///Use this method to try open URL in SFSafariViewController or will passes the URL to operating system.
    static func OpenInAppSafari(forURL url: URL, style: UIUserInterfaceStyle) {
        if let url = ProcessURL(url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false
            config.barCollapsingEnabled = true
            let safariViewController = SFSafariViewController(url: url, configuration: config)
            safariViewController.overrideUserInterfaceStyle = style
            UIApplication.shared.currentUIWindow()?.rootViewController?.present(safariViewController, animated: true)
        } else { OpenInOS(forURL: url) }
    }
    ///Use this method to try process URL if it's not http protocol. Return nil if it faild.
    static func ProcessURL(_ rawURL: URL) -> URL? {
        var result: URL? = rawURL
        if !rawURL.absoluteString.lowercased().hasPrefix("http") {
            result = URL(string: "http://" + rawURL.absoluteString)
        }
        return result
    }
    ///Use this method to request user push notifications permission.
    static func PromptForPushNotifications() {
        OneSignal.promptForPushNotifications(userResponse: { accepted in
           print("User accepted notifications: ", accepted)
        }, fallbackToSettings: false)
    }
}
