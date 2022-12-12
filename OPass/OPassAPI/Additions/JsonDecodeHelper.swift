//
//  JsonWrapper.swift
//  OPass
//
//  Created by secminhr on 2022/3/5.
//  2022 OPass.
//

import Foundation

//When decoding json, this wrapper will perform a transform, which is written by user, on the applied property/field.
@propertyWrapper
struct Transform<Func: TransformFunction>: Codable, Hashable {
    var wrappedValue: Func.ToType
    
    init(wrappedValue: Func.ToType) {
        self.wrappedValue = wrappedValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if (decoder.userInfo[.needTransform] as? Bool) ?? false {
            let decoded = try container.decode(Func.FromType.self)
            self.wrappedValue = Func.transform(decoded)
        } else {
            self.wrappedValue = try container.decode(Func.ToType.self)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue)
    }
}
typealias TransformWith = Transform

protocol TransformFunction {
    associatedtype FromType: Decodable
    associatedtype ToType: Codable, Hashable
    
    static func transform(_: FromType) -> ToType
}

extension CodingUserInfoKey {
    static let needTransform = CodingUserInfoKey(rawValue: "needTransform")!
}
