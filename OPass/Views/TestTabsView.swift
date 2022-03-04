//
//  MainTabsView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//

import SwiftUI

struct TestTabsView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    
    var body: some View {
        //Only for API Testing
        VStack {
            TabView {
                SettingView(eventAPI: eventAPI).tabItem {
                    Image(systemName: "gearshape.fill")
                }
                
                SessionView(eventAPI: eventAPI).tabItem({
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                })
                
                EventListView().tabItem {
                    Image(systemName: "list.bullet.circle.fill")
                }
            }
        }
    }
}

#if DEBUG
struct TestTabsView_Previews: PreviewProvider {
    static var previews: some View {
        TestTabsView(eventAPI: OPassAPIViewModel.mock().eventList[5])
            .environmentObject(OPassAPIViewModel.mock())
    }
}
#endif
