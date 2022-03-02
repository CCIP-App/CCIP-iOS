//
//  SettingView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//

import SwiftUI

struct SettingView: View {
    
    @EnvironmentObject var OPassAPI: OPassAPIModels
    
    var body: some View {
        //Only for API Testing
        VStack {
            if let data = OPassAPI.eventLogo, let uiimage = UIImage(data: data) {
                Image(uiImage: uiimage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.78, height: UIScreen.main.bounds.width * 0.4)
                    .background(Color.purple)
            }
            
            Text(OPassAPI.eventSettings.event_id)
            
            ScrollView {
                ForEach(OPassAPI.eventSettings.features, id: \.self) { feature in
                    Text(feature.display_text.zh)
                }
            }
        }
    }
}

#if DEBUG
struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .environmentObject(OPassAPIModels.mock())
    }
}
#endif
