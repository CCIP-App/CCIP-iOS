//
//  Constants.swift
//  OPass
//
//  Created by 張智堯 on 2022/8/2.
//  2023 OPass.
//

import SwiftUI
import Foundation
import SafariServices

final class Constants {
    /// Use this method to open the specified resource.
    /// If the specified URL scheme is handled by another app, OS launches that app and passes the URL to it.
    static func openInOS(forURL url: URL) {
        UIApplication.shared.open(url)
    }
    /// Use this method to try open URL in SFSafariViewController or will passes the URL to operating system.
    static func openInAppSafari(forURL url: URL, style: ColorScheme? = nil) {
        openInAppSafari(forURL: url, style: UIUserInterfaceStyle(style))
    }
    /// Use this method to try open URL in SFSafariViewController or will passes the URL to operating system.
    static func openInAppSafari(forURL url: URL, style: UIUserInterfaceStyle) {
        if let url = processURL(url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false
            config.barCollapsingEnabled = true
            let safariViewController = SFSafariViewController(url: url, configuration: config)
            safariViewController.overrideUserInterfaceStyle = style
            UIApplication.topViewController()?.present(safariViewController, animated: true)
        } else { openInOS(forURL: url) }
    }
    /// Use this method to try process URL if it's not http protocol. Return nil if it faild.
    static func processURL(_ rawURL: URL) -> URL? {
        var result: URL? = rawURL
        if !rawURL.absoluteString.lowercased().hasPrefix("http") {
            result = URL(string: "http://" + rawURL.absoluteString)
        }
        return result
    }
}
