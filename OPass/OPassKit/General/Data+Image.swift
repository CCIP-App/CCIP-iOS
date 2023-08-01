//
//  Data+Image.swift
//  OPass
//
//  Created by Brian Chang on 2023/8/1.
//

import Foundation
import SwiftUI

extension Data {
    @inline(__always)
    func image() -> Image? {
        guard let uiImage = UIImage(data: self) else { return nil }
        return Image(uiImage: uiImage)
    }
}

