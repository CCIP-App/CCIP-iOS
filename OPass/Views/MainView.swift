//
//  MainView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/25.
//  2022 OPass.
//

import SwiftUI
import BetterSafariView
import CryptoKit
import OSLog

struct MainView: View {
    
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    @ObservedObject var eventAPI: EventAPIViewModel
    private let gridItemLayout = Array(repeating: GridItem(spacing: CGFloat(UIScreen.main.bounds.width / 16.56), alignment: Alignment.top), count: 4)
    private let logger = Logger(subsystem: "app.opass.ccip", category: "MainView")
    @State private var selectedFeature: FeatureType? = nil
    
    var body: some View {
        VStack {
            Group {
                if let image = OPassAPI.currentEventLogo {
                    image
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal)
                } else if let eventLogoData = eventAPI.eventLogo, let eventLogoUIImage = UIImage(data: eventLogoData) {
                    Image(uiImage: eventLogoUIImage)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
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
                        if !(CheckFeatureIsWebview(feature.feature) && feature.url?.processWith(token: eventAPI.accessToken, role: eventAPI.eventScenarioStatus?.role) == nil),
                           CheckFeatureVisible(feature.visible_roles) {
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
                        } // Bypass Webview feature that it's url not accepted by URL structure
                    }
                }
            }
            .padding(.horizontal)
        }
        .background {
            Group {
                NavigationLink(
                    tag: FeatureType.fastpass,
                    selection: $selectedFeature,
                    destination: { FastpassView(eventAPI: eventAPI) }) {
                    EmptyView()
                }
                NavigationLink(
                    tag: FeatureType.ticket,
                    selection: $selectedFeature,
                    destination: { TicketView(eventAPI: eventAPI) }) {
                    EmptyView()
                }
                NavigationLink(
                    tag: FeatureType.schedule,
                    selection: $selectedFeature,
                    destination: { ScheduleView(eventAPI: eventAPI) }) {
                    EmptyView()
                }
                NavigationLink(
                    tag: FeatureType.announcement,
                    selection: $selectedFeature,
                    destination: { AnnounceView(eventAPI: eventAPI) }) {
                    EmptyView()
                }
            }.hidden()
        }
    }
    
    private func CheckFeatureIsWebview(_ featureType: FeatureType) -> Bool {
        return featureType == .im || featureType == .puzzle || featureType == .venue || featureType == .sponsors || featureType == .staffs || featureType == .webview
    }
    private func CheckFeatureVisible(_ visible: [String]?) -> Bool {
        if let visible = visible {
            if let role = eventAPI.eventScenarioStatus?.role, visible.contains(role) {
                return true
            }
            return false
        }
        return true
    }
}

fileprivate struct TabButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    let feature: FeatureModel
    @Binding var selectedFeature: FeatureType?
    @ObservedObject var eventAPI: EventAPIViewModel
    let width: CGFloat
    
    @State private var presentingWifiSheet = false
    @State private var presentingSafariView = false
    //fastpass, ticket, schedule, announcement, wifi, telegram, im, puzzle, venue, sponsors, staffs, webview
    var body: some View {
        switch(feature.feature) {
            case .fastpass, .ticket, .schedule, .announcement:
                Button(action: { selectedFeature = feature.feature }) {
                    Image(systemName: feature.symbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(width / 10)
                }
                .tabButtonStyle(color: feature.color, width: width)
            case .wifi:
                Button(action: {
                    if let wifi = feature.wifi, wifi.count == 1 {
                        NEHotspot.ConnectWiFi(SSID: wifi[0].SSID, withPass: wifi[0].password)
                    } else { presentingWifiSheet.toggle() }
                }) {
                    Image(systemName: feature.symbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(width / 10)
                }
                .tabButtonStyle(color: feature.color, width: width)
                .sheet(isPresented: $presentingWifiSheet) {
                    WiFiView(feature: feature)
                }
            case .telegram:
                Button(action: {
                    if let telegramURLString = feature.url, let telegramURL = URL(string: telegramURLString) {
                        openURL(telegramURL)
                    }
                }) {
                    Image(systemName: feature.symbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(width / 10)
                }
                .tabButtonStyle(color: feature.color, width: width)
            default:
            if let url = feature.url?.processWith(token: eventAPI.accessToken, role: eventAPI.eventScenarioStatus?.role) {
                    Button(action: {
                        presentingSafariView = true
                    }) {
                        if feature.feature != .webview {
                            Image(systemName: feature.symbolName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(width / 10)
                        } else {
                            if let iconData = feature.iconData, let iconUIImage = UIImage(data: iconData) {
                                Image(uiImage: iconUIImage)
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(width / 10)
                            } else {
                                Image(systemName: "shippingbox")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(width / 10)
                            }
                        }
                    }
                    .tabButtonStyle(color: feature.color, width: width)
                    .safariView(isPresented: $presentingSafariView) {
                        SafariView(
                            url: url,
                            configuration: .init(
                                entersReaderIfAvailable: false,
                                barCollapsingEnabled: true
                            )
                        )
                        .preferredBarAccentColor(colorScheme == .dark ? Color(red: 28/255, green: 28/255, blue: 30/255) : .white)
                    }
                }
        }
    }
}

fileprivate extension String {
    func processWith(token: String?, role: String?) -> URL? {
        var url = self
        guard let paramsRegex = try? NSRegularExpression.init(pattern: "(\\{[^\\}]+\\})", options: .caseInsensitive) else { return nil }
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

fileprivate extension FeatureType {
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
    
    var symbolName: String {
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
        return buttonSymbolName[self] ?? "exclamationmark.icloud"
    }
}

fileprivate extension FeatureModel {
    var color: Color { feature.color }
    var symbolName: String { feature.symbolName }
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
