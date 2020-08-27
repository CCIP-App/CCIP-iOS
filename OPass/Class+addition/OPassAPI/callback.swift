//
//  callback.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  2019 OPass.
//

import Foundation
import SwiftyJSON

protocol OPassData: Codable {
    var _data: JSON { get set }
    init(_ data: JSON)
}

extension OPassData {
    static var className: String {
        return String(describing: self)
    }
}

internal typealias OPassErrorCallback = (
    (_ retryCount: UInt, _ retryMax: UInt, _ error: Error, _ responsed: URLResponse?) -> Void
    )?
internal typealias OPassCompletionCallback = (
    (_ success: Bool, _ data: OPassData?, _ error: Error) -> Void
    )?
internal typealias OPassCompletionArrayCallback = (
    (_ success: Bool, _ data: [OPassData]?, _ error: Error) -> Void
    )?
