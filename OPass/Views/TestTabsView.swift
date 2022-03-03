//
//  MainTabsView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//

import SwiftUI

struct TestTabsView: View {
    
    @ObservedObject var event: EventViewModel
    
    var body: some View {
        //Only for API Testing
        VStack {
            TabView {
                SettingView(event: event).tabItem {
                    Image(systemName: "gearshape.fill")
                }
                
                SessionView(event: event).tabItem({
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
        TestTabsView(event: OPassAPIViewModel.mock().eventList[5])
            .environmentObject(OPassAPIViewModel.mock())
    }
}
#endif
