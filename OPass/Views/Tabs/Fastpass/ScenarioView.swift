//
//  ScenarioView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
//

import SwiftUI

struct ScenarioView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    @State var isShowingLogOutAlert = false
    
    var body: some View {
        //Only for API Testing
        VStack {
            VStack {
                Text("Get Scenario Status Scuess")
                Text("Current Token")
                Text(eventAPI.eventScenarioStatus?.token ?? "Error")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Fast Pass").font(.headline)
                    Text(eventAPI.display_name.en).font(.caption).foregroundColor(.gray)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isShowingLogOutAlert.toggle()
                }) { Text("Sign Out").foregroundColor(.red) }
            }
        }
        .alert("Confirm sign out?", isPresented: $isShowingLogOutAlert) {
            Button("Sign Out", role: .destructive) {
                eventAPI.isLogin = false
                eventAPI.accessToken = nil
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
}

#if DEBUG
struct ScenarioView_Previews: PreviewProvider {
    static var previews: some View {
        ScenarioView(eventAPI: OPassAPIViewModel.mock().eventList[5])
    }
}
#endif
