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
    
    var body: some View {
        VStack {
            if eventAPI.accessToken == nil {
                RedeemTokenView(eventAPI: eventAPI)
            } else {
                if eventAPI.eventScenarioStatus != nil {
                    ScenarioView(eventAPI: eventAPI)
                        .task { await eventAPI.loadScenarioStatus() }
                } else {
                    ProgressView(LocalizedStringKey("Loading"))
                        .task { await eventAPI.loadScenarioStatus() }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(LocalizedStringKey("FastPass")).font(.headline)
                    Text(Bundle.main.preferredLocalizations[0] ==  "zh-Hant" ? eventAPI.display_name.zh : eventAPI.display_name.en).font(.caption).foregroundColor(.gray)
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
