//
//  JsonWrapper.swift
//  OPass
//
//  Created by secminhr on 2022/3/5.
//  2022 OPass.
//

import Foundation

//When decoding json, this wrapper will perform a transform, which is written by user, on the applied property/field.
//You may find the usage in EventSessionModel
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
//Recommand use TransformedFrom when the type implement TransformSelf and use TransformWith when the type implement TransformFunction
//This is however only a matter of name, you can replace these two with Transform if you want.
typealias TransformedFrom<Func: TransformSelf> = Transform<Func>
typealias TransformWith = Transform

protocol TransformSelf: TransformFunction {}
protocol TransformFunction {
    associatedtype FromType: Decodable
    associatedtype ToType: Codable, Hashable
    
    static func transform(_: FromType) -> ToType
}
