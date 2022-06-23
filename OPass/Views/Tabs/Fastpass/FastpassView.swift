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
    @State var isShowingLoading = false
    @State var isError = false
    let display_text: DisplayTextModel
    
    init(eventAPI: EventAPIViewModel) {
        self.eventAPI = eventAPI
        self.display_text = eventAPI.eventSettings.feature(ofType: .fastpass).display_text
    }
    
    var body: some View {
        VStack {
            if eventAPI.accessToken == nil {
                RedeemTokenView(eventAPI: eventAPI)
            } else {
                if !isError {
                    if eventAPI.eventScenarioStatus != nil {
                        ScenarioView(eventAPI: eventAPI)
                            .task { try? await eventAPI.loadScenarioStatus() }
                    } else {
                        ProgressView(LocalizedStringKey("Loading"))
                            .task {
                                do { try await eventAPI.loadScenarioStatus() }
                                catch { self.isError = true }
                            }
                    }
                } else {
                    ErrorWithRetryView {
                        self.isError = false
                        Task {
                            do { try await eventAPI.loadScenarioStatus() }
                            catch { self.isError = true }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(LocalizeIn(zh: display_text.zh, en: display_text.en)).font(.headline)
                        //.fixedSize(horizontal: true, vertical: true)
                    Text(LocalizeIn(zh: eventAPI.display_name.zh, en: eventAPI.display_name.en)).font(.caption).foregroundColor(.gray)
                        //.fixedSize(horizontal: true, vertical: true)
                }
            }
        }
    }
}

#if DEBUG
struct FastpassView_Previews: PreviewProvider {
    static var previews: some View {
        FastpassView(eventAPI: OPassAPIViewModel.mock().currentEventAPI!)
    }
}
#endif
