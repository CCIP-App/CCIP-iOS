//
//  Structs.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//  2022 OPass.
//

import Foundation

struct DisplayTextModel: Hashable, Codable {
    var en: String = ""
    var zh: String = ""
}

struct DisplayTextModel_CountryCode: Hashable, Codable {
    var en: String = ""
    var zh: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case en = "en-US"
        case zh = "zh-TW"
    }
}
