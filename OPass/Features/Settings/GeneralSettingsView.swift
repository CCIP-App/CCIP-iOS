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
                Toggle(isOn: $hapticFeedback) {
                    Label {
                        Text("Haptic Feedback")
                    } icon: {
                        Image(systemName: "hand.rays.fill")
                            .resizable()
                            .scaledToFit()
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(colorScheme == .dark ? .white : .black, .blue)
                    }
                    .labelStyle(CenterLabelStyle())
                }

                Toggle(isOn: $autoSelectScheduleDay) {
                    Label {
                        Text("Auto-Select Schedule Day")
                    } icon: {
                        Image(systemName: "calendar.badge.checkmark")
                            .resizable()
                            .scaledToFit()
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.blue, colorScheme == .dark ? .white : .black)
                    }
                    .labelStyle(CenterLabelStyle())
                }
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
