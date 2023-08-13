//
//  ContentView.swift
//  OPass
//
//  Created by 張智堯 on 2022/2/28.
//  2023 OPass.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Variables
    @Binding var url: URL?
    @EnvironmentObject var store: OPassStore
    @State private var error: Error?
    @State private var presentEventList = false
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
                            try await store.loadEvent()
                        } catch { self.error = error }
                    }
            case .login(let url):
                ProgressView("LOGGINGIN")
                    .task { await parseUniversalLinkAndURL(url) }
                    .alert("InvalidURL", isPresented: $presentInvaildUrlAlert) {
                        Button("OK", role: .cancel) { self.url = nil }
                    } message: { Text("InvalidURLOrTokenContent") }
                    .alert("CouldntVerifiyYourIdentity", isPresented: $presentHttp403Alert) {
                        Button("OK", role: .cancel) { self.url = nil }
                    } message: { Text("ConnectToConferenceWiFi") }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .empty:
                EventListView()
            case .error:
                ErrorView(error: $error)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $presentEventList) { EventListView() }
        .background(Color("SectionBackgroundColor"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbar }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            SFButton(systemName: "rectangle.stack") {
                presentEventList.toggle()
            }
        }

        ToolbarItem(placement: .principal) {
            VStack {
                Text(store.event?.config.title.localized() ?? "OPass")
                    .font(.headline)
                if let userId = store.event?.userId, userId != "nil" {
                    Text(userId)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(value: RootDestinations.settings) {
                Image(systemName: "gearshape")
            }
        }
    }

    private struct ErrorView: View {
        @EnvironmentObject var store: OPassStore
        @Binding var error: Error?

        var body: some View {
            VStack {
                Spacer()

                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("LogoColor"))
                    .frame(width: UIScreen.main.bounds.width * 0.25)
                    .padding(.bottom, 5)

                Text("Something went wrong")
                    .multilineTextAlignment(.center)
                    .font(.title)

                Text(error?.localizedDescription ?? "")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .font(.callout)

                Spacer()

                Button {
                    self.error = nil
                } label: {
                    HStack {
                        Spacer()
                        Text("Try Again")
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)

                Button {
                    self.store.eventId = nil
                    self.error = nil
                } label: {
                    HStack {
                        Spacer()
                        Text("Select Event")
                        Spacer()
                    }
                }
                .buttonStyle(.bordered)
                .padding(.bottom)
            }
            .frame(width: UIScreen.main.bounds.width * 0.9)
        }
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
            error = nil
            return .login(url)
        }
        guard error == nil else { return .error }
        guard let eventID = store.eventId else { return .empty }
        guard let event = store.event, eventID == event.id else { return .loading }
        return .ready(event)
    }

    private func parseUniversalLinkAndURL(_ url: URL) async {
        let params = URLComponents(string: "?" + (url.query ?? ""))?.queryItems
        // MARK: Select Event
        guard let eventId = params?.first(where: { $0.name == "event_id"})?.value else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.presentInvaildUrlAlert = true
            }
            return
        }
        store.eventId = eventId
        if eventId != store.event?.id { store.eventLogo = nil }
        // MARK: Login
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
        // MARK: Error
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
