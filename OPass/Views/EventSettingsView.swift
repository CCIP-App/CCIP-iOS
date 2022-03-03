//
//  EventSettingsView.swift
//  OPass
//
//  Created by secminhr on 2022/3/3.
//

import SwiftUI

struct EventSettingsView: View {
    var eventSettings: EventSettingsModel
    
    var body: some View {
        VStack {
            Text(eventSettings.event_date.start)
            Text(eventSettings.display_name.zh)
        }
    }
}

#if DEBUG
struct EventSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        EventSettingsView(eventSettings: EventSettingsModel.mock())
    }
}
#endif
