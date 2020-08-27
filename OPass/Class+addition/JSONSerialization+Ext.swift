//
//  JSONSerialization+Ext.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/2/9.
//  2019 OPass.
//

import Foundation

extension JSONSerialization {
    static func parse(_ objString: String) -> Any? {
        if let data = objString.data(using: .utf8) {
            let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            return json
        }
        return nil
    }
    static func stringify(_ obj: Any) -> String? {
        if let data = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
