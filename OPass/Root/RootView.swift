//
//  RootView.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/8.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var event: EventStore
    @EnvironmentObject private var appDelegate: AppDelegate
    @StateObject private var router = Router()
    @State private var presentEventList = false

    var body: some View {
        NavigationStack(path: $router.path) {
            EventView()
                .navigationDestination(for: RootDestinations.self) { $0.view }
                .sheet(isPresented: $presentEventList) { EventListView() }
                .toolbar { toolbar }
        }
        .environmentObject(router)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: appDelegate.announcementEventId) { openNotificationAnnouncement() }
    }

    /// Opens the announcements once the event of a tapped push notification is shown.
    private func openNotificationAnnouncement() {
        guard appDelegate.announcementEventId == event.id else { return }
        appDelegate.announcementEventId = nil
        guard event.config.feature(.announcement) != nil else { return }
        router.backRoot()
        router.forward(FeatureDestinations.announcement)
    }

    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            SFButton(systemName: "rectangle.stack") {
                presentEventList = true
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            SFButton(systemName: "gearshape") {
                router.forward(RootDestinations.settings)
            }
        }
    }
}
