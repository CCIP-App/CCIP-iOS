//
//  MainView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/25.
//

import SwiftUI
import BetterSafariView

struct MainView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    private let gridItemLayout = Array(repeating: GridItem(spacing: CGFloat(25.0), alignment: Alignment.top), count: 4)
    
    
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
                                    TabButton(feature: feature, eventAPI: eventAPI)
                                        .frame(width: geometry.size.width, height: geometry.size.width)
                                }
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
                                
                                Text(feature.display_text.zh)
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        } else {
            ProgressView("Loading...")
        }
    }
}

struct TabButton: View {
    
    let buttonColor: [FeatureType : Color] = [.fastpass : .blue, .ticket : .purple, .schedule : .green, .announcement : .orange, .wifi : .brown, .telegram : .green, .im : .purple, .puzzle : .blue, .venue : .blue, .sponsors : .yellow, .staffs : .gray, .webview : .purple]
    let buttonSymbolName: [FeatureType : String] = [.fastpass : "wallet.pass", .ticket : "ticket", .schedule : "scroll", .announcement : "megaphone", .wifi : "wifi", .telegram : "paperplane", .im : "bubble.right", .puzzle : "puzzlepiece.extension", .venue : "map", .sponsors : "banknote", .staffs : "person.3"]
    @Environment(\.openURL) var openURL
    let feature: FeatureModel
    @ObservedObject var eventAPI: EventAPIViewModel
    @State private var safariViewURL = ""
    @State private var presentingSafariView = false
    //fastpass, ticket, schedule, announcement, wifi, telegram, im, puzzle, venue, sponsors, staffs, webview
    var body: some View {
        switch(feature.feature) {
        case .fastpass:
            NavigationLink(destination: FastpassView(eventAPI: eventAPI)) {
                Image(systemName: "wallet.pass")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(CGFloat(8))
            }
            .tabButtonStyle(color: buttonColor[.fastpass]!)
        case .ticket:
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "ticket")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(CGFloat(8))
            }
            .tabButtonStyle(color: buttonColor[.ticket]!)
        case .schedule:
            NavigationLink(destination: ScheduleView(eventAPI: eventAPI)) {
                Image(systemName: "scroll")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(CGFloat(8))
            }
            .tabButtonStyle(color: buttonColor[.schedule]!)
        case .announcement:
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "megaphone")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(CGFloat(8))
            }
            .tabButtonStyle(color: buttonColor[.announcement]!)
        case .wifi:
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "wifi")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(CGFloat(8))
            }
            .tabButtonStyle(color: buttonColor[.wifi]!)
        case .telegram:
            Button(action: {
                if let telegramURLString = feature.url, let telegramURL = URL(string: telegramURLString) {
                    openURL(telegramURL)
                }
            }) {
                Image(systemName: "paperplane")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(CGFloat(8))
            }
            .tabButtonStyle(color: buttonColor[.telegram]!)
        default:
            if let urlString = feature.url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) {
                Button(action: {
                    presentingSafariView.toggle()
                }) {
                    if feature.feature != .webview {
                        Image(systemName: buttonSymbolName[feature.feature] ?? "exclamationmark.icloud")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(CGFloat(8))
                    } else {
                        if let iconData = feature.iconData, let iconUIImage = UIImage(data: iconData) {
                            Image(uiImage: iconUIImage)
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(CGFloat(8))
                                
                        } else {
                            Image(systemName: "exclamationmark.icloud")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(CGFloat(8))
                        }
                    }
                }
                .tabButtonStyle(color: buttonColor[feature.feature] ?? .purple)
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

extension Double {
    var cgFloat: CGFloat { CGFloat(self) }
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
