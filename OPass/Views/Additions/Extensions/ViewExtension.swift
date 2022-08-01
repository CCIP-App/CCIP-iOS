//
//  ViewExtension.swift
//  OPass
//
//  Created by 張智堯 on 2022/5/3.
//  2022 OPass.
//

import SwiftUI
import SafariServices

extension View {
    ///Use this method to open the specified resource. If the specified URL scheme is handled by another app, iOS launches that app and passes the URL to it.
    func OpenInOS(forURL url: URL) {
        UIApplication.shared.open(url)
    }
    ///Use this method to try open URL in SFSafariViewController or will passes the URL to operating system.
    func OpenInAppSafari(forURL url: URL, style: ColorScheme? = nil) {
        OpenInAppSafari(forURL: url, style: UIUserInterfaceStyle(style))
    }
    ///Use this method to try open URL in SFSafariViewController or will passes the URL to operating system.
    func OpenInAppSafari(forURL url: URL, style: UIUserInterfaceStyle) {
        if let url = ProcessURL(url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false
            config.barCollapsingEnabled = true
            let safariViewController = SFSafariViewController(url: url, configuration: config)
            safariViewController.overrideUserInterfaceStyle = style
            UIApplication.shared.currentUIWindow()?.rootViewController?.present(safariViewController, animated: true)
        } else { OpenInOS(forURL: url) }
    }
    
    func LocalizeIn<T>(zh: T, en: T) -> T {
        if Bundle.main.preferredLocalizations[0] ==  "zh-Hant" { return zh }
        return en
    }
    
    func ProcessURL(_ rawURL: URL) -> URL? {
        var result: URL? = rawURL
        if !rawURL.absoluteString.lowercased().hasPrefix("http") {
            result = URL(string: "http://" + rawURL.absoluteString)
        }
        return result
    }
    
    @ViewBuilder //Use this at last resort. It's bad in SwiftUI.
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) }
        else { self }
    }
}
