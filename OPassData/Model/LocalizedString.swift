//
//  LocalizedString.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/30.
//  2026 OPass.
//

import Foundation

struct LocalizedString: Hashable, Codable, Localizable {
    var en: String
    var zh: String
    var hi: String?
    var ja: String?
    var ko: String?
    var nan: String?
    var nb: String?
    var ta: String?
}

struct LocalizedCodeString: Hashable, Codable, Localizable {
    var zh: String
    var en: String

    private enum CodingKeys: String, CodingKey {
        case zh = "zh-TW"
        case en = "en-US"
    }
}
