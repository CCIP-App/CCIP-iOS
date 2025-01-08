//
//  EventView.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/8.
//

import SwiftUI

struct EventView: View {
    @EnvironmentObject private var store: OPassStore
    @EnvironmentObject private var event: EventStore

    var body: some View {
        VStack {
            eventLogo
                .foregroundColor(.logo)
                .padding(.bottom)
                .frame(
                    width: UIScreen.main.bounds.width * 0.78,
                    height: UIScreen.main.bounds.width * 0.4)

            FeatureGrid()
        }
        .navigationDestination(for: FeatureDestinations.self) { $0.view }
        .background(.sectionBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbar }
    }

    @ViewBuilder
    private var eventLogo: some View {
        if let image = store.eventLogo {
            image
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
        } else if let logo = event.logo {
            logo
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
        } else {
            Text(event.config.title.localized())
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text(event.config.title.localized())
                    .font(.headline)
                if event.userId != "nil" {
                    Text(event.userId)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
