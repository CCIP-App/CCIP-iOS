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
            Form {
                Section {
                    Button(action: {
                        
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Scan token with camera").foregroundColor(Color.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Select a picture to scan token").foregroundColor(Color.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        
                    }) {
                        HStack {
                            Image(systemName: "keyboard")
                            Text("Enter token manually").foregroundColor(Color.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                }
            }
            
            //Task {
            //    await eventAPI.redeemToken(token: token)
            //}
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
