//
//  Markdown.swift
//  OPass
//
//  Created by 張智堯 on 2022/6/22.
//  2024 OPass.
//

import SwiftUI
import MarkdownKit

struct Markdown: View {
    @Environment(\.colorScheme) var colorScheme
    private let markdown: String
    private let font: UIFont.TextStyle
    private let onOpenLink: ((URL) -> Void)?
    
    init(_ markdown: String, font: UIFont.TextStyle, onOpenLink: ((URL) -> Void)? = nil) {
        self.markdown = markdown
        self.font = font
        self.onOpenLink = onOpenLink
    }
    
    var body: some View {
        AttributedText(attributedText: {
            let markdownParser = MarkdownParser(font: .preferredFont(forTextStyle: font))
            markdownParser.enabledElements = [.all]
            markdownParser.header.fontIncrease = 0
            let result = NSMutableAttributedString(attributedString: markdownParser.parse(markdown.tirm()))
            result.addAttribute(
                .foregroundColor,
                value: colorScheme == .dark ? UIColor.white : UIColor.black,
                range: NSRange(0..<result.length)
            )
            return result
        }, onOpenLink: onOpenLink)
    }
}
