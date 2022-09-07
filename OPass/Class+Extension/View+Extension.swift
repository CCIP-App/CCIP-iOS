//
//  View+Extension.swift
//  OPass
//
//  Created by 張智堯 on 2022/5/3.
//  2022 OPass.
//

import SwiftUI
import SafariServices

extension View {
    func LocalizeIn<T>(zh: T, en: T) -> T {
        if Bundle.main.preferredLocalizations[0] ==  "zh-Hant" { return zh }
        return en
    }
    
    @ViewBuilder //Use this at last resort. It's bad in SwiftUI.
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) }
        else { self }
    }
    @ViewBuilder
    func alert(_ titleKey: LocalizedStringKey, message: LocalizedStringKey? = nil, isPresented: Binding<Bool>) -> some View {
        if let message = message {
            self.alert(titleKey, isPresented: isPresented) {
                Button("OK", role: .cancel) {}
            } message: { Text(message) }

        } else {
            self.alert(titleKey, isPresented: isPresented) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}
