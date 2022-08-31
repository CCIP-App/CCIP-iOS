//
//  FastpassView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/25.
//  2022 OPass.
//

import SwiftUI

struct FastpassView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    @State var showHttp403Alert = false
    @State var errorType: String? = nil
    let display_text: DisplayTextModel
    
    init(eventAPI: EventAPIViewModel) {
        self.eventAPI = eventAPI
        self.display_text = eventAPI.settings.feature(ofType: .fastpass)?.display_text ?? .init(en: "", zh: "")
    }
    
    var body: some View {
        VStack {
            if eventAPI.accessToken == nil {
                RedeemTokenView(eventAPI: eventAPI)
            } else {
                if errorType == nil {
                    if eventAPI.scenarioStatus != nil {
                        ScenarioView(eventAPI: eventAPI)
                            .task {
                                do { try await eventAPI.loadScenarioStatus() }
                                catch APIRepo.LoadError.http403Forbidden {
                                    self.showHttp403Alert = true
                                } catch {}
                            }
                    } else {
                        ProgressView("Loading")
                            .task {
                                do { try await eventAPI.loadScenarioStatus() }
                                catch APIRepo.LoadError.http403Forbidden {
                                    self.errorType = "http403"
                                }
                                catch { self.errorType = "unknown" }
                            }
                    }
                } else {
                    ErrorWithRetryView(message: {
                        switch errorType! {
                        case "http403": return "ConnectToConferenceWiFi"
                        default: return nil
                        }
                    }()) {
                        self.errorType = nil
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(display_text.localized())
                        .font(.headline)
                    Text(eventAPI.display_name.localized())
                        .font(.caption).foregroundColor(.gray)
                }
            }
        }
        .http403Alert(isPresented: $showHttp403Alert)
    }
}

#if DEBUG
struct FastpassView_Previews: PreviewProvider {
    static var previews: some View {
        FastpassView(eventAPI: OPassAPIViewModel.mock().currentEventAPI!)
    }
}
#endif
