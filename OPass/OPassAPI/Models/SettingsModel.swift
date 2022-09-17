//
//  SettingsModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//  2022 OPass.
//

import Foundation
import CryptoKit
import SwiftDate
import SwiftUI

struct SettingsModel: Hashable, Codable {
    var event_id: String = ""
    var display_name = DisplayTextModel()
    var logo_url: String = ""
    var event_date = Start_EndModel()
    var publish = Start_EndModel()
    var features: [FeatureModel] = []
}

struct WiFiModel: Hashable, Codable {
    var SSID: String = ""
    var password: String = ""
}

struct Start_EndModel: Hashable, Codable {
    @TransformWith<StringToDateTransform> var start = DateInRegion()
    @TransformWith<StringToDateTransform> var end = DateInRegion()
}

struct FeatureModel: Hashable, Codable {
    let feature: FeatureType
    var icon: String? = nil
    var iconData: Data? = nil
    var display_text = DisplayTextModel()
    var visible_roles: [String]? = nil
    var wifi: [WiFiModel]? = nil
    var url: String? = nil
    var color: Color { feature.color }
    var symbol: String { feature.symbol }
    var iconImage: Image? {
        guard let iconData = iconData else { return nil }
        guard let uiImage = UIImage(data: iconData) else { return nil }
        return Image(uiImage: uiImage)
    }
    
    func url(token: String?, role: String?) -> URL? {
        guard var url = url else { return nil }
        guard let paramsRegex = try? NSRegularExpression(pattern: "(\\{[^\\}]+\\})", options: .caseInsensitive) else { return nil }
        let matches = paramsRegex.matches(in: url, options: .reportProgress, range: NSRange(location: 0, length: url.count))
        for m in stride(from: matches.count, to: 0, by: -1) {
            let range = Range(matches[m - 1].range(at: 1), in: url)!
            let param = url[range]
            switch param {
            case "{token}":
                url = url.replacingOccurrences(of: param, with: token ?? "")
            case "{public_token}":
                url = url.replacingOccurrences(
                    of: param,
                    with: Insecure.SHA1.hash(data: Data((token ?? "").utf8))
                        .map { String(format: "%02X", $0) }
                        .joined()
                        .lowercased()
                )
            case "{role}":
                url = url.replacingOccurrences(of: param, with: role ?? "")
            default:
                url = url.replacingOccurrences(of: param, with: "")
            }
        }
        return URL(string: url)
    }
}

enum FeatureType: String, Hashable, Codable {
    case fastpass, ticket, schedule, announcement, wifi, telegram, im, puzzle, venue, sponsors, staffs, webview
}

extension SettingsModel {
    func feature(ofType type: FeatureType) -> FeatureModel? {
        return features.first { $0.feature == type }
    }
}

private extension FeatureType {
    var color: Color {
        let Color: [FeatureType : Color] = [
            .fastpass : .blue,
            .ticket : .purple,
            .schedule : .green,
            .announcement : .orange,
            .wifi : .brown,
            .telegram : .init(red: 89/255, green: 196/255, blue: 189/255),
            .im : .init(red: 86/255, green: 89/255, blue: 207/255),
            .puzzle : .blue,
            .venue : .init(red: 87/255, green: 172/255, blue: 225/255),
            .sponsors : .yellow,
            .staffs : .gray,
            .webview : .purple
        ]
        return Color[self] ?? .purple
    }
    var symbol: String {
        let SymbolName: [FeatureType : String] = [
            .fastpass : "wallet.pass",
            .ticket : "ticket",
            .schedule : "scroll",
            .announcement : "megaphone",
            .wifi : "wifi",
            .telegram : "paperplane",
            .im : "bubble.right",
            .puzzle : "puzzlepiece.extension",
            .venue : "map",
            .sponsors : "banknote",
            .staffs : "person.3"
        ]
        return SymbolName[self] ?? "shippingbox"
    }
}
