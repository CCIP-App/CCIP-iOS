//
//  Wifi.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/30.
//  2024 OPass.
//

import Foundation

struct Wifi: Hashable, Codable {
    var ssid: String
    var password: String

    private enum CodingKeys: String, CodingKey {
        case ssid = "SSID"
        case password
    }
}
