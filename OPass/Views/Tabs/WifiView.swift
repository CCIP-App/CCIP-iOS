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
        VStack {
            if let wifi = feature.wifi {
                Form {
                    ForEach(wifi, id: \.self) { wifiDetail in
                        Button(action: {
                            NEHotspot.ConnectWiFi(SSID: wifiDetail.SSID, withPass: wifiDetail.password)
                        }) {
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
        .navigationTitle(LocalizeIn(zh: feature.display_text.zh, en: feature.display_text.en))
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

//#if DEBUG
//struct WiFiView_Previews: PreviewProvider {
//    static var previews: some View {
//        WiFiView(eventAPI: OPassAPIViewModel.mock().eventList[5])
//    }
//}
//#endif
