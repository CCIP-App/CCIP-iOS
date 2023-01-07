//
//  ActivityIndicator.swift
//  OPass
//
//  Created by 張智堯 on 2022/4/12.
//  2023 OPass.
//

import SwiftUI

struct ActivityIndicatorMark_1: View {
    @State var animate = false
    let style = StrokeStyle(lineWidth: 6, lineCap: .round)
    let color1 = Color.gray, color2 = Color.gray.opacity(0.5)
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(gradient: .init(colors: [color1, color2]), center: .center),
                    style: style)
                .rotationEffect(Angle(degrees: animate ? 360 : 0))
                .animation(Animation.linear(duration: 0.7).repeatForever(autoreverses: false), value: animate)
        }.onAppear() {
            self.animate.toggle()
        }
    }
}
