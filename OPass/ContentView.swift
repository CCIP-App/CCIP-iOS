//
//  ContentView.swift
//  OPass
//
//  Created by 張智堯 on 2022/2/28.
//  2025 OPass.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Variables
    @Binding var url: URL?
    @EnvironmentObject var store: OPassStore
    @StateObject private var router = Router()
    @State private var error: Error?
    @State private var presentHttp403Alert = false
    @State private var presentInvaildUrlAlert = false

    // MARK: - Views
    var body: some View {
        Group {
            switch viewState {
            case .ready(let event):
                RootView()
                    .environmentObject(event)
            case .loading:
                ProgressView("Loading")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task {
                        do {
                            try await store.loadEvent(reload: true)
                        } catch { self.error = error }
                    }
            case .login(let url):
                ProgressView("LOGGINGIN")
                    .task { await parseUniversalLink(url) }
                    .alert("InvalidURL", isPresented: $presentInvaildUrlAlert) {
                        Button("OK", role: .cancel) { self.url = nil }
                    } message: {
                        Text("InvalidURLOrTokenContent")
                    }
                    .alert("CouldntVerifiyYourIdentity", isPresented: $presentHttp403Alert) {
                        Button("OK", role: .cancel) { self.url = nil }
                    } message: {
                        Text("ConnectToConferenceWiFi")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .empty:
                EventListView()
            case .error:
                ContentUnavailableView {
                    Label("Can't load Event", systemImage: "exclamationmark.triangle.fill")
                } description: {
                    Text("Check your network status or select a new event.")
                } actions: {
                    Button("Try Again") {
                        self.error = nil
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Select Event") {
                        self.error = nil
                        self.store.eventId = nil
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .background(.sectionBackground)
    }
}

// MARK: ViewState
extension ContentView {
    private enum ViewState {
        case ready(EventStore)
        case empty
        case loading
        case login(URL)
        case error
    }

    private var viewState: ViewState {
        if let url = url {
            DispatchQueue.main.async { error = nil }
            return .login(url)
        }
        guard error == nil else { return .error }
        guard let eventID = store.eventId else { return .empty }
        guard let event = store.event, eventID == event.id else { return .loading }
        return .ready(event)
    }

    private func parseUniversalLink(_ url: URL) async {
        // Parse
        var prasedUrl = url
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let linkParam = components.queryItems?.first(where: { $0.name == "link" })?.value,
            let decodedLink = linkParam.removingPercentEncoding,
            let linkURL = URL(string: decodedLink)
        {
            prasedUrl = linkURL
        }
        let params = URLComponents(url: prasedUrl, resolvingAgainstBaseURL: false)?.queryItems

        // Select Event
        guard let eventId = params?.first(where: { $0.name == "event_id" })?.value else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.presentInvaildUrlAlert = true
            }
            return
        }
        store.eventId = eventId
        if eventId != store.event?.id { store.eventLogo = nil }
        
        // Login
        guard let token = params?.first(where: { $0.name == "token" })?.value else {
            DispatchQueue.main.async {
                self.url = nil
            }
            return
        }
        do {
            if try await store.loginCurrentEvent(with: token) {
                DispatchQueue.main.async { self.url = nil }
                await store.event?.loadLogos()
                return
            }
        } catch APIManager.LoadError.forbidden {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.presentHttp403Alert = true
            }
            return
        } catch {}
        
        // Error
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.presentInvaildUrlAlert = true
        }
    }
}

#if DEBUG
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView(url: .constant(nil))
                .environmentObject(OPassStore.mock())
        }
    }
#endif
