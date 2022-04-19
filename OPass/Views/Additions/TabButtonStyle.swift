//
//  TabButtonStyle.swift
//  OPass
//
//  Created by secminhr on 2022/3/27.
//  2022 OPass.
//

import Foundation
import SwiftUI

struct TabButtonStyleModifier: ViewModifier {
    let color: Color
    let width: CGFloat
    func body(content: Content) -> some View {
        content
            .tint(color)
            .aspectRatio(contentMode: .fill)
            .padding(width * 0.2)
            .background(color.opacity(0.1))
    }
}

extension Button {
    func tabButtonStyle(color: Color, width: CGFloat) -> some View {
        modifier(TabButtonStyleModifier(color: color, width: width))
    }
}
