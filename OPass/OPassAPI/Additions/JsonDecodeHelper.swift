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
struct Transform<Func: TransformFunction>: Decodable, Hashable {
    var wrappedValue: Func.ToType
    
    init(wrappedValue: Func.ToType) {
        self.wrappedValue = wrappedValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decoded = try container.decode(Func.FromType.self)
        self.wrappedValue = Func.transform(decoded)
    }
}
//Recommand use TransformedFrom when the type implement TransformSelf and use TransformWith when the type implement TransformFunction
//This is however only a matter of name, you can replace these two with Transform if you want.
typealias TransformedFrom<Func: TransformSelf> = Transform<Func>
typealias TransformWith = Transform

protocol TransformSelf: TransformFunction {}
protocol TransformFunction {
    associatedtype FromType: Decodable
    associatedtype ToType: Hashable
    
    static func transform(_: FromType) -> ToType
}
