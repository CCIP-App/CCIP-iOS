//
//  OPassAPI.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/3/7.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import then
import AFNetworking
import SwiftyJSON

internal typealias OPassErrorCallback = (
        (_ retryCount: UInt, _ retryMax: UInt, _ error: Error, _ responsed: URLResponse?) -> Void
    )?
internal typealias OPassCompletionCallback = (
        (_ success: Bool, _ data: Any?, _ error: Error) -> Void
    )

let OPassSuccessError = NSError(domain: "", code: 0, userInfo: nil)

@objc class OPassNonSuccessDataResponse: NSObject {
    @objc public var Response: HTTPURLResponse?
    @objc public var Data: Data?
    @objc public var Obj: NSObject
    public var Json: JSON?
    init(_ response: HTTPURLResponse?, _ data: Data?, _ json: JSON?) {
        self.Response = response
        self.Data = data
        self.Json = json
        self.Obj = json?.object as! NSObject
    }
}

@objc class OPassAPI: NSObject {
    static func InitializeRequest(_ url: String, maxRetry: UInt = 10, _ onceErrorCallback: OPassErrorCallback) -> Promise<Any?> {
        var retryCount: UInt = 0
        let e = Promise<Any?> { resolve, reject in
            let manager = AFHTTPSessionManager.init()
            manager.requestSerializer.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            manager.requestSerializer.timeoutInterval = 5
            manager.get(url, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
                NSLog("JSON: \(JSONSerialization.stringify(responseObject as Any)!)")
                if (responseObject != nil) {
                    resolve(responseObject)
                }
            }) { (operation: URLSessionDataTask?, error: Error) in
                NSLog("Error: \(error)")
                 let err = error as NSError
                // let systemMsg = err.userInfo["NSLocalizedDescription"] ?? ""
                let response = operation?.response as? HTTPURLResponse
                let data = err.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? Data
                if (response != nil) {
                    if onceErrorCallback != nil {
                        onceErrorCallback!(retryCount, maxRetry, error, response)
                    }
                    resolve(OPassNonSuccessDataResponse(response, data, JSON(data as Any)))
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        retryCount+=1
                        if onceErrorCallback != nil {
                            onceErrorCallback!(retryCount, maxRetry, error, response)
                        }
                        reject(error)
                    })
                }
            }
            }
        if maxRetry > 0 {
            return e.retry(maxRetry)
        } else {
            return e
        }
    }

    @objc static func RedeemCode(forEvent: String, withToken: String, completion: @escaping OPassCompletionCallback) {
        var event = forEvent
        if event == "" {
            event = Constants.currentEvent
        }
        let token = withToken.trim()
        let allowedCharacters = NSMutableCharacterSet.init(charactersIn: "-_")
        allowedCharacters.formUnion(with: NSCharacterSet.alphanumerics)
        let nonAllowedCharacters = allowedCharacters.inverted
        if (token.count != 0 && token.rangeOfCharacter(from: nonAllowedCharacters) == nil) {
            InitializeRequest(Constants.URL_LANDING(token: token)) { retryCount, retryMax, error, responsed in
                completion(false, nil, error)
            }.then { (obj: Any?) -> Void in
                if obj != nil {
                    switch (obj! as AnyObject).className {
                    case OPassNonSuccessDataResponse.className:
                        let sr = obj as! OPassNonSuccessDataResponse
                        let response = sr.Response!
                        switch response.statusCode {
                        case 400:
                            completion(false, sr, NSError(domain: "Opass Redeem Code Invalid", code: 4, userInfo: nil))
                            break
                        default:
                            completion(false, sr, NSError(domain: "Opass Redeem Code Invalid", code: 4, userInfo: nil))
                        }
                        break
                    default:
                        let json = JSON(obj!)
                        if json["nickname"].stringValue != "" {
                            AppDelegate.setLoginSession(true)
                            AppDelegate.setAccessToken(token)
                            AppDelegate.delegateInstance().checkinView.reloadCard()
                            completion(true, json, OPassSuccessError)
                        } else {
                            completion(false, json, NSError(domain: "Opass Redeem Code Invalid", code: 3, userInfo: nil))
                        }
                    }
                } else {
                    completion(false, obj, NSError(domain: "Opass Redeem Code Invalid", code: 2, userInfo: nil))
                }
            }
        } else {
            completion(false, nil, NSError(domain: "Opass Redeem Code Invalid", code: 1, userInfo: nil))
        }
    }

    @objc static func GetCurrentStatus(_ completion: @escaping OPassCompletionCallback) {
        let event = Constants.currentEvent
        let token = Constants.AccessToken
        if event.count > 0 && token.count > 0 {
            InitializeRequest(Constants.URL_STATUS(token: token)) { retryCount, retryMax, error, responsed in
                completion(false, nil, error)
            }.then { (obj: Any?) -> Void in
                completion(true, obj, OPassSuccessError)
            }
        } else {
            completion(false, nil, NSError(domain: "Opass Current Not in Event and No Valid Token", code: 1, userInfo: nil))
        }
    }
}
