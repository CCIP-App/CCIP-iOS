//
//  SessionOverView.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/10.
//  2023 OPass.
//

import SwiftUI
import SwiftDate

struct SessionOverView: View {
    let session: Session

    @AppStorage("DimPastSession") var dimPastSession = true
    @AppStorage("PastSessionOpacity") var pastSessionOpacity: Double = 0.4
    @EnvironmentObject private var event: EventStore

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack() {
                Text(event.schedule?.rooms[session.room]?.localized().name ?? session.room)
                    .font(.caption2)
                    .padding(.vertical, 1)
                    .padding(.horizontal, 8)
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(5)

                Text(String(
                    format: "%d:%02d ~ %d:%02d",
                    session.start.hour,
                    session.start.minute,
                    session.end.hour,
                    session.end.minute))
                .foregroundColor(.gray)
                .font(.footnote)
            }
            Text(session.localized().title)
                .lineLimit(2)
        }
        .opacity(session.end.isBeforeDate(DateInRegion(), orEqual: true, granularity: .minute) && dimPastSession ? pastSessionOpacity : 1)
    }
}
