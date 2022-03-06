//
//  AnnounceView.swift
//  OPass
//
//  Created by secminhr on 2022/3/5.
//

import SwiftUI

struct AnnounceView: View {
    
    var announcements: [AnnouncementModel]
    var refresh: @Sendable () async -> Void
    
    var body: some View {
        //Only for API Testing
        List(announcements, id: \.datetime) { announcement in
            Text(announcement.msg_zh)
                .padding()
        }
        .refreshable(action: refresh)
        .task(refresh)
    }
}

struct AnnounceView_Previews: PreviewProvider {
    static var previews: some View {
        AnnounceView(announcements: loadJson(filename: "announcementSample.json")) {}
    }
}
