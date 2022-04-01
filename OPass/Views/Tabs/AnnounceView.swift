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
    @Environment(\.openURL) var openURL
    
    var body: some View {
        //Only for API Testing
        Form {
            ForEach(announcements, id: \.datetime) { announcement in
                Button(action: {
                    if let urlString = announcement.url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) {
                        openURL(url)
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(announcement.msg_zh).foregroundColor(.black)
                            Text(String(format: "%d/%d %d:%02d", announcement.datetime.month, announcement.datetime.day, announcement.datetime.hour, announcement.datetime.minute))
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if let _ = announcement.url {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .navigationTitle("Announcement")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable(action: refresh)
        .task(refresh)
    }
}

struct AnnounceView_Previews: PreviewProvider {
    static var previews: some View {
        AnnounceView(announcements: loadJson(filename: "announcementSample.json")) {}
    }
}
