//
//  error.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  2019 OPass.
//

import Foundation
import SwiftyJSON

let OPassSuccessError = NSError(domain: "", code: 0, userInfo: nil)

struct OPassNonSuccessDataResponse: OPassData {
    var _data: JSON
    var Response: HTTPURLResponse? {
        if let rawDict = self._data.rawValue as? Dictionary<String, Any> {
            if let resp = rawDict["response"] as? HTTPURLResponse {
                return resp
            }
        }
        return nil
    }
    var Data: Data? {
        if let rawDict = self._data.rawValue as? Dictionary<String, Any> {
            if let data = rawDict["data"] as? Data {
                return data
            }
        }
        return nil
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
        self._data = JSON(parseJSON: "{}")
        if let json = json {
            self._data = JSON(["response": response, "data": data, "json": json])
        }
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
