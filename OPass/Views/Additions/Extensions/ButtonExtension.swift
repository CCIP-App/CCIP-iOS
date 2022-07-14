//
//  ButtonExtension.swift
//  OPass
//
//  Created by secminhr on 2022/3/27.
//  2022 OPass.
//

import SwiftUI

extension Button {
    func tabButtonStyle(color: Color, width: CGFloat) -> some View {
        self
            .tint(color)
            .aspectRatio(contentMode: .fill)
            .padding(width * 0.2)
            .background(color.opacity(0.1))
    }
}
