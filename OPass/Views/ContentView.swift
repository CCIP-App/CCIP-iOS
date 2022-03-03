//
//  ContentView.swift
//  OPass
//
//  Created by 張智堯 on 2022/2/28.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var OPassAPI: OPassAPIModels

    var body: some View {
        VStack {
            if let event = OPassAPI.currentEvent {
                EventView(event: event)
            }
            EventListView()
                .environmentObject(OPassAPI)
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(OPassAPIModels.mock())
    }
}
#endif
