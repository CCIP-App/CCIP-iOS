//
//  SwiftUIView.swift
//  OPass
//
//  Created by secminhr on 2022/3/3.
//

import SwiftUI

struct EventView: View {
    @ObservedObject var event: EventModel
    
    var body: some View {
        VStack {
            Text(event.logo_url)
            if let settings = event.eventSettings {
                EventSettingsView(eventSettings: settings)
            }
        }
    }
}

struct CurrentEventViewView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: OPassAPIModels.mock().eventList[0])
    }
}
