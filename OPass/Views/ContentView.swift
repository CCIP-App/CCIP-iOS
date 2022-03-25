//
//  ContentView.swift
//  OPass
//
//  Created by 張智堯 on 2022/2/28.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    @State var handlingURL = false
    @State var isShowingEventList = false

    var body: some View {
        NavigationView {
            VStack {
                if let eventAPI = OPassAPI.currentEventAPI {
                    MainView(eventAPI: eventAPI)
                } else {
                    SFButton(systemName: "person.crop.rectangle.stack") {
                        isShowingEventList.toggle()
                    }
                    .tint(.blue)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Text("Select Event")
                        .font(.caption2)
                }
            }
            .environmentObject(OPassAPI)
            .sheet(isPresented: $isShowingEventList) {
                EventListView()
                    .environmentObject(OPassAPI)
            }
            .navigationTitle("OPass")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    SFButton(systemName: "person.crop.rectangle.stack") {
                        isShowingEventList.toggle()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .onOpenURL(perform: handleURL)
        .onAppear(perform: {
            if OPassAPI.currentEventAPI == nil {
                isShowingEventList.toggle()
            }
        })
        
//        //Only for API Testing
//        VStack {
//            if handlingURL {
//                ProgressView {
//                    Text("Logining in")
//                }
//            } else {
//                if let eventAPI = OPassAPI.currentEventAPI {
//                    TestTabsView(eventAPI: eventAPI)
//                        .environmentObject(OPassAPI)
//                } else {
//                    EventListView()
//                        .environmentObject(OPassAPI)
//                }
//            }
//        }
//        .onOpenURL(perform: handleURL)
    }
    
    func handleURL(url: URL) {
        handlingURL = true
        Task {
            let (eventId, token) = parseURL(url)
            await OPassAPI.loginEvent(eventId, withToken: token)
            handlingURL = false
        }
    }
    
    func parseURL(_ url: URL) -> (String, String) {
        //TODO: implement it when dynamic link can work and we can see the real URL
        return ("COSCUP_2019", "7679f08f7eaeef5e9a65a1738ae2840e")
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(OPassAPIViewModel.mock())
    }
}
#endif
