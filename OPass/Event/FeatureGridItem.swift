//
//  FeatureGridItem.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/10.
//

import SwiftUI

struct FeatureGridItem: View {
    let feature: Feature

    @EnvironmentObject private var event: EventStore
    @EnvironmentObject private var router: Router
    @Environment(\.colorScheme) var colorScheme

    @State private var presentWifi = false

    var body: some View {
        VStack {
            Button {
                featureAction()
            } label: {
                Rectangle()
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(.clear)
                    .overlay {
                        if let image = feature.iconImage {
                            image
                                .renderingMode(.template)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: feature.symbol)
                                .resizable()
                                .scaledToFill()
                                .padding(3)
                        }
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .tint(feature.color)

            Text(feature.title.localized())
                .font(.custom("RobotoCondensed-Regular", size: 11, relativeTo: .caption2))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .sheet(isPresented: $presentWifi) { WiFiView(feature: feature) }
    }

    private func featureAction() {
        switch feature.feature {
        case .fastpass:
            router.forward(FeatureDestinations.fastpass)
        case .schedule:
            router.forward(FeatureDestinations.schedule)
        case .ticket:
            router.forward(FeatureDestinations.ticket)
        case .announcement:
            router.forward(FeatureDestinations.announcement)
        case .wifi:
            if let wifi = feature.wifi, wifi.count == 1 {
                NEHotspot.ConnectWiFi(SSID: wifi[0].ssid, withPass: wifi[0].password)
            } else {
                presentWifi = true
            }
        case .telegram:
            if let urlString = feature.url, let url = URL(string: urlString) {
                Constants.openInOS(forURL: url)
            }
        default:
            if let url = feature.url(token: event.token, role: event.attendee?.role) {
                Constants.openInAppSafari(forURL: url, style: colorScheme)  // TODO: Custom Webview
            }
        }
    }
}
