//
//  EventScenario.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import SwiftyJSON

extension OPassAPI {
    @objc static func RedeemCode(forEvent: String, withToken: String, completion: OPassCompletionCallback) {
        var event = forEvent
        if event == "" {
            event = OPassAPI.currentEvent
        }
        let token = withToken.trim()
        let allowedCharacters = NSMutableCharacterSet.init(charactersIn: "-_")
        allowedCharacters.formUnion(with: NSCharacterSet.alphanumerics)
        let nonAllowedCharacters = allowedCharacters.inverted
        if (token.count != 0 && token.rangeOfCharacter(from: nonAllowedCharacters) == nil) {
            OPassAPI.InitializeRequest(Constants.URL_LANDING(token: token)) { retryCount, retryMax, error, responsed in
                completion?(false, nil, error)
                }.then { (obj: Any?) -> Void in
                    if obj != nil {
                        switch String(describing: type(of: obj!)) {
                        case OPassNonSuccessDataResponse.className:
                            let sr = obj as! OPassNonSuccessDataResponse
                            let response = sr.Response!
                            switch response.statusCode {
                            case 400:
                                completion?(false, sr, NSError(domain: "OPass Redeem Code Invalid", code: 4, userInfo: nil))
                                break
                            default:
                                completion?(false, sr, NSError(domain: "OPass Redeem Code Invalid", code: 4, userInfo: nil))
                            }
                            break
                        default:
                            let json = JSON(obj!)
                            if json["nickname"].stringValue != "" {
                                AppDelegate.setLoginSession(true)
                                AppDelegate.setAccessToken(token)
                                (AppDelegate.delegateInstance().checkinView as! CheckinViewController).reloadCard()
                                completion?(true, json.dictionaryObject, OPassSuccessError)
                            } else {
                                completion?(false, json.dictionaryObject, NSError(domain: "OPass Redeem Code Invalid", code: 3, userInfo: nil))
                            }
                        }
                    } else {
                        completion?(false, obj, NSError(domain: "OPass Redeem Code Invalid", code: 2, userInfo: nil))
                    }
            }
        } else {
            completion?(false, nil, NSError(domain: "OPass Redeem Code Invalid", code: 1, userInfo: nil))
        }
    }

    static func GetCurrentStatus(_ completion: OPassCompletionCallback) {
        let event = OPassAPI.currentEvent
        let token = Constants.AccessToken
        if event.count > 0 && token.count > 0 {
            OPassAPI.InitializeRequest(Constants.URL_STATUS(token: token)) { retryCount, retryMax, error, responsed in
                completion?(false, nil, error)
                }.then { (obj: Any?) -> Void in
                    if obj != nil {
                        switch String(describing: type(of: obj!)) {
                        case OPassNonSuccessDataResponse.className:
                            let sr = obj as! OPassNonSuccessDataResponse
                            completion?(false, sr, NSError(domain: "OPass Current Not in Event or Not a Valid Token", code: 4, userInfo: nil))
                        default:
                            let json = JSON(obj!)
                            if json["user_id"].stringValue != "" {
                                completion?(true, json.dictionaryObject, OPassSuccessError)
                            } else {
                                completion?(false, json.dictionaryObject, NSError(domain: "OPass Current Not in Event or Not a Valid Token", code: 3, userInfo: nil))
                            }
                        }
                    } else {
                        completion?(false, obj, NSError(domain: "OPass Current Not in Event or Not a Valid Token", code: 2, userInfo: nil))
                    }
            }
        } else {
            completion?(false, nil, NSError(domain: "OPass Current Not in Event or Not a Valid Token", code: 1, userInfo: nil))
        }
    }
    
    static func UseScenario(_ event: String, _ token: String, _ scenario: String, _ completion: OPassCompletionCallback) {
        if event.count > 0 {
            OPassAPI.InitializeRequest(Constants.URL_USE(token: token, scenario: scenario)) { retryCount, retryMax, error, responsed in
                completion?(false, nil, error)
                }.then { (obj: Any?) -> Void in
                    if obj != nil {
                        switch String(describing: type(of: obj!)) {
                        case OPassNonSuccessDataResponse.className:
                            let sr = obj as! OPassNonSuccessDataResponse
                            completion?(false, sr, NSError(domain: "OPass Scenario can not use because current is Not in Event or Not a Valid Token", code: 3, userInfo: nil))
                        default:
                            let used = JSON(obj!)
                            completion?(true, used, OPassSuccessError)
                        }
                    } else {
                        completion?(false, obj, NSError(domain: "OPass Scenario can not use by return unexcepted response", code: 2, userInfo: nil))
                    }
            }
        } else {
            completion?(false, nil, NSError(domain: "OPass Scenario can not use, because event was not set", code: 1, userInfo: nil))
        }
    }

}
