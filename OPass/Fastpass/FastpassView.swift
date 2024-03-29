//
//  FastpassView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/25.
//  2023 OPass.
//

import SwiftUI

struct FastpassView: View {
    
    // MARK: - Variables
    @EnvironmentObject var EventStore: EventStore
    @State private var isHttp403AlertPresented = false
    @State private var errorType: String? = nil
    
    // MARK: - Views
    var body: some View {
        VStack {
            if EventStore.token == nil {
                RedeemTokenView()
            } else {
                if errorType == nil {
                    if EventStore.attendee != nil {
                        ScenarioView()
                            .task {
                                do { try await EventStore.loadAttendee() }
                                catch APIManager.LoadError.forbidden {
                                    self.isHttp403AlertPresented = true
                                } catch {}
                            }
                    } else {
                        ProgressView("Loading")
                            .task {
                                do { try await EventStore.loadAttendee() }
                                catch APIManager.LoadError.forbidden {
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
                    if let displayText = EventStore.config.feature(.fastpass)?.title {
                        Text(displayText.localized()).font(.headline)
                    }
                    Text(EventStore.config.title.localized())
                        .font(.caption).foregroundColor(.gray)
                }
            }
        }
        .http403Alert(isPresented: $isHttp403AlertPresented)
    }
}

#if DEBUG
struct FastpassView_Previews: PreviewProvider {
    static var previews: some View {
        FastpassView()
            .environmentObject(OPassStore.mock().event!)
    }
}
#endif
