//
//  MainView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/25.
//  2022 OPass.
//

import SwiftUI
import CryptoKit
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
                        .interpolation(.none)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal)
                } else if let eventLogoData = eventAPI.eventLogo, let eventLogoUIImage = UIImage(data: eventLogoData) {
                    Image(uiImage: eventLogoUIImage)
                        .interpolation(.none)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal)
                } else {
                    Text(LocalizeIn(zh: eventAPI.display_name.zh, en: eventAPI.display_name.en))
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
                    ForEach(eventAPI.eventSettings.features, id: \.self) { feature in
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
                                
                                Text(LocalizeIn(zh: feature.display_text.zh, en: feature.display_text.en))
                                    .font(.custom("RobotoCondensed-Regular", size: 11, relativeTo: .caption2))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }.padding(.bottom, 10)
                        }
                    }
                }
            }.padding(.horizontal)
        }
        .background {
            Group {
                NavigationLink(
                    tag: FeatureType.fastpass,
                    selection: $selectedFeature,
                    destination: { FastpassView(eventAPI: eventAPI) }
                ) { EmptyView() }
                NavigationLink(
                    tag: FeatureType.ticket,
                    selection: $selectedFeature,
                    destination: { TicketView(eventAPI: eventAPI) }
                ) { EmptyView() }
                NavigationLink(
                    tag: FeatureType.schedule,
                    selection: $selectedFeature,
                    destination: { ScheduleView(eventAPI: eventAPI) }
                ) { EmptyView() }
                NavigationLink(
                    tag: FeatureType.announcement,
                    selection: $selectedFeature,
                    destination: { AnnounceView(eventAPI: eventAPI) }
                ) { EmptyView() }
            }.hidden()
        }
    }
    
    private func FeatureIsAvailable(_ feature: FeatureModel) -> Bool {
        let t = feature.feature
        guard t == .im || t == .puzzle || t == .venue || t == .sponsors || t == .staffs || t == .webview else { return true }
        return feature.url?.processWith(token: eventAPI.accessToken, role: eventAPI.eventScenarioStatus?.role) != nil
    }
    private func FeatureIsVisible(_ visible_roles: [String]?) -> Bool {
        guard let visible_roles = visible_roles else { return true }
        guard let user_role = eventAPI.eventScenarioStatus?.role else { return false }
        return visible_roles.contains(user_role)
    }
}

private struct TabButton: View {
    @Environment(\.colorScheme) var colorScheme
    let feature: FeatureModel
    @Binding var selectedFeature: FeatureType?
    @ObservedObject var eventAPI: EventAPIViewModel
    let width: CGFloat
    
    @State private var presentingWifiSheet = false
    var body: some View {
        Button {
            switch(feature.feature) {
            case .fastpass, .schedule, .ticket, .announcement:
                self.selectedFeature = feature.feature
            case .wifi:
                if let wifi = feature.wifi, wifi.count == 1 {
                    NEHotspot.ConnectWiFi(SSID: wifi[0].SSID, withPass: wifi[0].password)
                } else { self.presentingWifiSheet.toggle() }
            case .telegram:
                if let url = URL(string: feature.url ?? "") {
                    Constants.OpenInOS(forURL: url)
                }
            default:
                if let url = feature.url?.processWith(token: eventAPI.accessToken, role: eventAPI.eventScenarioStatus?.role) {
                    Constants.OpenInAppSafari(forURL: url, style: colorScheme)
                }
            }
        } label: {
            Group {
                if let data = feature.iconData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .interpolation(.none)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: feature.symbolName ?? "shippingbox")
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

private extension String {
    func processWith(token: String?, role: String?) -> URL? {
        var url = self
        guard let paramsRegex = try? NSRegularExpression(pattern: "(\\{[^\\}]+\\})", options: .caseInsensitive) else { return nil }
        let matches = paramsRegex.matches(in: url, options: .reportProgress, range: NSRange(location: 0, length: url.count))
        for m in stride(from: matches.count, to: 0, by: -1) {
            let range = Range(matches[m - 1].range(at: 1), in: url)!
            let param = url[range]
            switch param {
            case "{token}":
                url = url.replacingOccurrences(of: param, with: token ?? "")
            case "{public_token}":
                url = url.replacingOccurrences(
                    of: param,
                    with: Insecure.SHA1.hash(data: Data((token ?? "").utf8))
                        .map { String(format: "%02X", $0) }
                        .joined()
                        .lowercased()
                )
            case "{role}":
                url = url.replacingOccurrences(of: param, with: role ?? "")
            default:
                url = url.replacingOccurrences(of: param, with: "")
            }
        }
        return URL(string: url)
    }
}

private extension FeatureType {
    var color: Color {
        let buttonColor: [FeatureType : Color] = [
            .fastpass : .blue,
            .ticket : .purple,
            .schedule : .green,
            .announcement : .orange,
            .wifi : .brown,
            .telegram : .green,
            .im : .purple,
            .puzzle : .blue,
            .venue : .blue,
            .sponsors : .yellow,
            .staffs : .gray,
            .webview : .purple
        ]
        return buttonColor[self] ?? .purple
    }
    
    var symbolName: String? {
        let buttonSymbolName: [FeatureType : String] = [
            .fastpass : "wallet.pass",
            .ticket : "ticket",
            .schedule : "scroll",
            .announcement : "megaphone",
            .wifi : "wifi",
            .telegram : "paperplane",
            .im : "bubble.right",
            .puzzle : "puzzlepiece.extension",
            .venue : "map",
            .sponsors : "banknote",
            .staffs : "person.3"
        ]
        return buttonSymbolName[self]
    }
}

private extension FeatureModel {
    var color: Color { feature.color }
    var symbolName: String? { feature.symbolName }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainView(eventAPI: OPassAPIViewModel.mock().currentEventAPI!)
        }
    }
}
#endif
