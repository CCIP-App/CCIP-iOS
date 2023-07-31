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
    @EnvironmentObject var OPassService: OPassService
    @EnvironmentObject var EventService: EventService
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
                } else if let logo = EventService.logo {
                    logo
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal)
                } else {
                    Text(EventService.display_name.localized())
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
                    ForEach(EventService.settings.features, id: \.self) { feature in
                        if FeatureIsAvailable(feature), FeatureIsVisible(feature.visibleRoles) {
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
    private func FeatureIsAvailable(_ feature: Feature) -> Bool {
        let t = feature.feature
        guard t == .im || t == .puzzle || t == .venue || t == .sponsors || t == .staffs || t == .webview else { return true }
        return feature.url(token: EventService.user_token, role: EventService.scenario_status?.role) != nil
    }
    private func FeatureIsVisible(_ visible_roles: [String]?) -> Bool {
        guard let visible_roles = visible_roles else { return true }
        guard EventService.user_role != "nil" else { return false }
        return visible_roles.contains(EventService.user_role)
    }
}

private struct TabButton: View {
    let feature: Feature, width: CGFloat
    @EnvironmentObject var EventService: EventService
    @EnvironmentObject var router: Router
    @Environment(\.colorScheme) var colorScheme
    
    @State private var presentingWifiSheet = false
    var body: some View {
        Button {
            switch(feature.feature) {
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
                    Constants.OpenInOS(forURL: url)
                }
            case .im, .puzzle, .venue, .sponsors, .staffs, .webview:
                if let url = feature.url(token: EventService.user_token, role: EventService.scenario_status?.role) {
                    Constants.OpenInAppSafari(forURL: url, style: colorScheme)
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
        .if (self.feature.feature == .wifi && self.feature.wifi?.count != 1) { $0
            .sheet(isPresented: $presentingWifiSheet) { WiFiView(feature: feature) }
        }
    }
    
    private func FeatureIsWebView(_ feature: Feature) -> Bool {
        let t = feature.feature
        if t == .im || t == .puzzle || t == .venue || t == .sponsors || t == .staffs || t == .webview { return true }
        return false
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MainView().environmentObject(OPassService.mock().event!)
        }
    }
}
#endif
