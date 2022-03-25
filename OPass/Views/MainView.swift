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
                        .foregroundColor(Color.purple)
                        .frame(width: UIScreen.main.bounds.width * 0.78, height: UIScreen.main.bounds.width * 0.4)
                } else {
                    Text(eventSettings.display_name.zh)
                        .font(.title)
                        .padding()
                        .foregroundColor(Color.purple)
                }
                
                ScrollView {
                    ForEach(eventSettings.features, id: \.self) { feature in
                        VStack() {
                            TabButton(feature: feature)
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
    //fastpass, ticket, schedule, announcement, wifi, telegram, im, puzzle, venue, sponsors, staffs, webview
    var body: some View {
        switch(feature.feature) {
        case .fastpass:
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "wallet.pass")
            }
            .tint(.blue)
        case .ticket:
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "ticket")
            }
            .tint(.purple)
        case .schedule:
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "newspaper")
            }
            .tint(.green)
        case .announcement:
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "megaphone")
            }
            .tint(.orange)
        case .wifi:
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "wifi")
            }
            .tint(.brown)
        case .telegram:
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "paperplane")
            }
            .tint(.green)
        case .im:
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "bubble.right")
            }
            .tint(.purple)
        case .puzzle:
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "puzzlepiece.extension")
            }
            .tint(.blue)
        case .venue:
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "map")
            }
            .tint(.blue)
        case .sponsors:
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "dollarsign.square")
            }
            .tint(.yellow)
        case .staffs:
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "person.3.sequence")
            }
            .tint(.gray)
        default: //WebView
            NavigationLink(destination: EmptyView()) {
                if let iconData = feature.iconData, let iconUIImage = UIImage(data: iconData) {
                    Image(uiImage: iconUIImage)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.2, height: UIScreen.main.bounds.width * 0.2)
                } else {
                    Image(systemName: "exclamationmark.icloud")
                }
            }
            .tint(.purple)
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
