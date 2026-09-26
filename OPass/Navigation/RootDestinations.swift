//
//  RootDestinations.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/8.
//  2026 OPass.
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
