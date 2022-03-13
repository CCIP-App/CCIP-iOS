//
//  SettingsModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//

import Foundation
import SwiftDate

struct SettingsModel: Hashable, Decodable {
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

struct Start_EndModel: Hashable, Decodable {
    @TransformedFrom<String> var start = DateInRegion()
    @TransformedFrom<String> var end = DateInRegion()
}

struct FeatureModel: Hashable, Codable {
    let feature: FeatureType
    var icon: String? = nil
    var display_text = DisplayTextModel()
    var wifi: [WiFiModel]? = nil
    var url: String? = nil
}

enum FeatureType: String, Hashable, Codable {
    case nullFeature, fastpass, ticket, schedule, announcement, wifi, telegram, im, puzzle, venue, sponsors, staffs, webview
}


extension Optional where Wrapped == SettingsModel {
    func feature(ofType type: FeatureType) -> FeatureModel {
        switch self {
            case .none:
                return FeatureModel(feature: .nullFeature)
            case .some(let model):
                return model.features[ofType: type] ?? FeatureModel(feature: .nullFeature)
        }
    }
}

extension Array where Element == FeatureModel {
    fileprivate subscript(ofType type: FeatureType) -> Element? {
        return self.first { $0.feature == type }
    }
}
