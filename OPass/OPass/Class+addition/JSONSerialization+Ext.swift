//
//  JSONSerialization+Ext.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/2/9.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation

@objc extension JSONSerialization {
    @objc static func parse(_ objString: String) -> Any? {
        let data = objString.data(using: .utf8)
        let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
        return json
    }
    @objc static func stringify(_ obj: Any) -> String? {
        let data = try! JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
        return String(data: data, encoding: .utf8)
    }
}
