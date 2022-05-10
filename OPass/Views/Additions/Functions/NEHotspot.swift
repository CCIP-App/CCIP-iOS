//
//  NEHotspot.swift
//  OPass
//
//  Created by 張智堯 on 2022/5/10.
//  2022 OPass.
//

import Foundation
import NetworkExtension
import OSLog

class NEHotspot {
    private static let logger = Logger(subsystem: "app.opass.ccip", category: "NEHotspot")
    static func ConnectWiFi(SSID: String, withPass: String) {
        #if targetEnvironment(simulator)
        logger.debug("In Simulator, NEHotspot not working")
        #else
        if SSID.count > 0 {
            logger.info("NEHotspot association with SSID: \(SSID).");
            let NEHConfig: NEHotspotConfiguration = (withPass.count > 0) ? NEHotspotConfiguration.init(ssid: SSID, passphrase: withPass, isWEP: false) : NEHotspotConfiguration.init(ssid: SSID);
            NEHConfig.joinOnce = false
            NEHConfig.lifeTimeInDays = 3
            let manager = NEHotspotConfigurationManager.shared
            manager.apply(NEHConfig, completionHandler: { (error: Error?) -> Void in
                if let theError = error {
                    logger.error("Error: \(theError as NSObject)")
                }
            })
        } else {
            logger.info("No SSID was set, bypass for NEHotspot association.");
        }
        #endif
    }
}
