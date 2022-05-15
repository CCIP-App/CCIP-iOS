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
    
    @ObservedObject var eventAPI: EventAPIViewModel
    private let gridItemLayout = Array(repeating: GridItem(spacing: CGFloat(25.0), alignment: Alignment.top), count: 4)
    private let logger = Logger(subsystem: "app.opass.ccip", category: "MainView")
    @State private var selectedFeature: FeatureType? = nil
    
    var body: some View {
        VStack {
            if let eventLogoData = eventAPI.eventLogo, let eventLogoUIImage = UIImage(data: eventLogoData) {
                Image(uiImage: eventLogoUIImage)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .foregroundColor(Color("LogoColor"))
                    .frame(width: UIScreen.main.bounds.width * 0.78, height: UIScreen.main.bounds.width * 0.4)
            } else {
                Text(LocalizeIn(zh: eventAPI.display_name.zh, en: eventAPI.display_name.en))
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.medium)
                    .padding(.vertical)
                    .foregroundColor(Color("LogoColor"))
                    .frame(width: UIScreen.main.bounds.width * 0.78, height: UIScreen.main.bounds.width * 0.4)
            }
            
            ScrollView {
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(eventAPI.eventSettings.features, id: \.self) { feature in
                        if !(CheckFeatureIsWebview(type: feature.feature) && feature.url?.processWith(token: eventAPI.accessToken, role: eventAPI.eventScenarioStatus?.role) == nil) {
                            VStack {
                                GeometryReader { geometry in
                                    TabButton(feature: feature, selectedFeature: $selectedFeature, eventAPI: eventAPI, width: geometry.size.width)
                                        .frame(width: geometry.size.width, height: geometry.size.width)
                                }
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
                                
                                Text(LocalizeIn(zh: feature.display_text.zh, en: feature.display_text.en))
                                    .font(.caption2)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }.padding(.bottom, 10)
                        } //Bypass Webview feature that it's url not accepted by URL structure
                    }
                }
            }
            .padding(.horizontal)
        }
        .background {
            //put invisible NavigationLink in background
            NavigationLink(
                tag: FeatureType.fastpass,
                selection: $selectedFeature,
                destination: { FastpassView(eventAPI: eventAPI) }) {
                EmptyView()
            }
                .frame(width: 0, height: 0).hidden()
            NavigationLink(
                tag: FeatureType.ticket,
                selection: $selectedFeature,
                destination: { TicketView(eventAPI: eventAPI) }) {
                EmptyView()
            }
                .frame(width: 0, height: 0).hidden()
            NavigationLink(
                tag: FeatureType.schedule,
                selection: $selectedFeature,
                destination: { ScheduleView(eventAPI: eventAPI) }) {
                EmptyView()
            }
                .frame(width: 0, height: 0).hidden()
            NavigationLink(
                tag: FeatureType.announcement,
                selection: $selectedFeature,
                destination: { AnnounceView(eventAPI: eventAPI) }) {
                EmptyView()
            }
            .frame(width: 0, height: 0).hidden()
        }
    }
    
    private func CheckFeatureIsWebview(type featureType: FeatureType) -> Bool {
        return featureType == .im || featureType == .puzzle || featureType == .venue || featureType == .sponsors || featureType == .staffs || featureType == .webview
    }
}

struct TabButton: View {
    @Environment(\.openURL) var openURL
    let feature: FeatureModel
    @Binding var selectedFeature: FeatureType?
    @ObservedObject var eventAPI: EventAPIViewModel
    let width: CGFloat
    @State private var safariViewURL = ""
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
                    NavigationView {
                        WiFiView(feature: feature)
                    }
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
                        presentingSafariView.toggle()
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
                            configuration: SafariView.Configuration(
                                entersReaderIfAvailable: false,
                                barCollapsingEnabled: true
                            )
                        )
                        //.preferredBarAccentColor(.white)
                        //.preferredControlAccentColor(.accentColor)
                        .dismissButtonStyle(.done)
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
                url = url.replacingOccurrences(of: param, with: Insecure.SHA1.hash(data: Data((token ?? "").utf8)).map { String(format: "%02X", $0) }.joined())
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
