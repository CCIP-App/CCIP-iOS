//
//  Wifi.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/30.
//  2023 OPass.
//

import Foundation

struct Wifi: Hashable, Codable {
    var ssid: String
    var password: String

    enum CodingKeys: String, CodingKey {
        case ssid = "SSID"
        case password
    }
}
