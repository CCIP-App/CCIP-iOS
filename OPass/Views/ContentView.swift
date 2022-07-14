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
    
    @EnvironmentObject var OPassAPI: OPassAPIViewModel
    @State var handlingURL = false
    @State var isShowingEventList = false
    @State var isError = false
    @State var showInvalidURL = false
    @Binding var url: URL?

    var body: some View {
        NavigationView {
            VStack {
                if !isError {
                    if OPassAPI.currentEventID == nil {
                        VStack {}
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onAppear(perform: {
                                isShowingEventList = true
                            })
                    } else if OPassAPI.currentEventID != OPassAPI.currentEventAPI?.event_id {
                        ProgressView(LocalizedStringKey("Loading"))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .task {
                                do { try await OPassAPI.loadCurrentEventAPI() }
                                catch { self.isError = true }
                            }
                    } else {
                        MainView(eventAPI: OPassAPI.currentEventAPI!)
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
            .sheet(isPresented: $isShowingEventList) {
                EventListView()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(
                        LocalizeIn(
                            zh: OPassAPI.currentEventAPI?.display_name.zh,
                            en: OPassAPI.currentEventAPI?.display_name.en
                        ) ?? "OPass"
                    )
                    .bold()
                    .lineLimit(1)
                    .fixedSize()
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    SFButton(systemName: "rectangle.stack") {
                        isShowingEventList.toggle()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .overlay {
            if self.url != nil {
                ProgressView("LOGGINGIN")
                    .task {
                        self.isShowingEventList = false
                        await parseUniversalLinkAndURL(url!)
                    }
                    .alert("InvalidURL", isPresented: $showInvalidURL) {
                        Button("OK", role: .cancel) {
                            url = nil
                            if OPassAPI.currentEventAPI == nil {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self.isShowingEventList = true
                                }
                            }
                        }
                    } message: {
                        Text("InvalidURLOrTokenContent")
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
            DispatchQueue.main.async {
                self.showInvalidURL = true
            }
            return
        }
        
        DispatchQueue.main.async {
            OPassAPI.currentEventID = eventId
        }
        
        // Login
        guard let token = params?.first(where: { $0.name == "token" })?.value else {
            DispatchQueue.main.async {
                self.url = nil
            }
            return
        }
        
        if await OPassAPI.loginCurrentEvent(token: token) {
            DispatchQueue.main.async {
                self.url = nil
            }
            await OPassAPI.currentEventAPI?.loadLogos()
        } else {
            DispatchQueue.main.async {
                self.showInvalidURL = true
            }
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
