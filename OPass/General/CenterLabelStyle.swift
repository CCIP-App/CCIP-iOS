//
//  CenterLabelStyle.swift
//  OPass
//
//  Created by Brian Chang on 2024/8/22.
//  2025 OPass.
//

import SwiftUI

struct CenterLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            configuration.icon
                .frame(width: 23, height: 23)
                .padding(.leading, 2.666666)
                .padding(.trailing, 10.333333)
            configuration.title
        }
    }
}

