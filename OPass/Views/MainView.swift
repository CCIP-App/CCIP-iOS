//
//  MainView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/25.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    
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
                        .font(.largeTitle)
                        .padding()
                        .foregroundColor(Color("LogoColor"))
                        .frame(width: UIScreen.main.bounds.width * 0.78, height: UIScreen.main.bounds.width * 0.4)
                }
                
                ScrollView {
                    ForEach(eventSettings.features, id: \.self) { feature in
                        VStack() {
                            TabButton(feature: feature, eventAPI: eventAPI)
                                .frame(width: 70, height: 70)
                                .buttonStyle(.bordered)
                                .controlSize(.large)
                            
                            Text(feature.display_text.zh)
                                .font(.caption2)
                        }
                    }
                }
            }
        } else {
            ProgressView("Loading...")
        }
    }
}

struct TabButton: View {
    
    let buttonSize: CGFloat = 50
    @State var feature: FeatureModel
    @ObservedObject var eventAPI: EventAPIViewModel
    //fastpass, ticket, schedule, announcement, wifi, telegram, im, puzzle, venue, sponsors, staffs, webview
    var body: some View {
        VStack {
            switch(feature.feature) {
            case .fastpass:
                NavigationLink(destination: FastpassView(eventAPI: eventAPI)) {
                    Image(systemName: "wallet.pass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tint(.blue)
            case .ticket:
                NavigationLink(destination: EmptyView()) {
                    Image(systemName: "ticket")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tint(.purple)
            case .schedule:
                NavigationLink(destination: ScheduleView(eventAPI: eventAPI)) {
                    Image(systemName: "newspaper")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tint(.green)
            case .announcement:
                NavigationLink(destination: EmptyView()) {
                    Image(systemName: "megaphone")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tint(.orange)
            case .wifi:
                NavigationLink(destination: EmptyView()) {
                    Image(systemName: "wifi")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tint(.brown)
            case .telegram:
                NavigationLink(destination: EmptyView()) {
                    Image(systemName: "paperplane")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tint(.green)
            case .im:
                NavigationLink(destination: EmptyView()) {
                    Image(systemName: "bubble.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tint(.purple)
            case .puzzle:
                NavigationLink(destination: EmptyView()) {
                    Image(systemName: "puzzlepiece.extension")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tint(.blue)
            case .venue:
                NavigationLink(destination: EmptyView()) {
                    Image(systemName: "map")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tint(.blue)
            case .sponsors:
                NavigationLink(destination: EmptyView()) {
                    Image(systemName: "dollarsign.square")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tint(.yellow)
            case .staffs:
                NavigationLink(destination: EmptyView()) {
                    Image(systemName: "person.3.sequence")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tint(.gray)
            default: //WebView
                NavigationLink(destination: EmptyView()) {
                    if let iconData = feature.iconData, let iconUIImage = UIImage(data: iconData) {
                        Image(uiImage: iconUIImage)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            
                    } else {
                        Image(systemName: "exclamationmark.icloud")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .tint(.purple)
            }
        }
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(eventAPI: OPassAPIViewModel.mock().eventList[5])
    }
}
#endif
