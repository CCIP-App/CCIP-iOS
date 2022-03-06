//
//  WiFiView.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/6.
//

import SwiftUI
import NetworkExtension

struct WiFiView: View {
    
    @ObservedObject var eventAPI: EventAPIViewModel
    
    var body: some View {
        VStack {
            
        }
    }
    
    private func ConnectWiFi(SSID: String, withPass: String) {
        if #available(iOS 11.0, *) {
            #if TARGET_OS_SIMULATOR
            print("In Simulator, NEHotspot not working")
            #else
            if SSID.count > 0 {
                print("NEHotspot association with SSID `%@`.", SSID);
                let NEHConfig: NEHotspotConfiguration = (withPass.count > 0) ? NEHotspotConfiguration.init(ssid: SSID, passphrase: withPass, isWEP: false) : NEHotspotConfiguration.init(ssid: SSID);
                NEHConfig.joinOnce = false
                NEHConfig.lifeTimeInDays = 30
                let manager = NEHotspotConfigurationManager.shared
                manager.apply(NEHConfig, completionHandler: { (error: Error?) -> Void in
                    print("Error: \(error as Any)")
                })
            } else {
                print("No SSID was set, bypass for NEHotspot association.");
            }
            #endif
        }
    }
}

#if DEBUG
struct WiFiView_Previews: PreviewProvider {
    static var previews: some View {
        WiFiView(eventAPI: OPassAPIViewModel.mock().eventList[5])
    }
}
#endif
