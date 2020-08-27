//
//  MarkdownVIew.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/9/23.
//  2018 OPass.
//

import Foundation
import Then
import Down
import WebKit

public class MarkdownView: NSObject {
    public var markdownString: String
    public var downView: DownView?
    public var config: WKWebViewConfiguration

    public init(
        _ markdown: String,
        toView: UIView,
        config: WKWebViewConfiguration? = nil
    ) {
        self.config = WKWebViewConfiguration.init()
        self.markdownString = markdown
        if let _d = (try? await(Promise { resolve, _ in
            resolve(try? DownView(frame: CGRect.zero, markdownString: markdown, configuration: config, options: .smartUnsafe) {})
        })) {
            self.downView = _d
        }
        guard let downView = self.downView else { return }
        self.config = downView.configuration
        toView.addSubview(downView)

        self.downView?.translatesAutoresizingMaskIntoConstraints = false
        self.downView?.addLayoutGuide(UILayoutGuide())
        self.downView?.safeAreaLayoutGuide.topAnchor.constraint(equalTo: toView.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        self.downView?.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: toView.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        self.downView?.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: toView.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        self.downView?.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: toView.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    }

    public func append(_ markdown: String) {
        self.update(self.getMarkdown() + markdown)
    }

    public func update(_ markdown: String) {
        self.markdownString = markdown
        try? self.downView?.update(markdownString: self.getMarkdown())
    }

    public func getMarkdown() -> String {
        return self.markdownString
    }
}
