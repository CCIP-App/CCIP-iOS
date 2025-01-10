//
//  GeneralSettingsView.swift
//  OPass
//
//  Created by Brian Chang on 2025/1/9.
//  2025 OPass.
//

import SwiftUI

struct GeneralSettingsView: View {
    // MARK: - Variables
    @AppStorage("HapticFeedback") private var hapticFeedback = true
    @AppStorage("AutoSelectScheduleDay") private var autoSelectScheduleDay = true
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Views
    var body: some View {
        Form {
            Section {
                Toggle("Haptic Feedback", systemImage: "hand.rays", isOn: $hapticFeedback)
                    .symbolRenderingMode(.hierarchical)

                Toggle("Auto-Select Schedule Day", systemImage: "scroll", isOn: $autoSelectScheduleDay)
            }

            Section {
                Button("Reset General Settings", role: .destructive) {
                    reset()
                }
            }
        }
        .analyticsScreen(name: "GeneralSettingsView")
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("General")
    }

    // MARK: - Functions
    private func reset() {
        hapticFeedback = true
        autoSelectScheduleDay = true
    }
}

#Preview {
    NavigationView {
        GeneralSettingsView()
    }
}
