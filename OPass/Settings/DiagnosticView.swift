//
//  DiagnosticView.swift
//  OPass
//
//  Created by Brian Chang on 2026/8/8.
//  2026 OPass.
//

import OneSignalFramework
import SwiftUI

struct DiagnosticView: View {
    var body: some View {
        Form {
            VStack(alignment: .leading) {
                Text("OneSignal ID")
                Text(OneSignal.User.onesignalId ?? "None")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
            .contextMenu {
                Button {
                    UIPasteboard.general.string = OneSignal.User.onesignalId ?? ""
                } label: {
                    Label("Copy ID", systemImage: "square.on.square")
                }
            }
        }
        .analyticsScreen(name: "DiagnosticView")
        .navigationTitle("Diagnostic")
    }
}

#Preview {
    NavigationView {
        DiagnosticView()
    }
}
