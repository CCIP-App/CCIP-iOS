//
//  NSObject+className.swift
//  OPass
//
//  Created by 腹黒い茶 on 2018/11/5.
//  2018 OPass.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }

    class var className: String {
        return String(describing: self)
    }
}
