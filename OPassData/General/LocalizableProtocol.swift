//
//  LocalizableProtocol.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/29.
//  2025 OPass.
//

import Foundation

protocol Localizable {
    associatedtype T
    var zh: T { get }
    var en: T { get }
}

extension Localizable {
    @inline(__always)
    func localized() -> T {
        switch Bundle.main.preferredLocalizations[0] {
        case "nan", "zh-Hant":
            return self.zh
        default:
            return self.en
        }
    }
}
