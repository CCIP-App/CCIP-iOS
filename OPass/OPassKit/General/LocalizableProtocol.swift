//
//  LocalizableProtocol.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/29.
//  2023 OPass.
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
        if Bundle.main.preferredLocalizations[0] ==  "zh-Hant" { return self.zh }
        return self.en
    }
}
