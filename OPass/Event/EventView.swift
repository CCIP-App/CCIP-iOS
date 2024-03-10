//
//  EventView.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/8.
//

import SwiftUI

struct EventView: View {

    // MARK: - View State

    @EnvironmentObject private var store: OPassStore
    @EnvironmentObject private var event: EventStore
    @EnvironmentObject private var router: Router
    @Environment(\.colorScheme) private var colorScheme
    @State private var presentWifi = false

    // MARK: - Main View

    var body: some View {
        VStack() {
            eventLogo
                .foregroundColor(.logo)
                .padding(.bottom)
                .frame(
                    width: UIScreen.main.bounds.width * 0.78,
                    height: UIScreen.main.bounds.width * 0.4
                )

            featureGrid
        }
        .navigationDestination(for: FeatureDestinations.self) { $0.view }
        .background(.sectionBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbar }
    }

    // MARK: - Private Subviews

    @ViewBuilder
    private var eventLogo: some View {
        if let image = store.eventLogo {
            image
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
        } else if let logo = event.logo {
            logo
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
        } else {
            Text(event.config.title.localized())
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var featureGrid: some View {
        ScrollView {
            LazyVGrid(columns: .init(
                repeating: .init(spacing: 30, alignment: .top),
                count: 4
            )) {
                ForEach(event.avaliableFeatures, id: \.self) { feature in
                    featureButton(of: feature)
                        .padding(.bottom, 5)
                }
            }
        }
        .padding(.horizontal)
    }

    private func featureButton(of feature: Feature) -> some View {
        VStack {
            Button {
                featureAction(of: feature)
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

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text(event.config.title.localized())
                    .font(.headline)
                if event.userId != "nil" {
                    Text(event.userId)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }

    // MARK: - Private Helper

    private func featureAction(of feature: Feature) {
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
            } else { presentWifi = true }
        case .telegram:
            if let urlString = feature.url, let url = URL(string: urlString) {
                Constants.openInOS(forURL: url)
            }
        default:
            if let url = feature.url(token: event.token, role: event.attendee?.role) {
                Constants.openInAppSafari(forURL: url, style: colorScheme) // TODO: Custom Webview
            }
        }
    }
}
