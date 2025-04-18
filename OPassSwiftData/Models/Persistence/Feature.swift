//
//  Feature.swift
//  OPass
//
//  Created by Brian Chang on 2025/4/17.
//  2025 OPass.
//

import Foundation
import SwiftData
import SwiftUI

enum FeatureType: String, Hashable, Codable {
    case fastpass,
         ticket,
         schedule,
         announcement,
         wifi,
         telegram,
         im,
         puzzle,
         venue,
         sponsors,
         staffs,
         webview
}

@Model
public final class Feature: Decodable {
    var feature: FeatureType
    var icon: String?
    var iconData: Data?
    var title: LocalizedString
    var visibleRoles: [String]?
    var url: String?
    
    @Relationship(deleteRule: .cascade) var wifi: [Wifi]? = []
    
    @Relationship(inverse: \Event.features) var event: Event?
    
    @Transient let webFeatures: [FeatureType] = [.im, .puzzle, .venue, .sponsors, .staffs, .webview]
    
    // MARK: - Decoding
    private enum CodingKeys: String, CodingKey {
        case feature
        case icon
        case title = "display_text"
        case visibleRoles = "visible_roles"
        case wifi
        case url
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.feature = try container.decode(FeatureType.self, forKey: .feature)
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon)
        self.title = try container.decode(LocalizedString.self, forKey: .title)
        self.visibleRoles = try container.decodeIfPresent([String].self, forKey: .visibleRoles)
        self.wifi = try container.decodeIfPresent([Wifi].self, forKey: .wifi)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
    }
}

extension Feature {
    var isWeb: Bool { return webFeatures.contains(feature) }
    
    var color: Color {
        switch self.feature {
        case .fastpass: return .blue
        case .ticket: return .purple
        case .schedule: return .green
        case .announcement: return .orange
        case .wifi: return .brown
        case .telegram: return .init(red: 89/255, green: 196/255, blue: 189/255)
        case .im: return .init(red: 86/255, green: 89/255, blue: 207/255)
        case .puzzle: return .blue
        case .venue: return .init(red: 87/255, green: 172/255, blue: 225/255)
        case .sponsors: return .yellow
        case .staffs: return .gray
        case .webview: return .purple
        }
    }
    
    var symbol: String {
        switch self.feature {
        case .fastpass: return "wallet.pass"
        case .ticket: return "ticket"
        case .schedule: return "scroll"
        case .announcement: return "megaphone"
        case .wifi: return "wifi"
        case .telegram: return "paperplane"
        case .im: return "bubble.right"
        case .puzzle: return "puzzlepiece.extension"
        case .venue: return "map"
        case .sponsors: return "banknote"
        case .staffs: return "person.2"
        case .webview: return "shippingbox"
        }
    }
    
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
                    with: token?.data(using: .utf8)?.sha1() ?? ""
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
