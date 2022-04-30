//
//  ContentView.swift
//  OPass
//
//  Created by 張智堯 on 2022/2/28.
//  2022 OPass.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    @State var handlingURL = false
    @State var isShowingEventList = false

    var body: some View {
        NavigationView {
            VStack {
                if OPassAPI.currentEventID == nil {
                    VStack {}
                        .onAppear(perform: {
                            isShowingEventList.toggle()
                        })
                } else if OPassAPI.currentEventID != OPassAPI.currentEventAPI?.event_id {
                    ProgressView(LocalizedStringKey("Loading"))
                        .task {
                            await OPassAPI.loadCurrentEventAPI()
                        }
                } else {
                    MainView(eventAPI: OPassAPI.currentEventAPI!)
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
