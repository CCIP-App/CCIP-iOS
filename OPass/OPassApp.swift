//
//  OPassApp.swift
//  OPass
//
//  Created by 張智堯 on 2022/2/28.
//  2025 OPass.
//

import SwiftUI

@main
struct OPassApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage("UserInterfaceStyle") private var interfaceStyle = UIUserInterfaceStyle.unspecified
    @StateObject private var store = OPassStore()
    @State var url: URL? = nil

    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
            .overrideUserInterfaceStyle = interfaceStyle
        SoundManager.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(url: $url)
                .preferredColorScheme(.init(interfaceStyle))
                .environmentObject(store)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    if let url = activity.webpageURL {
                        UIApplication.currentUIWindow()?.rootViewController?.dismiss(animated: true)
                        self.url = url
                    }
                }
                .onOpenURL {
                    if ($0.scheme == "app.opass.ccip") { return }
                    UIApplication.currentUIWindow()?.rootViewController?.dismiss(animated: true)
                    self.url = $0
                }
        }
    }
}
