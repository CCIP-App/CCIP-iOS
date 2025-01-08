//
//  SettingsView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//  2025 OPass.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var store: OPassStore

    var body: some View {
        VStack {
            Form {
                AppIconSection()

                GeneralSection()

                AboutSection()

                AdvancedSection()
            }
        }
        .navigationDestination(for: SettingsDestinations.self) { $0.view }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Settings")
    }
}

private struct AppIconSection: View {
    var body: some View {
        Section {
            HStack {
                Spacer()
                VStack {
                    Image("InAppIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width * 0.28)
                        .clipShape(Circle())
                    Text("OPass")
                }
                .padding(5)
                Spacer()
            }
        }
    }
}

private struct GeneralSection: View {
    var body: some View {
        Section(header: Text("GENERAL")) {
            NavigationLink(value: SettingsDestinations.appearance) {
                Label {
                    Text("Appearance")
                } icon: {
                    Image(systemName: "circle.lefthalf.filled")
                        .padding(4)
                        .foregroundColor(.white)
                        .background(Color(red: 89 / 255, green: 169 / 255, blue: 214 / 255))
                        .cornerRadius(7)
                }
            }
        }
    }
}

private struct AboutSection: View {

    @Environment(\.colorScheme) var colorScheme
    private let CCIPWebsiteURL = URL(string: "https://opass.app")!
    private let CCIPGitHubURL = URL(string: "https://github.com/CCIP-App")!
    private let CCIPPolicyURL = URL(string: "https://opass.app/privacy-policy.html")!

    var body: some View {
        Section(header: Text("ABOUT")) {
            VStack(alignment: .leading) {
                Text("Version")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Text(
                    String("\(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)")
                        + String(" (Build \(Bundle.main.infoDictionary!["CFBundleVersion"]!))")
                )
                .font(.subheadline)
                .foregroundColor(.gray)
            }

            Button {
                Constants.openInAppSafari(forURL: CCIPWebsiteURL, style: colorScheme)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("OfficialWebsite")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Text(CCIPWebsiteURL.absoluteString)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Image("external-link")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(width: UIScreen.main.bounds.width * 0.045)
                }
            }

            Button {
                Constants.openInAppSafari(forURL: CCIPGitHubURL, style: colorScheme)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("GitHub")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Text(CCIPGitHubURL.absoluteString)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Image("external-link")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(width: UIScreen.main.bounds.width * 0.045)
                }
            }

            Button {
                Constants.openInAppSafari(forURL: CCIPPolicyURL, style: colorScheme)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("PrivacyPolicy")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Text(CCIPPolicyURL.absoluteString)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Image("external-link")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(width: UIScreen.main.bounds.width * 0.045)
                }
            }

            NavigationLink("Developers", value: SettingsDestinations.developers)
        }
    }
}

private struct AdvancedSection: View {
    var body: some View {
        Section(header: Text("ADVANCED")) {
            NavigationLink(destination: AdvancedOptionView()) {
                Image(systemName: "hammer")
                Text("AdvancedOption")
            }
        }
    }
}

private struct AdvancedOptionView: View {
    @AppStorage("UserInterfaceStyle") private var interfaceStyle: UIUserInterfaceStyle =
        .unspecified
    @AppStorage("AutoAdjustTicketBirghtness") private var autoAdjustTicketBirghtness = true
    @AppStorage("AutoSelectScheduleDay") private var autoSelectScheduleDay = true
    @AppStorage("PastSessionOpacity") private var pastSessionOpacity = 0.4
    @AppStorage("DimPastSession") private var dimPastSession = true
    @AppStorage("NotifiedAlert") private var notifiedAlert = true
    private var keyStore = NSUbiquitousKeyValueStore()
    @EnvironmentObject var store: OPassStore

    var body: some View {
        Form {
            Section("FEATURE") {
                Toggle("AutoSelectScheduleDay", isOn: $autoSelectScheduleDay)
            }

            Button("Reset All", role: .destructive) {
                resetAll()
            }

            Button("ClearCacheData", role: .destructive) {
                keyStore.removeObject(forKey: "EventStore")
                keyStore.synchronize()
            }
        }
        .navigationTitle("AdvancedOption")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func resetAll() {
        interfaceStyle = .unspecified
        autoAdjustTicketBirghtness = true
        autoSelectScheduleDay = true
        pastSessionOpacity = 0.4
        dimPastSession = true
        notifiedAlert = true
    }
}

#if DEBUG
    struct SettingsView_Previews: PreviewProvider {
        static var previews: some View {
            SettingsView()
        }
    }
#endif
