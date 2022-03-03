//
//  ContentView.swift
//  OPass
//
//  Created by 張智堯 on 2022/2/28.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var OPassAPI: OPassAPIViewModel

    var body: some View {
        //Only for API Testing
        VStack {
            if let event = OPassAPI.currentEvent {
                TestTabsView(event: event)
                    .environmentObject(OPassAPI)
            } else {
                EventListView()
                    .environmentObject(OPassAPI)
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
