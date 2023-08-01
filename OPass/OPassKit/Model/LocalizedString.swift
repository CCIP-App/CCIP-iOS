//
//  LocalizedString.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/30.
//  2023 OPass.
//

import Foundation

struct LocalizedString: Hashable, Codable, Localizable {
    var zh: String
    var en: String
}

struct LocalizedCodeString: Hashable, Codable, Localizable {
    var zh: String
    var en: String

    private enum CodingKeys: String, CodingKey {
        case zh = "zh-TW"
        case en = "en-US"
    }
}
