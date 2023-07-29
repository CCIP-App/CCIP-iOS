//
//  SearchScheduleView.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/4.
//

import SwiftUI

struct SearchScheduleView: View {
    let schedule: Schedule
    @EnvironmentObject private var event: EventService
    
    @State private var searchText = ""
    //@State private var searchActive = true //TODO: Will be implement in iOS 17
    
    private let weekDayName: [LocalizedStringKey] = ["SUN", "MON", "TUE", "WEN", "THR", "FRI", "SAT"]
    
    private var searchResult: [SessionModel] {
        let texts = searchText.tirm().components(separatedBy: " ").compactMap { text in
            let text = text.tirm()
            return text.isEmpty ? nil : text
        }
        if texts.isEmpty { return schedule.sessions } //TODO: Tokens
        return schedule.sessions.compactMap { session in
            var session = session
            session.header = session.header.filter { header in
                guard var datas = session.data[header] else { return false }
                datas = datas.filter { data in
                    for text in texts {
                        if data.en.title.range(of: text, options: .caseInsensitive) != nil ||
                            data.zh.title.range(of: text, options: .caseInsensitive) != nil {
                            return true
                        }
                    }
                    return false
                }
                session.data[header] = datas.isEmpty ? nil : datas
                return !datas.isEmpty
            }
            return session.header.isEmpty ? nil : session
        }
    }
    
    var body: some View {
        Group {
            //TODO: Tokens
            Form {
                ForEach(searchResult, id: \.self) { result in
                    ForEach(Array(result.header.enumerated()), id: \.element) { index, header in
                        Section {
                            ForEach(result.data[header]!, id: \.id) { session in
                                NavigationLink(value: Router.mainDestination.sessionDetail(session)) {
                                    SessionOverView(
                                        room: schedule.rooms[session.room]?.localized().name ?? session.room,
                                        start: session.start,
                                        end: session.end,
                                        title: session.localized().title
                                    )
                                }
                            }
                        } header: {
                            if index == 0 {
                                Text("\(result.header[0].month)/\(result.header[0].day) ") +
                                Text(weekDayName[result.header[0].weekday - 1])
                            }
                        }

                    }
                }
            }
        }
        .searchable(
            text: $searchText,
            //isPresented: $searchActive, //TODO: Will be avaiable in iOS 17
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Title"
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search")
    }
}
