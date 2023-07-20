//
//  Data+CryptoKit.swift
//  OPass
//
//  Created by Brian Chang on 2023/7/20.
//

import Foundation
import CryptoKit

extension Data {
    func sha1() -> String {
        return Insecure.SHA1.hash(data: self)
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
