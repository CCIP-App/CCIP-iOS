//
//  SessionView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//

import SwiftUI

struct SessionView: View {
    
    @EnvironmentObject var OPassAPI: OPassAPIModels
    
    var body: some View {
        //Only for API Testing
        ScrollView {
            VStack {
                ForEach(OPassAPI.eventSession.sessions, id: \.self) { session in
                    Text(session.zh.title)
                    
                    Divider()
                }
            }
        }
        .task {
            await OPassAPI.loadEventSession()
        }
    }
}

#if DEBUG
struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
            .environmentObject(OPassAPIModels.mock())
    }
}
#endif
