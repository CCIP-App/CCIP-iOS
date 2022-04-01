//
//  TabButtonStyle.swift
//  OPass
//
//  Created by secminhr on 2022/3/27.
//

import Foundation
import SwiftUI

struct TabButtonStyleModifier: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fill)
            .padding()
            .tint(color)
            .background(color.opacity(0.1))
    }
}

extension NavigationLink {
    func tabButtonStyle(color: Color) -> some View {
        modifier(TabButtonStyleModifier(color: color))
    }
}

extension Button {
    func tabButtonStyle(color: Color) -> some View {
        modifier(TabButtonStyleModifier(color: color))
    }
}
