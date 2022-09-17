//
//  Array+Extension.swift
//  OPass
//
//  Created by secminhr on 2022/4/23.
//  2022 OPass.
//

import Foundation

extension Array: RawRepresentable where Element == String {
    public init?(rawValue: String) {
        guard let json = rawValue.data(using: .utf8),
              let dictionary = try? JSONDecoder().decode([String].self, from: json)  else {
            return nil
        }
        self = dictionary
    }
    
    public var rawValue: String {
        guard let json = try? JSONEncoder().encode(self),
              let jsonString = String(data: json, encoding: .utf8) else {
            return "[]"
        }
        return jsonString
    }
}
