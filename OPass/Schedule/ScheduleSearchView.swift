//
//  ScheduleSearchView.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/4.
//

import SwiftUI
import SwiftDate
import OrderedCollections

struct ScheduleSearchView: View {
    let schedule: Schedule
    @EnvironmentObject private var event: EventStore
    
    @State private var searchText = ""
    @State private var searchActive = true
    
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
                        if session.en.title.range(of: text, options: .caseInsensitive) == nil &&
                            session.zh.title.range(of: text, options: .caseInsensitive) == nil {
                            return false
                        }
                    }
                    return true
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
                                 NavigationLink(value: ScheduleDestinations.session(session)) {
                                     SessionOverView(session: session)
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
            isPresented: $searchActive,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Title"
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search")
    }
}
