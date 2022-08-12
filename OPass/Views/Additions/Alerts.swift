//
//  Alerts.swift
//  OPass
//
//  Created by 張智堯 on 2022/8/12.
//  2022 OPass.
//

import SwiftUI

extension View {
    @ViewBuilder
    func http403Alert(title: LocalizedStringKey? = nil, isPresented: Binding<Bool>, action: (() -> Void)? = nil) -> some View {
        self.alert(title ?? "ConnectToConferenceWiFi", isPresented: isPresented) {
            Button("OK", role: .cancel) {
                if let action = action { return action() }
            }
        } message: {
            title != nil ? Text("ConnectToConferenceWiFi") : nil
        }
    }
}
