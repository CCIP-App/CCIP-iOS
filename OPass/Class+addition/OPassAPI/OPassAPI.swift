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

class OPassAPI: NSObject {
    static var currentEvent: String = ""
    static var eventInfo: EventInfo? = nil

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
                    onceErrorCallback?(retryCount, maxRetry, error, response)
                    resolve(OPassNonSuccessDataResponse(response, data, JSON(data as Any)))
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        retryCount+=1
                        onceErrorCallback?(retryCount, maxRetry, error, response)
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
}
