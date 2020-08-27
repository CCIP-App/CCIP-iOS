//
//  NEHotspot.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/3/2.
//  2019 OPass.
//

import Foundation
import NetworkExtension

class NEHotspot: NSObject {
    static func ConnectWiFi(SSID: String, withPass: String) {
        if #available(iOS 11.0, *) {
            #if TARGET_OS_SIMULATOR
            NSLog("In Simulator, NEHotspot not working")
            #else
            if SSID.count > 0 {
                NSLog("NEHotspot association with SSID `%@`.", SSID);
                let NEHConfig: NEHotspotConfiguration = (withPass.count > 0) ? NEHotspotConfiguration.init(ssid: SSID, passphrase: withPass, isWEP: false) : NEHotspotConfiguration.init(ssid: SSID);
                NEHConfig.joinOnce = false
                NEHConfig.lifeTimeInDays = 3
                let manager = NEHotspotConfigurationManager.shared
                manager.apply(NEHConfig, completionHandler: { (error: Error?) -> Void in
                    NSLog("Error: \(error as Any)")
                })
            } else {
                NSLog("No SSID was set, bypass for NEHotspot association.");
            }
            #endif
        }
    }
}
