//
//  MainView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/25.
//  2022 OPass.
//

import SwiftUI
import OSLog

struct MainView: View {
    
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    @ObservedObject var eventAPI: EventAPIViewModel
    @State private var selectedFeature: FeatureType? = nil
    private let gridItemLayout = Array(repeating: GridItem(spacing: UIScreen.main.bounds.width / 16.56, alignment: .top), count: 4)
    private let logger = Logger(subsystem: "app.opass.ccip", category: "MainView")
    
    var body: some View {
        VStack {
            Group {
                if let image = OPassAPI.currentEventLogo {
                    image
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal)
                } else if let logo = eventAPI.logo {
                    logo
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal)
                } else {
                    Text(eventAPI.display_name.localized())
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
                    ForEach(eventAPI.settings.features, id: \.self) { feature in
                        if FeatureIsAvailable(feature), FeatureIsVisible(feature.visible_roles) {
                            VStack {
                                TabButton(
                                    feature: feature,
                                    selectedFeature: $selectedFeature,
                                    eventAPI: eventAPI,
                                    width: UIScreen.main.bounds.width / 5.394136
                                )
                                .aspectRatio(contentMode: .fill)
                                .frame(
                                    width: UIScreen.main.bounds.width / 5.394136,
                                    height: UIScreen.main.bounds.width / 5.394136
                                )
                                .clipShape(RoundedRectangle(cornerSize: CGSize(
                                    width: UIScreen.main.bounds.width / 27.6,
                                    height: UIScreen.main.bounds.width / 27.6
                                )))
                                
                                Text(feature.display_text.localized())
                                    .font(.custom("RobotoCondensed-Regular", size: 11, relativeTo: .caption2))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }.padding(.bottom, 10)
                        }
                    }
                }
            }.padding(.horizontal)
        }
        .navigationDestination(for: SessionDataModel.self) { detail in
            SessionDetailView(eventAPI, detail: detail)
        }
    }
    private func FeatureIsAvailable(_ feature: FeatureModel) -> Bool {
        let t = feature.feature
        guard t == .im || t == .puzzle || t == .venue || t == .sponsors || t == .staffs || t == .webview else { return true }
        return feature.url(token: eventAPI.user_token, role: eventAPI.scenario_status?.role) != nil
    }
    private func FeatureIsVisible(_ visible_roles: [String]?) -> Bool {
        guard let visible_roles = visible_roles else { return true }
        guard eventAPI.user_role != "nil" else { return false }
        return visible_roles.contains(eventAPI.user_role)
    }
}

private struct TabButton: View {
    @Environment(\.colorScheme) var colorScheme
    let feature: FeatureModel
    @Binding var selectedFeature: FeatureType?
    @ObservedObject var eventAPI: EventAPIViewModel
    @EnvironmentObject var pathManager: PathManager
    let width: CGFloat
    
    @State private var presentingWifiSheet = false
    var body: some View {
        Button {
            switch(feature.feature) {
            case .fastpass:     pathManager.path.append(.fastpass)
            case .schedule:     pathManager.path.append(.schedule)
            case .ticket:       pathManager.path.append(.ticket)
            case .announcement: pathManager.path.append(.announcement)
            case .wifi:
                if let wifi = feature.wifi, wifi.count == 1 {
                    NEHotspot.ConnectWiFi(SSID: wifi[0].SSID, withPass: wifi[0].password)
                } else { self.presentingWifiSheet.toggle() }
            case .telegram:
                if let url = URL(string: feature.url ?? "") {
                    Constants.OpenInOS(forURL: url)
                }
            case .im, .puzzle, .venue, .sponsors, .staffs, .webview:
                if let url = feature.url(token: eventAPI.user_token, role: eventAPI.scenario_status?.role) {
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
    
    private func FeatureIsWebView(_ feature: FeatureModel) -> Bool {
        let t = feature.feature
        if t == .im || t == .puzzle || t == .venue || t == .sponsors || t == .staffs || t == .webview { return true }
        return false
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MainView(eventAPI: OPassAPIViewModel.mock().currentEventAPI!)
        }
    }
}
#endif
