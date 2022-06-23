//
//  SafariView.swift
//  OPass
//
//  Created by secminhr on 2022/6/23.
//

import Foundation
import SwiftUI
import WebKit

struct WebviewWrapper: UIViewRepresentable {
    let url: URL?
    @Binding var outdated: Bool
    @Binding var progress: Double
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(outdated: _outdated, progress: _progress)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        
        context.coordinator.observer = view.observe(\.estimatedProgress, options: [.new]) { _, change in
            DispatchQueue.main.async {
                progress = change.newValue ?? 0.0
            }
        }
        view.navigationDelegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        //check context.coordinator.started to prevent unnecessary load,
        //the check is necessary since updateUIView will be called multiple times due to progress change
        if let url = url, !context.coordinator.started {
            DispatchQueue.main.async {
                outdated = false
            }
            uiView.load(URLRequest(url: url))
        }
        if outdated {
            DispatchQueue.main.async {
                outdated = false
            }
            uiView.reload()
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var outdated: Bool
        @Binding var progress: Double
        var observer: NSKeyValueObservation? = nil
        private(set) var started = false
        init(outdated: Binding<Bool>, progress: Binding<Double>) {
            _outdated = outdated
            _progress = progress
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            started = true
        }
        
        deinit {
            observer = nil
        }
    }
}
