//
//  WiFiView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/6.
//  2023 OPass.
//

import SwiftUI

struct WiFiView: View {
    
    let feature: Feature
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if let wifi = feature.wifi {
                    Form {
                        ForEach(wifi, id: \.self) { wifiDetail in
                            Button {
                                NEHotspot.ConnectWiFi(SSID: wifiDetail.ssid, withPass: wifiDetail.password)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(wifiDetail.ssid)
                                            .foregroundColor(.black)
                                        Text(wifiDetail.password)
                                            .foregroundColor(.gray)
                                            .font(.footnote)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(feature.title.localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("Close")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

//#if DEBUG
//struct WiFiView_Previews: PreviewProvider {
//    static var previews: some View {
//        WiFiView(EventStore: store.mock().eventList[5])
//    }
//}
//#endif
