//
//  InternalConfigView.swift
//  OPass
//
//  Created by 腹黒い茶 on 2020/8/25.
//  2020 OPass.
//

import Foundation
import SwiftUI

struct InternalConfigView: View {
    var buttons = ["Redeem", "Checkin", "Disabled", "Used", "Message"]
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ForEach(self.buttons, id: \.self) { button in
                    Button(action: {
                    }) {
                        Text("\(button)Button")
                            .foregroundColor(.white)
                            .frame(width: geometry.size.width * 0.8, height: 40)
                    }
                    .background(LinearGradient(gradient: Gradient(colors: [Color(Constants.appConfigColor[dynamicMember: "\(button)ButtonLeftColor"]), Color(Constants.appConfigColor[dynamicMember: "\(button)ButtonRightColor"])]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(.infinity)
                        .padding(5)
                }
                Text("Hello")
            }
        }
    }
}

struct InternalConfigView_Previews: PreviewProvider {
    static var previews: some View {
        InternalConfigView()
    }
}
