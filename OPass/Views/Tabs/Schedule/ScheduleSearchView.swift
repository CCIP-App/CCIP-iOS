//
//  SearchScheduleView.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/4.
//

import SwiftUI
import SwiftDate
import OrderedCollections

struct SearchScheduleView: View {
    let schedule: Schedule
    @EnvironmentObject private var event: EventStore
    
    @State private var searchText = ""
    //@State private var searchActive = true //TODO: Will be implement in iOS 17
    
    private let weekDayName: [LocalizedStringKey] = ["SUN", "MON", "TUE", "WEN", "THR", "FRI", "SAT"]
    
    private var searchResult: [OrderedDictionary<DateInRegion, [Session]>] {
        let texts = searchText.tirm().components(separatedBy: " ").compactMap { text in
            let text = text.tirm()
            return text.isEmpty ? nil : text
        }
        if texts.isEmpty { return schedule.sessions } //TODO: Tokens
        return schedule.sessions.compactMap { session in
            var session = session
            for (key, value) in session.elements {
                let value = value.filter { session in
                    for text in texts {
                        if session.en.title.range(of: text, options: .caseInsensitive) != nil ||
                            session.zh.title.range(of: text, options: .caseInsensitive) != nil {
                            return true
                        }
                    }
                    return false
                }
                if value.isEmpty { session[key] = nil }
                else { session[key] = value }
            }
            return session.isEmpty ? nil : session
        }
    }
    
    var body: some View {
        Group {
            //TODO: Tokens
            Form {
                ForEach(searchResult, id: \.self) { result in
                    ForEach(result.elements.indices, id: \.self) { index in
                        Section {
                             ForEach(result.values[index]) { session in
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
                                Text("\(result.keys[index].month)/\(result.keys[index].day) ") +
                                Text(weekDayName[result.keys[index].weekday - 1])
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
