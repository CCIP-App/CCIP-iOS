//
//  ContentView.swift
//  OPass
//
//  Created by 張智堯 on 2022/2/28.
//  2022 OPass.
//

import SwiftUI
import FirebaseDynamicLinks

struct ContentView: View {
    
    @Binding var url: URL?
    @StateObject var pathManager = PathManager()
    @StateObject var OPassAPI = OPassAPIViewModel()
    @State private var isError = false
    @State private var handlingURL = false
    @State private var isEventListPresented = false
    @State private var isHttp403AlertPresented = false
    @State private var isInvalidURLAlertPresented = false
    
    var body: some View {
        NavigationStack(path: $pathManager.path) {
            VStack {
                if !isError {
                    if OPassAPI.currentEventID == nil {
                        VStack {}
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onAppear {
                                self.isEventListPresented = true
                            }
                    } else if OPassAPI.currentEventID != OPassAPI.currentEventAPI?.event_id {
                        ProgressView("Loading")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .task {
                                do { try await OPassAPI.loadCurrentEventAPI() }
                                catch { self.isError = true }
                            }
                    } else if let eventAPI = OPassAPI.currentEventAPI {
                        MainView(eventAPI: eventAPI)
                    } else {
                        VStack {} // Unknown status
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onAppear { self.isError = true }
                    }
                } else {
                    ErrorWithRetryView {
                        self.isError = false
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: OPassAPI.currentEventID) { _ in
                        self.isError = false
                    }
                }
            }
            .background(Color("SectionBackgroundColor"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: PathManager.destination.self) { destination in
                switch destination {
                case .fastpass:                FastpassView(eventAPI: OPassAPI.currentEventAPI!)
                case .schedule:                ScheduleView(eventAPI: OPassAPI.currentEventAPI!)
                case .sessionDetail(let data): SessionDetailView(OPassAPI.currentEventAPI!, detail: data)
                case .ticket:                  TicketView(eventAPI: OPassAPI.currentEventAPI!)
                case .announcement:            AnnouncementView(eventAPI: OPassAPI.currentEventAPI!)
                case .settings:                SettingsView()
                case .appearance:              AppearanceView()
                case .developers:              DevelopersView()
                }
            }
            .sheet(isPresented: $isEventListPresented) {
                EventListView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    SFButton(systemName: "rectangle.stack") {
                        isEventListPresented.toggle()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(OPassAPI.currentEventAPI?.display_name.localized() ?? "OPass")
                            .font(.headline)
                        if let userId = OPassAPI.currentEventAPI?.user_id, userId != "nil" {
                            Text(userId)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(value: PathManager.destination.settings) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .environmentObject(pathManager)
        .environmentObject(OPassAPI)
        .overlay {
            if self.url != nil {
                ProgressView("LOGGINGIN")
                    .task {
                        self.isEventListPresented = false
                        await parseUniversalLinkAndURL(url!)
                    }
                    .alert("InvalidURL", isPresented: $isInvalidURLAlertPresented) {
                        Button("OK", role: .cancel) {
                            self.url = nil
                            if OPassAPI.currentEventAPI == nil {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self.isEventListPresented = true
                                }
                            }
                        }
                    } message: {
                        Text("InvalidURLOrTokenContent")
                    }
                    .http403Alert(title: "CouldntVerifiyYourIdentity", isPresented: $isHttp403AlertPresented) {
                        self.url = nil
                        if OPassAPI.currentEventAPI == nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.isEventListPresented = true
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("SectionBackgroundColor").edgesIgnoringSafeArea(.all))
            }
        }
    }
    
    private func parseUniversalLinkAndURL(_ url: URL) async {
        let params = URLComponents(string: "?" + (url.query ?? ""))?.queryItems
        
        // Select event
        guard let eventId = params?.first(where: { $0.name == "event_id"})?.value else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isInvalidURLAlertPresented = true
            }
            return
        }
        
        DispatchQueue.main.async {
            OPassAPI.currentEventID = eventId
            if eventId != OPassAPI.currentEventAPI?.event_id { OPassAPI.currentEventLogo = nil }
        }
        
        // Login
        guard let token = params?.first(where: { $0.name == "token" })?.value else {
            DispatchQueue.main.async {
                self.url = nil
            }
            return
        }
        
        do {
            if try await OPassAPI.loginCurrentEvent(withToken: token) {
                DispatchQueue.main.async { self.url = nil }
                await OPassAPI.currentEventAPI?.loadLogos()
                return
            }
        } catch APIRepo.LoadError.http403Forbidden {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isHttp403AlertPresented = true
            }
            return
        } catch {}
        
        // Error
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isInvalidURLAlertPresented = true
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(url: .constant(nil))
            .environmentObject(OPassAPIViewModel.mock())
    }
}
#endif
