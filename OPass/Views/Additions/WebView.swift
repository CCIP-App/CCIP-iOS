//
//  WebView.swift
//  OPass
//
//  Created by secminhr on 2022/6/23.
//  2022 OPass.
//

import SwiftUI
import WebKit

struct WebView: View {
    let url: URL
    let title: String
    @State private var progress: Double = 0.0
    @State private var outdated: Bool = false
    @State private var error: Error? = nil
    @Environment(\.colorScheme) var colorScheme
    
    init(_ url: URL, title: String? = nil) {
        self.url = url
        self.title = title ?? ""
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            WebViewWrapper(url: url, outdated: $outdated, progress: $progress, error: $error)
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color("SectionBackgroundColor").edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(title)
        .refreshable { outdated = true }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                SFButton(systemName: progress != 1.0 ? "xmark" : "arrow.clockwise") {
                    outdated = progress == 1.0
                }
            }
        }
        .overlay {
            if progress != 1.0 {
                VStack {
                    ProgressView(value: progress)
                    Spacer()
                }.frame(width: UIScreen.main.bounds.width + 4)
            }
            if error != nil {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color("LogoColor"))
                        .frame(width: UIScreen.main.bounds.width * 0.25)
                        .padding(.bottom, 8)
                    
                    Text("\(error!.localizedDescription)")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        //.foregroundColor(colorScheme == .dark ? .white : .black)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
    }
}

struct WebViewWrapper: UIViewRepresentable {
    let url: URL?
    @Binding var outdated: Bool
    @Binding var progress: Double
    @Binding var error: Error?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(outdated: _outdated, progress: _progress, error: _error)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.isOpaque = false
        view.backgroundColor = .clear
        
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
            if error != nil {
                uiView.load(URLRequest(url: url!))
            } else {
                uiView.reload()
            }
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var outdated: Bool
        @Binding var progress: Double
        @Binding var error: Error?
        var observer: NSKeyValueObservation? = nil
        private(set) var started = false
        init(outdated: Binding<Bool>, progress: Binding<Double>, error: Binding<Error?>) {
            _outdated = outdated
            _progress = progress
            _error = error
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            started = true
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            error = nil
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            self.error = error
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            self.error = error
        }
        
        deinit {
            observer = nil
        }
    }
}
