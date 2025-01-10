//
//  Event.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/30.
//  2025 OPass.
//

import Foundation

struct Event: Hashable, Codable, Identifiable {
    var id: String
    var title: LocalizedString
    var logoUrl: String

    private enum CodingKeys: String, CodingKey {
        case id = "event_id"
        case title = "display_name"
        case logoUrl = "logo_url"
    }
}
