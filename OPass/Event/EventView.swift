//
//  EventView.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/8.
//

import SwiftUI

struct EventView: View {
    @EnvironmentObject private var store: OPassStore
    @EnvironmentObject private var event: EventStore
    @EnvironmentObject private var router: Router
    @Environment(\.colorScheme) private var colorScheme
    @State private var presentWifi = false

    // MARK: - Views
    var body: some View {
        VStack {
            eventLogo
                .foregroundColor(.logo)
                .padding(.bottom)
                .frame(
                    width: UIScreen.main.bounds.width * 0.78,
                    height: UIScreen.main.bounds.width * 0.4)

            featureGrid
        }
        .navigationDestination(for: FeatureDestinations.self) { $0.view }
        .background(.sectionBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbar }
    }

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
            let spacing = UIApplication.size.width * 0.0545454
            LazyVGrid(
                columns: .init(
                    repeating: .init(spacing: spacing, alignment: .top),
                    count: 4
                )
            ) {
                ForEach(event.avaliableFeatures, id: \.self) { feature in
                    featureButton(of: feature)
                        .padding(.bottom, 5)
                }
            }
            .padding(.horizontal, spacing)
        }
    }

    private func featureButton(of feature: Feature) -> some View {
        VStack {
            Button {
                featureAction(of: feature)
            } label: {
                Rectangle()
                    .aspectRatio(0.8484848, contentMode: .fit)
                    .foregroundColor(.clear)
                    .overlay {
                        GeometryReader { geometry in
                            let width = geometry.size.width
                            Group {
                                if let image = feature.iconImage {
                                    image
                                        .renderingMode(.template)
                                        .interpolation(.none)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: width * 0.8, height: width * 0.8)
                                } else {
                                    Image(systemName: feature.symbol)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: width * 0.7, height: width * 0.65)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
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

    // MARK: - Private Functions
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
