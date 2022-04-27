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
    let wrappedValue: FeatureModel
    init(_ type: FeatureType, in settings: SettingsModel) {
        wrappedValue = settings.feature(ofType: type)
    }
    init(wrappedValue: FeatureModel, _ type: FeatureType) {
        //Only accept the target type or null feature
        //Other mismatched type must be an argument error, it's fatal and should be fixed during development.
        if wrappedValue.feature == type || wrappedValue.feature == .nullFeature {
            self.wrappedValue = wrappedValue
        } else {
            fatalError("incorrect feature type: require \(type) found \(wrappedValue.feature)")
        }
    }
}
