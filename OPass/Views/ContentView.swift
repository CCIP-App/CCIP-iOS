//
//  ContentView.swift
//  OPass
//
//  Created by 張智堯 on 2022/2/28.
//  2022 OPass.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Variables
    @Binding var url: URL?
    @StateObject var router = Router()
    @EnvironmentObject var OPassAPI: OPassAPIService
    @State private var isError = false
    @State private var handlingURL = false
    @State private var isEventListPresented = false
    @State private var isHttp403AlertPresented = false
    @State private var isInvalidURLAlertPresented = false
    
    // MARK: - Views
    var body: some View {
        NavigationStack(path: $router.path) {
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
                        MainView()
                            .environmentObject(eventAPI)
                            .navigationDestination(for: Router.mainDestination.self) { destination in
                                switch destination {
                                case .fastpass:                FastpassView().environmentObject(eventAPI)
                                case .schedule:                ScheduleView(eventAPI: eventAPI)
                                case .sessionDetail(let data): SessionDetailView(data).environmentObject(eventAPI)
                                case .ticket:                  TicketView().environmentObject(eventAPI)
                                case .announcement:            AnnouncementView().environmentObject(eventAPI)
                                }
                            }
                            
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
            .navigationDestination(for: Router.rootDestination.self) { destination in
                switch destination {
                case .settings:   SettingsView()
                case .appearance: AppearanceView()
                case .developers: DevelopersView()
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
                    NavigationLink(value: Router.rootDestination.settings) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .environmentObject(router)
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
            .environmentObject(OPassAPIService.mock())
    }
}
#endif
