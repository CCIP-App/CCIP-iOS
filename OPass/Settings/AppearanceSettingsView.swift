//
//  AppearanceSettingsView.swift
//  OPass
//
//  Created by Brian Chang on 2025/1/9.
//

import SwiftUI

struct AppearanceSettingsView: View {
    // MARK: - Variables
    @AppStorage("HapticFeedback") private var hapticFeedback = true
    @AppStorage("UserInterfaceStyle") var userInterfaceStyle = UIUserInterfaceStyle.unspecified
    @AppStorage("PastSessionOpacity") var pastSessionOpacity: Double = 0.4
    @AppStorage("DimPastSession") var dimPastSession = true

    // MARK: - Views
    var body: some View {
        Form {
            darkModePicker()

            Section("SCHEDULE") {
                ScheduleOptions()
            }

            Section {
                Button("Reset Appearance Settings", role: .destructive) {
                    reset()
                }
            }
        }
        .analyticsScreen(name: "AppearanceSettingsView")
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Appearance")
    }

    @ViewBuilder
    private func darkModePicker() -> some View {
        Section {
            Picker(selection: $userInterfaceStyle) {
                Text("System").tag(UIUserInterfaceStyle.unspecified)
                Text("Enable").tag(UIUserInterfaceStyle.dark)
                Text("Disable").tag(UIUserInterfaceStyle.light)
            } label: {
                Label {
                    Text("Dark Mode")
                } icon: {
                    Image(systemName: "moon.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.indigo)
                        .symbolEffect(.bounce, value: userInterfaceStyle)
                }
                .labelStyle(CenterLabelStyle())
            }
            .sensoryFeedback(.success, trigger: userInterfaceStyle) { _, _ in hapticFeedback }
            .onChange(of: userInterfaceStyle) {
                UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
                    .overrideUserInterfaceStyle = userInterfaceStyle
            }
        }
    }

    // MARK: - Functions
    private func reset() {
        withAnimation {
            userInterfaceStyle = .unspecified
            pastSessionOpacity = 0.4
            dimPastSession = true
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
                .overrideUserInterfaceStyle = userInterfaceStyle
        }
    }
}

private struct ScheduleOptions: View {
    @AppStorage("DimPastSession") var dimPastSession = true
    @AppStorage("PastSessionOpacity") var pastSessionOpacity: Double = 0.4
    let sampleTimeHour: [Int] = [
        Calendar.current.component(.hour, from: Date.now.advanced(by: -3600)),
        Calendar.current.component(.hour, from: Date.now),
        Calendar.current.component(.hour, from: Date.now.advanced(by: 3600)),
        Calendar.current.component(.hour, from: Date.now.advanced(by: 7200))
    ]

    var body: some View {
        if dimPastSession {
            List {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text("OPass Room 1")
                                .font(.caption2)
                                .padding(.vertical, 1)
                                .padding(.horizontal, 8)
                                .foregroundColor(.white)
                                .background(.blue)
                                .cornerRadius(5)
                            
                            Text(String(format: "%d:00 ~ %d:00", sampleTimeHour[0], sampleTimeHour[1]))
                                .foregroundColor(.gray)
                                .font(.footnote)
                        }
                        Text("Past Session")
                            .lineLimit(2)
                    }
                    
                    .opacity(self.dimPastSession ? self.pastSessionOpacity : 1)
                    .padding(.horizontal, 5)
                    .padding(10)
                    Spacer()
                }
                .background(.sectionBackground)
                .cornerRadius(8)
                
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text("OPass Room 2")
                                .font(.caption2)
                                .padding(.vertical, 1)
                                .padding(.horizontal, 8)
                                .foregroundColor(.white)
                                .background(.blue)
                                .cornerRadius(5)
                            
                            Text(String(format: "%d:00 ~ %d:00", sampleTimeHour[2], sampleTimeHour[3]))
                                .foregroundColor(.gray)
                                .font(.footnote)
                        }
                        Text("Future Session")
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 5)
                    .padding(10)
                    Spacer()
                }
                .background(.sectionBackground)
                .cornerRadius(8)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 6, trailing: 10))
        }

        Toggle("Dim Past Sessions", isOn: $dimPastSession.animation())

        if dimPastSession {
            Slider(
                value: $pastSessionOpacity.animation(),
                in: 0.1...0.9,
                onEditingChanged: { _ in },
                minimumValueLabel: Image(systemName: "sun.min"),
                maximumValueLabel: Image(systemName: "sun.min.fill"),
                label: {}
            )
        }
    }
}

#Preview {
    NavigationView {
        AppearanceSettingsView()
    }
}
