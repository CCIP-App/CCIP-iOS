//
//  String+Extension.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/31.
//

import Foundation

extension String {
    @inline(__always)
    func tirm() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    @inline(__always)
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    @inline(__always)
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
