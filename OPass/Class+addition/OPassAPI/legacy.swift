//
//  legacy.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  2019 OPass.
//

import Foundation
import SwiftyJSON

internal typealias OPassCompletionCallbackLegacy = ( (_ success: Bool, _ data: Any?, _ error: Error) -> Void )?

@objc class OPassNonSuccessDataResponseLegacy: NSObject {
    @objc public var Response: HTTPURLResponse?
    public var Data: Data?
    @objc public var Obj: NSObject
    public var Json: JSON?
    init(_ response: HTTPURLResponse?, _ data: Data?, _ json: JSON?) {
        self.Response = response
        self.Data = data
        self.Json = json
        self.Obj = NSObject.init()
        if let json = json {
            if let obj = json.object as? NSObject {
                self.Obj = obj
            }
        }
    }
}

extension OPassAPI {
    @objc static func DoLogin(byEventId eventId: String, withToken token: String, onCompletion completion: OPassCompletionCallbackLegacy) {
        self.DoLogin(eventId, token) { success, data, error in
            completion?(success, data as Any, error)
        }
    }

    @objc static func RedeemCode(forEvent: String, withToken: String, completion: OPassCompletionCallbackLegacy) {
        self.RedeemCode(forEvent, withToken) { success, data, error in
            completion?(success, data as Any, error)
        }
    }
}
