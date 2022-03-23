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
    @State var choosingEvent = false

    var body: some View {
        NavigationView {
            Text("a")
                .environmentObject(OPassAPI)
                .sheet(isPresented: $choosingEvent) {
                    EventListView()
                        .environmentObject(OPassAPI)
                }
                .navigationTitle("OPass")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        SFButton(systemName: "person.crop.rectangle.stack") {
                            choosingEvent = true
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        SFButton(systemName: "gearshape") {
                            
                        }
                    }
                }
        }
        .onOpenURL(perform: handleURL)
        
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
