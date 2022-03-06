//
//  JsonWrapper.swift
//  OPass
//
//  Created by secminhr on 2022/3/5.
//

import Foundation

//When decoding json, this wrapper will perform a transform, which is written by user, on the applied property.
//You may find the usage in EventSessionModel
@propertyWrapper
struct TransformedFrom<OriginalType: Transformation & Decodable>: Decodable, Hashable {
    var wrappedValue: OriginalType.ToType
    
    init(wrappedValue: OriginalType.ToType) {
        self.wrappedValue = wrappedValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decoded = try container.decode(OriginalType.self)
        self.wrappedValue = OriginalType.transform(decoded)
    }
}

protocol Transformation {
    associatedtype ToType: Hashable
    
    static func transform(_: Self) -> ToType
}
