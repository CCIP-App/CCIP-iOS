//
//  Wifi.swift
//  OPass
//
//  Created by Brian Chang on 2025/4/17.
//  2025 OPass.
//

import Foundation
import SwiftData

@Model
final class Wifi: Decodable {
    var ssid: String
    var password: String
    
    @Relationship(inverse: \Feature.wifi) var feature: Feature?
    
    // MARK: - Decoding
    private enum CodingKeys: String, CodingKey {
        case ssid = "SSID"
        case password
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ssid = try container.decode(String.self, forKey: .ssid)
        self.password = try container.decode(String.self, forKey: .password)
    }
}
