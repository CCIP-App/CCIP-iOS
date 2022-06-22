//
//  Markdown.swift
//  OPass
//
//  Created by 張智堯 on 2022/6/22.
//  2022 OPass.
//

import SwiftUI
import MarkdownKit
import AttributedText

struct Markdown: View {
    let markdown: String
    let font: UIFont.TextStyle
    
    init(_ markdown: String, font: UIFont.TextStyle) {
        self.markdown = markdown
        self.font = font
    }
    
    var body: some View {
        AttributedText {
            let markdownParser = MarkdownParser(font: .preferredFont(forTextStyle: font))
            markdownParser.enabledElements = .all
            markdownParser.header.fontIncrease = 0
            return markdownParser.parse(markdown.tirm())
        }
    }
}
