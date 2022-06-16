//
//  ContentView.swift
//  OPass
//
//  Created by 張智堯 on 2022/2/28.
//  2022 OPass.
//

import SwiftUI
import FirebaseDynamicLinks

struct ContentView: View {
    
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    @State var handlingURL = false
    @State var isShowingEventList = false

    var body: some View {
        NavigationView {
            VStack {
                if OPassAPI.currentEventID == nil {
                    VStack {}
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear(perform: {
                            isShowingEventList.toggle()
                        })
                } else if OPassAPI.currentEventID != OPassAPI.currentEventAPI?.event_id {
                    ProgressView(LocalizedStringKey("Loading"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .task {
                            await OPassAPI.loadCurrentEventAPI()
                        }
                } else {
                    MainView(eventAPI: OPassAPI.currentEventAPI!)
                }
            }
            .background(Color("SectionBackgroundColor"))
            .sheet(isPresented: $isShowingEventList) {
                EventListView()
            }
            .navigationTitle("OPass")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    SFButton(systemName: "rectangle.stack") {
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
