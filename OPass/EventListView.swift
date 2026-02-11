//
//  EventListView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//  2026 OPass.
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
                .contentMargins(.top, 8)
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
                AsyncImage(url: URL(string: event.logoUrl), transaction: .init(animation: .spring)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .onAppear { self.preloadLogoImage = image }
                    } else if let error = phase.error {
                        Image(systemName: "xmark.circle")
                            .foregroundStyle(.white)
                            .onAppear { logger.error("\(error)") }
                    } else { ProgressView() }
                }
                .frame(
                    width: UIScreen.main.bounds.width * 0.25,
                    height: UIScreen.main.bounds.width * 0.15
                )
                .background(Image(.appGradientBackground).resizable().brightness(0.1))
                .clipShape(.rect(cornerRadius: 15, style: .continuous))
                .padding(.trailing, 10)
                .padding(.leading, -4)

                Text(event.title.localized())
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .fontWeight(.medium)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.gray.opacity(0.55))
                    .padding(.trailing, 1.5)
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
