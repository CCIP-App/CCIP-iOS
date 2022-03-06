//
//  RedeemTokenView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/5.
//

import SwiftUI

struct RedeemTokenView: View {
    
    @State var token: String = ""
    @ObservedObject var eventAPI: EventAPIViewModel
    
    var body: some View {
        VStack {
            Text("Enter Token")
            
            TextField("Token", text: $token, prompt: Text("Token"))
                .padding()
            Button(action: {
                //It shoud has token Certification
                if token != "" {
                    eventAPI.accessToken = token
                    Task {
                        await eventAPI.loadScenarioStatus()
                    }
                }
            }) {
                Text("Redeem")
                    .foregroundColor(Color.white)
                    .padding(5)
                    .background(Color.blue)
                    .cornerRadius(5)
            }
        }
    }
}

#if DEBUG
struct RedeemTokenView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemTokenView(eventAPI: OPassAPIViewModel.mock().eventList[5])
    }
}
#endif
