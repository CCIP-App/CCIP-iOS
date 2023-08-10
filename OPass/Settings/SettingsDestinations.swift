//
//  SettingsDestinations.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/10.
//

import SwiftUI

enum SettingsDestinations: Destination {
    case appearance
    case developers
}

extension SettingsDestinations {
    @ViewBuilder
    var view: some View {
        switch self {
        case .appearance:
            AppearanceView()
        case .developers:
            DevelopersView()
        }
    }
}
