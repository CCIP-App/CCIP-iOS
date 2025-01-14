//
//  SettingsView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//  2025 OPass.
//

import StoreKit
import SwiftUI

struct SettingsView: View {
    // MARK: - Variables
    @EnvironmentObject var store: OPassStore
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.requestReview) private var requestReview
    @AppStorage("HapticFeedback") private var hapticFeedback = true
    @AppStorage("RequestReviewVersion") private var requestReviewVersion = ""
    @State private var safariUrl: URL?
    @State private var requestReviewTrigger = false
    private let websiteURL = URL(string: "https://opass.app")!
    private let gitHubURL = URL(string: "https://github.com/CCIP-App/CCIP-iOS")!
    private let policyURL = URL(string: "https://opass.app/privacy-policy.html")!

    // MARK: - Views
    var body: some View {
        Form {
            introductionSection()

            generalSection()

            aboutSection()

            bottomText()
        }
        .safariViewSheet(url: $safariUrl) { print("Hello") }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Settings")
        .listSectionSpacing(0)
    }

    @ViewBuilder
    private func introductionSection() -> some View {
        VStack(spacing: 5) {
            Image(.inAppIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 70)
                .clipShape(.rect(cornerRadius: 15.6))  // radius = width * 2/9

            Text("OPass")
                .font(.title2)
                .bold()

            Text("Open Pass & All Pass - A Community Checkin with Interactivity Project for iOS")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 5)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 5)
    }

    @ViewBuilder
    private func generalSection() -> some View {
        Section("GENERAL") {
            generalSectionButton(
                "General",
                iconSystemName: "gear",
                iconForegroundStyle: .gray
            ) { GeneralSettingsView() }

            generalSectionButton(
                "Appearance",
                iconSystemName: "sun.max.fill",
                iconForegroundStyle: .yellow
            ) { AppearanceSettingsView() }
        }
    }

    @ViewBuilder
    private func generalSectionButton<S, V>(
        _ title: String,
        iconSystemName: String,
        iconForegroundStyle: S,
        destination: () -> V
    ) -> some View where S: ShapeStyle, V: View {
        NavigationLink(destination: destination) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: iconSystemName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(iconForegroundStyle)
            }
            .labelStyle(CenterLabelStyle())
        }
    }

    @ViewBuilder
    private func aboutSection() -> some View {
        Section("ABOUT") {
            aboutSectionButton(
                "Official Website",
                urlText: websiteURL.absoluteString,
                iconSystemName: "safari",
                iconRenderingMode: .hierarchical,
                iconColor: .primary
            ) { safariUrl = websiteURL }

            aboutSectionButton(
                "Source Code",
                urlText: gitHubURL.absoluteString,
                icon: .githubMark,
                iconColor: colorScheme == .light ? .black : .white
            ) { safariUrl = gitHubURL }

            aboutSectionButton(
                "Privacy Policy",
                urlText: policyURL.absoluteString,
                iconSystemName: "doc.plaintext",
                iconColor: .gray
            ) { safariUrl = policyURL }
        }
        .sensoryFeedback(.selection, trigger: safariUrl != nil) { $1 && hapticFeedback }
    }

    @ViewBuilder
    private func aboutSectionButton<S>(
        _ title: String,
        urlText: String,
        icon: ImageResource? = nil,
        iconSystemName: String? = nil,
        iconRenderingMode: SymbolRenderingMode? = nil,
        iconColor: S,
        action: @escaping () -> Void
    ) -> some View where S: ShapeStyle {
        Button(action: action) {
            Label {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                    Text(urlText)
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                }
                Spacer()
                Image(.externalLink)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.gray.opacity(0.7))
                    .frame(width: 18)
            } icon: {
                if let icon = icon {
                    Image(icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(iconColor)
                } else {
                    Image(systemName: iconSystemName ?? "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(iconColor)
                        .symbolRenderingMode(iconRenderingMode)
                }
            }
        }
        .labelStyle(CenterLabelStyle())
    }

    @ViewBuilder
    private func bottomText() -> some View {
        let availableRequestReview = requestReviewVersion != Bundle.main.buildVersionNumber
        Button {
            requestReviewTrigger.toggle()
            requestReview()
            requestReviewVersion = Bundle.main.buildVersionNumber ?? "1"
        } label: {
            VStack {
                Text("Version \(Bundle.main.releaseVersionNumber ?? "") (\(Bundle.main.buildVersionNumber ?? ""))")
                    .foregroundStyle(.gray)
                    .font(.footnote)
                Text("Made with Love")
                    .foregroundStyle(.gray)
                    .font(.caption)
                    .bold()
                    .underline(availableRequestReview, color: .gray.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .sensoryFeedback(.success, trigger: requestReviewTrigger) { _, _ in hapticFeedback }
        .disabled(!availableRequestReview)
        .listRowBackground(Color.clear)
    }
}

extension Bundle {
    fileprivate var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    fileprivate var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
