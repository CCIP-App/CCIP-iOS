//
//  EventListView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//  2022 OPass.
//

import SwiftUI
import OSLog

struct EventListView: View {
    
    // MARK: - Variables
    @EnvironmentObject private var OPassAPI: OPassAPIService
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
            .navigationTitle("SelectEvent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
        }
        .interactiveDismissDisabled(OPassAPI.currentEventID == nil)
    }
    
    var list: some View {
        List(viewModel.listedEvents, id: \.event_id) { event in
            EventRow(event: event, dismiss: _dismiss)
        }
        .searchable(text: $viewModel.searchQuery, placement: .navigationBarDrawer(displayMode: .automatic))
    }
    
    var loading: some View {
        ProgressView("Loading")
            .task { await viewModel.loadEvents() }
    }
    
    var error: some View {
        ErrorWithRetryView {
            Task { await viewModel.reset() }
        }
    }
    
    var toolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                if OPassAPI.currentEventAPI != nil {
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
}

private struct EventRow: View {
    let event: EventTitleModel
    
    @EnvironmentObject var OPassAPI: OPassAPIService
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var preloadLogoImage: Image? = nil
    
    private let logger = Logger(subsystem: "app.opass.ccip", category: "EventListView")
    var body: some View {
        Button {
            OPassAPI.currentEventID = event.event_id
            OPassAPI.currentEventLogo = preloadLogoImage
            dismiss()
        } label: {
            HStack {
                AsyncImage(url: URL(string: event.logo_url), transaction: Transaction(animation: .spring())) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .renderingMode(.template)
                            .resizable().scaledToFit()
                            .foregroundColor(Color("LogoColor"))
                            .onAppear { self.preloadLogoImage = image }
                    case .failure(_):
                        Image(systemName: "xmark.circle")
                            .foregroundColor(Color("LogoColor").opacity(0.5))
                    @unknown default:
                        Image(systemName: "xmark.circle")
                            .foregroundColor(Color("LogoColor").opacity(0.5))
                            .onAppear {
                                logger.error("Unknow AsyncImage status")
                            }
                    }
                }
                .padding(.horizontal, 3)
                .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.15)
                
                Text(event.display_name.localized())
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
    @Published var events: [EventTitleModel] = []
    @Published var searchQuery: String = ""
    @Published var error: Error? = nil
    
    var listedEvents: [EventTitleModel] {
        if searchQuery.isEmpty { return events }
        else {
            return events.filter { event in
                let name = event.display_name.localized().lowercased()
                for component in searchQuery.tirm().lowercased().components(separatedBy: " ") {
                    let component = component.tirm()
                    if component.isEmpty { continue }
                    if name.notContains(component) { return false }
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
        await APIManager.shared.fetchEvents { result in
            switch result {
            case .success(let events): self.events = events
            case .failure(let error): self.error = error
            }
        }
    }
    
    func reset() async {
        self.error = nil
        self.events = []
        await loadEvents()
    }
}

#if DEBUG
struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
            .environmentObject(OPassAPIService.mock())
    }
}
#endif
