//
//  SessionView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//

import SwiftUI

struct SessionView: View {
    
    @ObservedObject var event: EventViewModel
    
    var body: some View {
        //Only for API Testing
        ScrollView {
            VStack {
                if let data = event.eventSession {
                    //simply flatten here
                    ForEach(data.sessions.flatMap { $0 }, id: \.self) { session in
                        Text(session.zh.title)
                        Divider()
                    }
                }
            }
        }
        .task {
            await event.loadEventSession()
        }
    }
}

#if DEBUG
struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView(event: OPassAPIViewModel.mock().eventList[5])
            .environmentObject(OPassAPIViewModel.mock())
    }
}
#endif
