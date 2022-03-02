//
//  MainTabsView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//

import SwiftUI

struct TestTabsView: View {
    
    var body: some View {
        //Only for API Testing
        VStack {
            TabView {
                SettingView().tabItem {
                    Image(systemName: "gearshape.fill")
                }
                
                SessionView().tabItem({
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
        TestTabsView()
            .environmentObject(OPassAPIModels.mock())
    }
}
#endif
