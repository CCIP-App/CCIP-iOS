//
//  EventListView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//

import SwiftUI

struct EventListView: View {
    
    @EnvironmentObject var OPassAPI: OPassAPIModels
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(OPassAPI.eventList, id: \.event_id) { list in
                    Button(list.event_id) {
                        OPassAPI.currentEvent = list
                    }
                }
            }
        }
        .task {
            await OPassAPI.loadEventList()
        }
    }
}

#if DEBUG
struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
            .environmentObject(OPassAPIModels.mock())
    }
}
#endif
