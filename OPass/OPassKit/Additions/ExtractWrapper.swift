//
//  ExtractWrapper.swift
//  OPass
//
//  Created by secminhr on 2022/3/13.
//  2023 OPass.
//

import Foundation

@propertyWrapper
struct Extract {
    let wrappedValue: Feature?
    init(_ type: FeatureType, in settings: EventConfig) {
        self.wrappedValue = settings.feature(type)
    }
    init(wrappedValue: Feature?, _ type: FeatureType) {
        self.wrappedValue = wrappedValue?.feature == type ? wrappedValue : nil
    }
}
