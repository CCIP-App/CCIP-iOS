//
//  error.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import SwiftyJSON

let OPassSuccessError = NSError(domain: "", code: 0, userInfo: nil)

struct OPassNonSuccessDataResponse: OPassData {
    var _data: JSON
    var Response: HTTPURLResponse? {
        return (self._data.rawValue as! Dictionary<String, Any>)["response"] as? HTTPURLResponse
    }
    var Data: Data? {
        return (self._data.rawValue as! Dictionary<String, Any>)["data"] as? Data
    }
    var Obj: NSObject? {
        return self._data.object as? NSObject
    }
    var Json: JSON {
        return self._data
    }
    init(_ data: JSON) {
        self._data = data
    }
    init(_ response: HTTPURLResponse, _ data: Data, _ json: JSON?) {
        self._data = JSON(["response": response, "data": data, "json": json!])
    }
}

struct RawOPassData: OPassData {
    var _data: JSON
    init(_ data: JSON) {
        self._data = data
    }
    init(_ data: Any) {
        self._data = JSON(data)
    }
}
