//
//  TruncableText.swift
//  OPass
//
//  Created by 張智堯 on 2022/4/15.
//  2022 OPass.
//

import SwiftUI
import MarkdownUI

struct TruncableText: View {
    let text: Text
    let lineLimit: Int?
    @State private var intrinsicSize: CGSize = .zero
    @State private var truncatedSize: CGSize = .zero
    let isTruncatedUpdate: (_ isTruncated: Bool) -> Void
    
    var body: some View {
        text
            .lineLimit(lineLimit)
            .readSize { size in
                truncatedSize = size
                isTruncatedUpdate(truncatedSize != intrinsicSize)
            }
            .background(
                text
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .readSize { size in
                        intrinsicSize = size
                        isTruncatedUpdate(truncatedSize != intrinsicSize)
                    }
            )
    }
}

struct TruncableMarkdown: View {
    let text: String
    let font: MarkdownStyle.Font
    let lineLimit: Int?
    @State private var intrinsicSize: CGSize = .zero
    @State private var truncatedSize: CGSize = .zero
    let isTruncatedUpdate: (_ isTruncated: Bool) -> Void
    
    var body: some View {
        Markdown(text.tirm())
            .markdownStyle(
                MarkdownStyle(font: font)
            )
            .lineLimit(lineLimit)
            .readSize { size in
                truncatedSize = size
                isTruncatedUpdate(truncatedSize != intrinsicSize)
            }
            .background(
                Markdown(text.tirm())
                    .markdownStyle(
                        MarkdownStyle(font: font)
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .readSize { size in
                        intrinsicSize = size
                        isTruncatedUpdate(truncatedSize != intrinsicSize)
                    }
            )
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
