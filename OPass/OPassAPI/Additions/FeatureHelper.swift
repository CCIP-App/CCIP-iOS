//
//  FeatureHelper.swift
//  OPass
//
//  Created by secminhr on 2022/3/13.
//  2022 OPass.
//

import Foundation

@propertyWrapper
struct Feature {
    let wrappedValue: FeatureModel?
    init(_ type: FeatureType, in settings: SettingsModel) {
        self.wrappedValue = settings.feature(ofType: type)
    }
    init(wrappedValue: FeatureModel?, _ type: FeatureType) {
        self.wrappedValue = wrappedValue?.feature == type ? wrappedValue : nil
    }
}
