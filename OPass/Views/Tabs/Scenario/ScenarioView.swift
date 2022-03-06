//
//  ScenarioView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
//

import SwiftUI

struct ScenarioView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    
    var body: some View {
        //Only for API Testing
        VStack {
            if let eventScenarioStatus = eventAPI.eventScenarioStatus {
                VStack {
                    Text("Get Scenario Status Scuess")
                    Text("Current Token")
                    Text(eventScenarioStatus.token)
                }
            }
            
            Divider()
            
            RedeemTokenView(eventAPI: eventAPI)
        }
        .onAppear(perform: {
            if eventAPI.accessToken != "" {
                Task {
                    await eventAPI.loadScenarioStatus()
                }
            }
        })
    }
}

#if DEBUG
struct ScenarioView_Previews: PreviewProvider {
    static var previews: some View {
        ScenarioView(eventAPI: OPassAPIViewModel.mock().eventList[5])
    }
}
#endif
