//
//  EventListView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//  2025 OPass.
//

import OSLog
import SwiftUI

struct EventListView: View {

    // MARK: - Variables
    @EnvironmentObject private var store: OPassStore
    @StateObject private var viewModel = EventListViewModel()
    @Environment(\.dismiss) var dismiss

    // MARK: - Views
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.viewState {
                case .ready: list
                case .loading: loading
                case .error: error
                }
            }
            .navigationTitle("Select Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
        }
        .interactiveDismissDisabled(store.eventId == nil)
    }

    var list: some View {
        Group {
            if !viewModel.listedEvents.isEmpty {
                List(viewModel.listedEvents) { event in
                    EventRow(event: event, dismiss: _dismiss)
                }
            } else {
                ContentUnavailableView.search(text: viewModel.searchQuery)
            }
        }
        .searchable(
            text: $viewModel.searchQuery, placement: .navigationBarDrawer(displayMode: .automatic))
    }

    var loading: some View {
        ProgressView("Loading")
            .task { await viewModel.loadEvents() }
    }

    var error: some View {
        ContentUnavailableView {
            Label("Faild to Load Event List", systemImage: "exclamationmark.triangle.fill")
        } description: {
            Text("Check your network status or try again")
        } actions: {
            Button("Try Again") {
                self.viewModel.error = nil
            }
            .buttonStyle(.borderedProminent)
        }
    }

    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if store.event != nil {
                Button(LocalizedStringKey("Close")) {
                    dismiss()
                }
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            SFButton(systemName: "arrow.clockwise") {
                Task { await viewModel.reset() }
            }
        }
    }
}

private struct EventRow: View {
    let event: Event

    @EnvironmentObject var store: OPassStore
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var preloadLogoImage: Image? = nil

    private let logger = Logger(subsystem: "app.opass.ccip", category: "EventListView")
    var body: some View {
        Button {
            store.eventId = event.id
            store.eventLogo = preloadLogoImage
            dismiss()
        } label: {
            HStack {
                AsyncImage(
                    url: URL(string: event.logoUrl), transaction: Transaction(animation: .spring())
                ) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .renderingMode(.template)
                            .resizable().scaledToFit()
                            .foregroundColor(.logo)
                            .onAppear { self.preloadLogoImage = image }
                    case .failure(_):
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.logo.opacity(0.5))
                    @unknown default:
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.logo.opacity(0.5))
                            .onAppear {
                                logger.error("Unknow AsyncImage status")
                            }
                    }
                }
                .padding(.horizontal, 3)
                .frame(
                    width: UIScreen.main.bounds.width * 0.25,
                    height: UIScreen.main.bounds.width * 0.15)

                Text(event.title.localized())
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
    }
}

@MainActor
private class EventListViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var searchQuery: String = ""
    @Published var error: Error? = nil

    var listedEvents: [Event] {
        if searchQuery.isEmpty {
            return events
        } else {
            return events.filter { event in
                let name = event.title.localized().lowercased()
                for component in searchQuery.tirm().lowercased().components(separatedBy: " ") {
                    let component = component.tirm()
                    if component.isEmpty { continue }
                    if !name.contains(component) { return false }
                }
                return true
            }
        }
    }

    enum ViewState {
        case ready
        case loading
        case error
    }

    var viewState: ViewState {
        if error != nil { return .error }
        if events.isNotEmpty { return .ready }
        return .loading
    }

    func loadEvents() async {
        do { self.events = try await APIManager.fetchEvents() } catch { self.error = error }
    }

    func reset() async {
        self.error = nil
        self.events = []
    }
}

#if DEBUG
    struct EventListView_Previews: PreviewProvider {
        static var previews: some View {
            EventListView()
                .environmentObject(OPassStore.mock())
        }
    }
#endif
