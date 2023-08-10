//
//  ScheduleDestinations.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/10.
//

import SwiftUI

enum ScheduleDestinations: Destination {
    case search(Schedule)
    case session(Session)
}

extension ScheduleDestinations {
    @ViewBuilder
    var view: some View {
        switch self {
        case .search(let schedule):
            ScheduleSearchView(schedule: schedule)
        case .session(let session):
            SessionView(session: session)
        }
    }
}
