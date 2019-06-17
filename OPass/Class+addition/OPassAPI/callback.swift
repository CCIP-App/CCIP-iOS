//
//  callback.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation

internal typealias OPassErrorCallback = (
    (_ retryCount: UInt, _ retryMax: UInt, _ error: Error, _ responsed: URLResponse?) -> Void
    )?
internal typealias OPassCompletionCallback = (
    (_ success: Bool, _ data: Any?, _ error: Error) -> Void
    )?
