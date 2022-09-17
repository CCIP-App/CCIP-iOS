//
//  Collection+Extension.swift
//  OPass
//
//  Created by 張智堯 on 2022/8/31.
//  2022 OPass.
//

import Foundation

extension Collection {
    /// A Boolean value indicating whether the collection is **not** empty.
    /// - Complexity: O(1)
    var isNotEmpty: Bool {
        !self.isEmpty
    }
}
