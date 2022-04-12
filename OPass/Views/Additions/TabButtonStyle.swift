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
    func body(content: Content) -> some View {
        content
            .tint(color)
            .aspectRatio(contentMode: .fill)
            .padding()
            .background(color.opacity(0.1))
    }
}

extension Button {
    func tabButtonStyle(color: Color) -> some View {
        modifier(TabButtonStyleModifier(color: color))
    }
}
