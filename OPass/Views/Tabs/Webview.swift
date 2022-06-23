//
//  Webview.swift
//  OPass
//
//  Created by secminhr on 2022/6/23.
//

import SwiftUI

struct Webview: View {
    let url: URL?
    let title: String?
    @State private var progress: Double = 0.0
    @State private var outdated: Bool = false
    
    var body: some View {
        WebviewWrapper(url: url, outdated: $outdated, progress: $progress)
            .navigationBarTitle(title ?? "")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    SFButton(systemName: "arrow.clockwise", action: {
                        outdated = true
                    })
                }
            }
            .safeAreaInset(edge: .top, spacing: CGFloat.zero) {
                if 1.0 - progress > 0.001 {
                    ProgressView(value: progress)
                }
            }
    }
}

struct Webview_Previews: PreviewProvider {
    static var previews: some View {
        Webview(url: URL(string: "google.com")!, title: "Title")
    }
}
