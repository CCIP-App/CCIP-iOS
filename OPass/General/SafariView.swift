//
//  SafariView.swift
//  OPass
//
//  Created by Brian Chang on 2025/1/9.
//  2025 OPass.
//

import SafariServices
import SwiftUI

extension View {
    func safariViewSheet(url: Binding<URL?>, onDismiss: (() -> Void)? = nil) -> some View {
        self.sheet(item: url, onDismiss: onDismiss) { url in
            SFSafariViewWrapper(url: url)
                .analyticsScreen(name: "SFSafariView")
                .ignoresSafeArea()
        }
    }
}

private struct SFSafariViewWrapper: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariViewWrapper>) {
        return
    }
}

extension URL: @retroactive Identifiable {
    public var id: Int { self.absoluteString.hashValue }
}
