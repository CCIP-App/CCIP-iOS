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
    
    @StateObject var pathManager = PathManager()
    @StateObject var OPassAPI = OPassAPIViewModel()
    @State var handlingURL = false
    @State var isShowingEventList = false
    @State var showHttp403Alert = false
    @State var isError = false
    @State var showInvalidURL = false
    @State var viewFirstActive = true
    @Binding var url: URL?

    var body: some View {
        NavigationStack(path: $pathManager.path) {
            VStack {
                if !isError {
                    if OPassAPI.currentEventID == nil {
                        VStack {}
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onAppear {
                                self.isShowingEventList = true
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
                            .onAppear {
                                if viewFirstActive {
                                    Constants.PromptForPushNotifications()
                                    viewFirstActive.toggle()
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
            .navigationTitle(OPassAPI.currentEventAPI?.display_name.localized() ?? "OPass")
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
            .sheet(isPresented: $isShowingEventList) {
                EventListView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    SFButton(systemName: "rectangle.stack") {
                        isShowingEventList.toggle()
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
                        self.isShowingEventList = false
                        await parseUniversalLinkAndURL(url!)
                    }
                    .alert("InvalidURL", isPresented: $showInvalidURL) {
                        Button("OK", role: .cancel) {
                            self.url = nil
                            if OPassAPI.currentEventAPI == nil {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self.isShowingEventList = true
                                }
                            }
                        }
                    } message: {
                        Text("InvalidURLOrTokenContent")
                    }
                    .http403Alert(title: "CouldntVerifiyYourIdentity", isPresented: $showHttp403Alert) {
                        self.url = nil
                        if OPassAPI.currentEventAPI == nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.isShowingEventList = true
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
                self.showInvalidURL = true
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
                self.showHttp403Alert = true
            }
            return
        } catch {}
        
        // Error
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showInvalidURL = true
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
