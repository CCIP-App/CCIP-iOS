//
//  FeatureDestinations.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/9.
//

import SwiftUI

enum FeatureDestinations: Destination {
    case fastpass
    case schedule
    case ticket
    case announcement
    case webview
}

extension FeatureDestinations {
    @ViewBuilder
    var view: some View {
        switch self {
        case .fastpass:
            FastpassView()
        case .schedule:
            ScheduleContainerView()
        case .ticket:
            TicketView()
        case .announcement:
            AnnouncementView()
        case .webview:
            EmptyView() // TODO: Custom WebView
        }
    }
}
