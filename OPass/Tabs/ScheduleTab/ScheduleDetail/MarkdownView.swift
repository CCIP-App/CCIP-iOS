//
//  ScheduleDetailContent.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/9/23.
//  Copyright © 2018 CPRTeam. All rights reserved.
//

import Foundation
import then
import Down

@objc public class MarkdownView : NSObject {
    public var markdownString: String
    public var downView: DownView
    
    @objc public init(
        _ frame: CGRect,
        withMarkdown: String,
        toView: UIView
        ) {
        self.downView = try! await(Promise { resolve, reject in
            resolve(try! DownView(frame: frame, markdownString: withMarkdown) {})
        })
        self.markdownString = withMarkdown
        toView .addSubview(self.downView)
    }
    
    @objc public func append(
        _ markdown: String
        ) {
        self .update(self.getMarkdown() + markdown)
    }
    
    @objc public func update(
        _ markdown: String
        ) {
        try? self.downView .update(markdownString: markdown)
        self.markdownString = markdown
    }
    
    @objc public func getMarkdown() -> String {
        return self.markdownString
    }
}
