//
//  WiFiView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/6.
//  2022 OPass.
//

import SwiftUI

struct WiFiView: View {
    
    let feature: FeatureModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if let wifi = feature.wifi {
                    Form {
                        ForEach(wifi, id: \.self) { wifiDetail in
                            Button {
                                NEHotspot.ConnectWiFi(SSID: wifiDetail.SSID, withPass: wifiDetail.password)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(wifiDetail.SSID)
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
            .navigationTitle(feature.display_text.localized())
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
//        WiFiView(eventAPI: OPassAPIService.mock().eventList[5])
//    }
//}
//#endif
