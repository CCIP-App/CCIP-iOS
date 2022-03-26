//
//  FastpassView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/25.
//

import SwiftUI

struct FastpassView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    
    var body: some View {
        VStack {
            if let eventLogoData = eventAPI.eventLogo, let eventLogoUIImage = UIImage(data: eventLogoData) {
                Image(uiImage: eventLogoUIImage)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .foregroundColor(Color("LogoColor"))
                    .frame(width: UIScreen.main.bounds.width * 0.78, height: UIScreen.main.bounds.width * 0.4)
            } else {
                Text(eventAPI.display_name.en)
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(Color("LogoColor"))
                    .frame(width: UIScreen.main.bounds.width * 0.78, height: UIScreen.main.bounds.width * 0.4)
            }
            
            if eventAPI.accessToken != nil {
                ScenarioView(eventAPI: eventAPI)
            } else {
                RedeemTokenView(eventAPI: eventAPI)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Fast Pass").font(.headline)
                    Text(eventAPI.display_name.en).font(.caption).foregroundColor(.gray)
                }
            }
        }
    }
}

#if DEBUG
struct FastpassView_Previews: PreviewProvider {
    static var previews: some View {
        FastpassView(eventAPI: OPassAPIViewModel.mock().eventList[5])
    }
}
#endif
