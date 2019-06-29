//
//  EventScenario.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ScenarioLanding: OPassData {
    var _data: JSON
    var Nickname: String
    init(_ data: JSON) {
        self._data = data
        self.Nickname = self._data["nickname"].stringValue
    }
}

struct ScenarioAttribute: OPassData {
    var _data: JSON
    init(_ data: JSON) {
        self._data = data
    }
    subscript(_ member: String) -> Any {
        return self._data[member].object
    }
}

struct Scenario: OPassData, Equatable {
    static func == (lhs: Scenario, rhs: Scenario) -> Bool {
        return lhs.Id == rhs.Id
    }
    var _data: JSON
    var Id: String
    var Used: Int?
    var Disabled: String?
    var Attributes: ScenarioAttribute
    var Countdown: Int?
    var ExpireTime: Int?
    var AvailableTime: Int?
    var DisplayText: String? {
        return self._data["display_text"][Constants.longLangUI!].string ?? ""
    }
    var Order: Int
    var Message: String?
    init(_ data: JSON) {
        self._data = data
        self.Id = self._data["id"].stringValue
        self.Used = self._data["used"].int
        self.Disabled = self._data["disabled"].string
        self.Attributes = ScenarioAttribute(self._data["attr"])
        self.Countdown = self._data["countdown"].int
        self.ExpireTime = self._data["expire_time"].int
        self.AvailableTime = self._data["available_time"].int
        self.Order = self._data["order"].intValue
        self.Message = self._data["message"].string
    }
}

struct ScenarioStatus: OPassData {
    var _data: JSON
    var _id: String {
        return self._data["_id"].dictionaryValue["$oid"]!.stringValue
    }
    var EventId: String
    var Token: String
    var UserId: String
    var Attributes: ScenarioAttribute
    var FirstUse: Int64
    var `Type`: String
    var Scenarios: [Scenario]
    init(_ data: JSON) {
        self._data = data
        self.EventId = self._data["event_id"].stringValue
        self.Token = self._data["token"].stringValue
        self.UserId = self._data["user_id"].stringValue
        self.Attributes = ScenarioAttribute(self._data["attr"])
        self.FirstUse = self._data["first_use"].int64Value
        self.Type = self._data["type"].stringValue
        self.Scenarios = self._data["scenarios"].arrayValue.map { obj -> Scenario in
            return Scenario(obj)
        }
    }
    subscript(_ member: String) -> String {
        return self._data[member].stringValue
    }
}

extension OPassAPI {
    static func RedeemCode(_ event: String, _ token: String, _ completion: OPassCompletionCallback) {
        var event = event
        if event == "" {
            event = OPassAPI.currentEvent
        }
        let token = token.trim()
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
                            let response = sr.Response
                            switch response!.statusCode {
                            case 400:
                                completion?(false, sr, NSError(domain: "OPass Redeem Code Invalid", code: 4, userInfo: nil))
                                break
                            default:
                                completion?(false, sr, NSError(domain: "OPass Redeem Code Invalid", code: 4, userInfo: nil))
                            }
                            break
                        default:
                            let landing = ScenarioLanding(JSON(obj!))
                            if landing.Nickname.count > 0 {
                                Constants.isLoginSession = true
                                Constants.accessToken = token
                                AppDelegate.delegateInstance.checkinView?.reloadCard()
                                completion?(true, landing, OPassSuccessError)
                            } else {
                                completion?(false, landing, NSError(domain: "OPass Redeem Code Invalid", code: 3, userInfo: nil))
                            }
                        }
                    } else {
                        completion?(false, RawOPassData(obj!), NSError(domain: "OPass Redeem Code Invalid", code: 2, userInfo: nil))
                    }
            }
        } else {
            completion?(false, nil, NSError(domain: "OPass Redeem Code Invalid", code: 1, userInfo: nil))
        }
    }

    static func GetCurrentStatus(_ completion: OPassCompletionCallback) {
        let event = OPassAPI.currentEvent
        guard let token = Constants.accessToken else {
            completion?(false, nil, NSError(domain: "Not a Valid Token", code: -1, userInfo: nil))
            return
        }
        if event.count > 0 && token.count > 0 {
            OPassAPI.InitializeRequest(Constants.URL_STATUS(token: token)) { retryCount, retryMax, error, responsed in
                completion?(false, nil, error)
                }.then { (obj: Any?) -> Void in
                    if obj != nil {
                        switch String(describing: type(of: obj!)) {
                        case OPassNonSuccessDataResponse.className:
                            let sr = obj as! OPassNonSuccessDataResponse
                            let response = sr.Response
                            switch response!.statusCode {
                            case 200:
                                completion?(false, sr, NSError(domain: "OPass Data not valid", code: 5, userInfo: nil))
                            default:
                                completion?(false, sr, NSError(domain: "OPass Current Not in Event or Not a Valid Token", code: 4, userInfo: nil))
                            }
                        default:
                            let status = ScenarioStatus(JSON(obj!))
                            if status.UserId.count > 0 {
                                completion?(true, status, OPassSuccessError)
                            } else {
                                completion?(false, status, NSError(domain: "OPass Current Not in Event or Not a Valid Token", code: 3, userInfo: nil))
                            }
                        }
                    } else {
                        completion?(false, RawOPassData(obj!), NSError(domain: "OPass Current Not in Event or Not a Valid Token", code: 2, userInfo: nil))
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
                            let used = Scenario(JSON(obj!))
                            completion?(true, used, OPassSuccessError)
                        }
                    } else {
                        completion?(false, RawOPassData(obj!), NSError(domain: "OPass Scenario can not use by return unexcepted response", code: 2, userInfo: nil))
                    }
            }
        } else {
            completion?(false, nil, NSError(domain: "OPass Scenario can not use, because event was not set", code: 1, userInfo: nil))
        }
    }

    static func ParseScenarioType(_ id: String) -> Dictionary<String, Any> {
        let id_pattern = "^(day(\\d+))?(\\w+)$"
        let id_regex = try? NSRegularExpression.init(pattern: id_pattern, options: .caseInsensitive)
        let id_matches = id_regex!.matches(in: id, options: .withTransparentBounds, range: NSRangeFromString(id))

        guard let did_range = id_matches.first?.range(at: 2) else {
            return [
                "scenarioType": id,
                "did": ""
            ]
        }
        let did = String(id[String.Index(utf16Offset: did_range.location, in: id)..<String.Index(utf16Offset: did_range.length, in: id)])
        guard let scenarioRange = id_matches.first?.range(at: 3) else {
            return [
                "scenarioType": id,
                "did": did
            ]
        }
        let scenarioType = String(id[String.Index(utf16Offset: scenarioRange.location, in: id)..<String.Index(utf16Offset: scenarioRange.length, in: id)])

        return [
            "scenarioType": scenarioType,
            "did": did
        ]
    }

    static func ParseScenarioRange(_ scenario: Scenario) -> Array<String> {
        let formatter = DateFormatter.init()
        formatter.dateFormat = Constants.appConfig("DisplayDateTimeFormat") as? String
        formatter.timeZone = NSTimeZone.default
        let availDate = Date.init(timeIntervalSince1970: TimeInterval(scenario.AvailableTime!))
        let expireDate = Date.init(timeIntervalSince1970: TimeInterval(scenario.ExpireTime!))
        let availString = formatter.string(from: availDate)
        let expireString = formatter.string(from: expireDate)
        return [ availString, expireString ]
    }
}
