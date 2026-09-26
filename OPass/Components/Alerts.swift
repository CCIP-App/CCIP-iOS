//
//  Alerts.swift
//  OPass
//
//  Created by 張智堯 on 2022/8/12.
//  2025 OPass.
//

import SwiftUI

extension View {
    @ViewBuilder
    func http403Alert(title: LocalizedStringKey? = nil, isPresented: Binding<Bool>, action: (() -> Void)? = nil) -> some View {
        self.alert(title ?? "Please connect to the Wi-Fi provided by event", isPresented: isPresented) {
            Button("OK", role: .cancel) {
                if let action = action { return action() }
            }
        } message: {
            title != nil ? Text("Please connect to the Wi-Fi provided by event") : nil
        }
    }
}
