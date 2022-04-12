//
//  MainView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/25.
//  2022 OPass.
//

import SwiftUI
import BetterSafariView

struct MainView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    private let gridItemLayout = Array(repeating: GridItem(spacing: CGFloat(25.0), alignment: Alignment.top), count: 4)
    @State private var selectedFeature: FeatureType? = nil
    
    var body: some View {
        if let eventSettings = eventAPI.eventSettings {
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
                    Text(eventAPI.display_name.en)
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.medium)
                        .padding(.vertical)
                        .foregroundColor(Color("LogoColor"))
                        .frame(width: UIScreen.main.bounds.width * 0.78, height: UIScreen.main.bounds.width * 0.4)
                }
                
                ScrollView {
                    LazyVGrid(columns: gridItemLayout) {
                        ForEach(eventSettings.features, id: \.self) { feature in
                            VStack {
                                GeometryReader { geometry in
                                    TabButton(feature: feature, selectedFeature: $selectedFeature, eventAPI: eventAPI, width: geometry.size.width)
                                        .frame(width: geometry.size.width, height: geometry.size.width)
                                }
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
                                
                                Text(feature.display_text.zh)
                                    .font(.caption2)
                                    .multilineTextAlignment(.center)
                            }
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
                .frame(width: 0, height: 0)
                .opacity(0)
                NavigationLink(
                    tag: FeatureType.ticket,
                    selection: $selectedFeature,
                    destination: { TicketView(eventAPI: eventAPI) }) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                .opacity(0)
                NavigationLink(
                    tag: FeatureType.schedule,
                    selection: $selectedFeature,
                    destination: { ScheduleView(eventAPI: eventAPI) }) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                .opacity(0)
                NavigationLink(
                    tag: FeatureType.announcement,
                    selection: $selectedFeature,
                    destination: {
                        AnnounceView(announcements: eventAPI.eventAnnouncements, refresh: {
                            await eventAPI.loadAnnouncements()
                        })
                    }) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                .opacity(0)
            }
        } else {
            ProgressView("Loading...")
        }
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
                .tabButtonStyle(color: feature.color)
            case .wifi:
                Button(action: {
                    presentingWifiSheet.toggle()
                }) {
                    Image(systemName: feature.symbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(width / 10)
                }
                .tabButtonStyle(color: feature.color)
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
                .tabButtonStyle(color: feature.color)
            default:
                if let urlString = feature.url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) {
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
                                Image(systemName: "exclamationmark.icloud")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(width / 10)
                            }
                        }
                    }
                    .tabButtonStyle(color: feature.color)
                    .safariView(isPresented: $presentingSafariView) {
                        SafariView(
                            url: url,
                            configuration: SafariView.Configuration(
                                entersReaderIfAvailable: false,
                                barCollapsingEnabled: true
                            )
                        )
                        .preferredBarAccentColor(.white)
                        .preferredControlAccentColor(.accentColor)
                        .dismissButtonStyle(.cancel)
                    }
                }
        }
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
            MainView(eventAPI: OPassAPIViewModel.mock().eventList[5])
        }
    }
}
#endif
