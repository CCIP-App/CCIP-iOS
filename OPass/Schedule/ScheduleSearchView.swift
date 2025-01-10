//
//  ScheduleSearchView.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/4.
//

import OrderedCollections
import SwiftDate
import SwiftUI

struct ScheduleSearchView: View {
    let schedule: Schedule
    @EnvironmentObject private var event: EventStore
    @EnvironmentObject private var router: Router

    @State private var searchText = ""
    @State private var searchActive = true

    private let weekDayName: [LocalizedStringKey] = [
        "SUN", "MON", "TUE", "WEN", "THR", "FRI", "SAT"
    ]

    private var searchResult: [OrderedDictionary<DateInRegion, [Session]>] {
        let texts = searchText.tirm().components(separatedBy: " ").compactMap { text in
            let text = text.tirm()
            return text.isEmpty ? nil : text
        }
        if texts.isEmpty { return schedule.sessions }  //TODO: Tokens
        return schedule.sessions.compactMap { session in
            var session = session
            for (key, value) in session.elements {
                let value = value.filter { session in
                    for text in texts {
                        if session.en.title.range(of: text, options: .caseInsensitive) == nil
                            && session.zh.title.range(of: text, options: .caseInsensitive) == nil
                        {
                            return false
                        }
                    }
                    return true
                }
                if value.isEmpty { session[key] = nil } else { session[key] = value }
            }
            return session.isEmpty ? nil : session
        }
    }

    private var searchIsEmpty: Bool {
        guard !searchResult.isEmpty else { return true }
        for daySessions in searchResult {
            if daySessions.isEmpty { return true }
        }
        return false
    }

    var body: some View {
        Group {
            //TODO: Tokens
            if !searchIsEmpty {
                Form {
                    ForEach(searchResult, id: \.self) { result in
                        ForEach(result.elements.indices, id: \.self) { index in
                            Section {
                                ForEach(result.values[index]) { session in
                                    Button {
                                        self.router.forward(ScheduleDestinations.session(session))
                                    } label: {
                                        SessionOverView(session: session)
                                    }
                                }
                            } header: {
                                if index == 0 {
                                    Text("\(result.keys[index].month)/\(result.keys[index].day) ")
                                        + Text(weekDayName[result.keys[index].weekday - 1])
                                }
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .searchable(
            text: $searchText,
            isPresented: $searchActive,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search Title"
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search")
    }
}
