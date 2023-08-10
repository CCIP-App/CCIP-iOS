//
//  RootView.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/8.
//

import SwiftUI

struct RootView: View {
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
