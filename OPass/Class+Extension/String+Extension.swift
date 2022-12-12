//
//  String+Extension.swift
//  OPass
//
//  Created by 張智堯 on 2022/8/25.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func notContains<T>(_ other: T) -> Bool where T : StringProtocol {
        return !self.contains(other)
    }
}
