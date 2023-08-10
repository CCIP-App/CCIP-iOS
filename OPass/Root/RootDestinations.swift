//
//  RootRoutes.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/8.
//

import SwiftUI

enum RootDestinations: Destination {
    case settings
}

extension RootDestinations {
    @ViewBuilder
    var view: some View {
        switch self {
        case .settings:
            SettingsView()
        }
    }
}
