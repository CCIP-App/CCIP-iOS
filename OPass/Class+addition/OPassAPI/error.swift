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

@objc class OPassNonSuccessDataResponse: NSObject {
    @objc public var Response: HTTPURLResponse?
    public var Data: Data?
    @objc public var Obj: NSObject
    public var Json: JSON?
    init(_ response: HTTPURLResponse?, _ data: Data?, _ json: JSON?) {
        self.Response = response
        self.Data = data
        self.Json = json
        self.Obj = json?.object as! NSObject
    }
}
