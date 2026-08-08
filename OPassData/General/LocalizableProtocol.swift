//
//  LocalizableProtocol.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/29.
//  2026 OPass.
//

import Foundation

protocol Localizable {
    associatedtype T
    var en: T { get }
    var zh: T { get }
    var hi: T? { get }
    var ja: T? { get }
    var ko: T? { get }
    var nan: T? { get }
    var nb: T? { get }
    var ta: T? { get }
}

extension Localizable {
    var hi: T? { nil }
    var ja: T? { nil }
    var ko: T? { nil }
    var nan: T? { nil }
    var nb: T? { nil }
    var ta: T? { nil }

    @inline(__always)
    func localized() -> T {
        switch Bundle.main.preferredLocalizations[0] {
        case "zh-Hant":
            return self.zh
        case "nan":
            return self.nan ?? self.zh
        case "ja":
            return self.ja ?? self.en
        case "ko":
            return self.ko ?? self.en
        case "nb":
            return self.nb ?? self.en
        case "ta":
            return self.ta ?? self.en
        case "hi":
            return self.hi ?? self.en
        default:
            return self.en
        }
    }
}
