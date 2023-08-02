//
//  MainView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/25.
//  2023 OPass.
//

import SwiftUI
import OSLog

struct MainView: View {
    // MARK: - Variables
    @EnvironmentObject var OPassService: OPassStore
    @EnvironmentObject var event: EventStore
    private let gridItemLayout = Array(repeating: GridItem(spacing: UIScreen.main.bounds.width / 16.56, alignment: .top), count: 4)
    private let logger = Logger(subsystem: "app.opass.ccip", category: "MainView")

    // MARK: - Views
    var body: some View {
        VStack {
            Group {
                if let image = OPassService.eventLogo {
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
            .padding(.vertical)
            .foregroundColor(Color("LogoColor"))
            .frame(width: UIScreen.main.bounds.width * 0.78, height: UIScreen.main.bounds.width * 0.4)

            ScrollView {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(event.config.features, id: \.self) { feature in
                        if featureIsAvailable(feature), featureIsVisible(feature.visibleRoles) {
                            VStack {
                                TabButton(feature: feature, width: UIScreen.main.bounds.width / 5.394136)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(
                                        width: UIScreen.main.bounds.width / 5.394136,
                                        height: UIScreen.main.bounds.width / 5.394136
                                    )
                                    .clipShape(RoundedRectangle(cornerSize: CGSize(
                                        width: UIScreen.main.bounds.width / 27.6,
                                        height: UIScreen.main.bounds.width / 27.6
                                    )))

                                Text(feature.title.localized())
                                    .font(.custom("RobotoCondensed-Regular", size: 11, relativeTo: .caption2))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }.padding(.bottom, 10)
                        }
                    }
                }
            }.padding(.horizontal)
        }
    }
    private func featureIsAvailable(_ feature: Feature) -> Bool {
        let type = feature.feature
        guard type == .im || type == .puzzle || type == .venue || type == .sponsors || type == .staffs || type == .webview else { return true }
        return feature.url(token: event.token, role: event.attendee?.role) != nil
    }
    private func featureIsVisible(_ visibleRoles: [String]?) -> Bool {
        guard let visibleRoles = visibleRoles else { return true }
        guard event.userRole != "nil" else { return false }
        return visibleRoles.contains(event.userRole)
    }
}

private struct TabButton: View {
    let feature: Feature, width: CGFloat
    @EnvironmentObject var event: EventStore
    @EnvironmentObject var router: Router
    @Environment(\.colorScheme) var colorScheme

    @State private var presentingWifiSheet = false
    var body: some View {
        Button {
            switch feature.feature {
            case .fastpass:     router.path.append(Router.mainDestination.fastpass)
            case .schedule:     router.path.append(Router.mainDestination.schedule)
            case .ticket:       router.path.append(Router.mainDestination.ticket)
            case .announcement: router.path.append(Router.mainDestination.announcement)
            case .wifi:
                if let wifi = feature.wifi, wifi.count == 1 {
                    NEHotspot.ConnectWiFi(SSID: wifi[0].ssid, withPass: wifi[0].password)
                } else { self.presentingWifiSheet.toggle() }
            case .telegram:
                if let url = URL(string: feature.url ?? "") {
                    Constants.openInOS(forURL: url)
                }
            case .im, .puzzle, .venue, .sponsors, .staffs, .webview:
                if let url = feature.url(token: event.token, role: event.attendee?.role) {
                    Constants.openInAppSafari(forURL: url, style: colorScheme)
                }
            }
        } label: {
            Group {
                if let image = feature.iconImage {
                    image
                        .interpolation(.none)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: feature.symbol)
                        .resizable()
                        .scaledToFit()
                }
            }.padding(width / 10)
        }
        .tint(feature.color)
        .aspectRatio(contentMode: .fill)
        .padding(width * 0.2)
        .background(feature.color.opacity(0.1))
        .if(self.feature.feature == .wifi && self.feature.wifi?.count != 1) { $0
            .sheet(isPresented: $presentingWifiSheet) { WiFiView(feature: feature) }
        }
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MainView().environmentObject(OPassStore.mock().event!)
        }
    }
}
#endif
