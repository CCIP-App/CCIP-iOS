//
//  EventSession.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftDate

struct Programs: Codable {
    var Sessions: [ProgramSession]
    var Speakers: [ProgramSpeaker]
    var SessionTypes: [ProgramSessionType]
    var Rooms: [ProgramRoom]
    var Tags: [ProgramsTag]
    init(_ data: JSON) {
        self.Sessions = data["sessions"].arrayValue.map { obj -> ProgramSession in
            return ProgramSession(obj)
        }
        self.Speakers = data["speakers"].arrayValue.map { obj -> ProgramSpeaker in
            return ProgramSpeaker(obj)
        }
        self.SessionTypes = data["session_types"].arrayValue.map { obj -> ProgramSessionType in
            return ProgramSessionType(obj)
        }
        self.Rooms = data["rooms"].arrayValue.map { obj -> ProgramRoom in
            return ProgramRoom(obj)
        }
        self.Tags = data["tags"].arrayValue.map { obj -> ProgramsTag in
            return ProgramsTag(obj)
        }
    }

    func GetSession(_ sessionId: String) -> SessionInfo? {
        guard let session = (self.Sessions.filter { $0.Id == sessionId }.first) else { return nil }
        return SessionInfo(session, self)
    }

    func GetSessionIds(byDateString: String) -> Array<String> {
        return self.Sessions.filter { Constants.DateToDisplayDateString(Constants.DateFromString($0.Start)) == byDateString }.map { $0.Id }
    }
}

struct SessionInfo: Codable {
    var _sessionData: ProgramSession
    var Id: String
    var _types: [ProgramSessionType]
    var `Type`: String? {
        return self._types.filter { $0.Id == self._sessionData.Type }.first?.Name
    }
    var Room: String?
    var Broadcast: String?
    var Start: String
    var End: String
    var QA: String?
    var Slide: String?
    var Live: String?
    var Record: String?
    var _speakers: [ProgramSpeaker]
    var Speakers: [ProgramSpeaker] {
        return self._speakers.filter { self._sessionData.Speakers.contains($0.Id) }
    }
    var _tags: [ProgramsTag]
    var Tags: [ProgramsTag] {
        return self._tags.filter { self._sessionData.Tags.contains($0.Id) }
    }
    init(_ data: ProgramSession, _ programs: Programs) {
        self._sessionData = data
        self.Id = self._sessionData.Id
        self._types = programs.SessionTypes
        self.Room = self._sessionData.Room
        self.Broadcast = self._sessionData.Broadcast
        self.Start = self._sessionData.Start
        self.End = self._sessionData.End
        self.QA = self._sessionData.QA
        self.Slide = self._sessionData.Slide
        self.Live = self._sessionData.Live
        self.Record = self._sessionData.Record
        self._speakers = programs.Speakers
        self._tags = programs.Tags
    }
    subscript(_ member: String) -> String {
        return self._sessionData[member]
    }
}

struct ProgramSession: Codable {
    var _sessionData: JSON
    var Id: String
    var `Type`: String?
    var Room: String?
    var Broadcast: String?
    var Start: String
    var End: String
    var QA: String?
    var Slide: String?
    var Live: String?
    var Record: String?
    var Speakers: [String?]
    var Tags: [String?]
    init(_ data: JSON) {
        self._sessionData = data
        self.Id = data["id"].stringValue
        self.Type = data["type"].stringValue
        self.Room = data["room"].string
        self.Broadcast = data["broadcast"].string
        self.Start = data["start"].stringValue
        self.End = data["end"].stringValue
        self.QA = data["qa"].string
        self.Slide = data["slide"].string
        self.Live = data["live"].string
        self.Record = data["record"].string
        self.Speakers = data["speakers"].arrayValue.map({ obj -> String? in
            return obj.string
        })
        self.Tags = data["tags"].arrayValue.map({ obj -> String? in
            return obj.string
        })
    }
    subscript(_ member: String) -> String {
        if member == "Id" {
            return Id
        }
        if member == "_sessionData" {
            return ""
        }
        let name = member.lowercased()
        switch name {
        case "title", "description":
            return _sessionData[AppDelegate.shortLangUI()].dictionaryValue[name]?.stringValue ?? ""
        default:
            return ""
        }
    }
}

struct ProgramSpeaker: Codable {
    var _speakerData: JSON
    var Id: String
    var Avatar: URL?
    init(_ data: JSON) {
        self._speakerData = data
        self.Id = data["id"].stringValue
        self.Avatar = data["avatar"].url
    }
    subscript(_ member: String) -> String {
        if member == "Id" {
            return Id
        }
        if member == "_speakerData" {
            return ""
        }
        let name = member.lowercased()
        switch name {
        case "name", "bio":
            return _speakerData[AppDelegate.shortLangUI()].dictionaryValue[name]?.stringValue ?? ""
        default:
            return ""
        }
    }
}

struct ProgramSessionType: Codable {
    var _sessionData: JSON
    var Id: String
    var Name: String {
        return _sessionData[AppDelegate.shortLangUI()].dictionaryValue["name"]?.stringValue ?? ""
    }
    init(_ data: JSON) {
        self._sessionData = data
        self.Id = data["id"].stringValue
    }
}

struct ProgramRoom: Codable {
    var _roomData: JSON
    var Id: String
    var Name: String {
        return _roomData[AppDelegate.shortLangUI()].dictionaryValue["name"]?.stringValue ?? ""
    }
    init(_ data: JSON) {
        self._roomData = data
        self.Id = data["id"].stringValue
    }
}

struct ProgramsTag: Codable {
    var _tagData: JSON
    var Id: String
    var Name: String {
        return _tagData[AppDelegate.shortLangUI()].dictionaryValue["name"]?.stringValue ?? ""
    }
    init(_ data: JSON) {
        self._tagData = data
        self.Id = data["id"].stringValue
    }
}

extension OPassAPI {
    static func GetSessionData(_ event: String, _ completion: OPassCompletionCallback) {
        if event.count > 0 {
            OPassAPI.InitializeRequest(Constants.URL_SESSION) { retryCount, retryMax, error, responsed in
                completion?(false, nil, error)
                }.then { (obj: Any?) -> Void in
                    if obj != nil {
                        let prog = Programs(JSON(obj!))
                        completion?(true, prog, OPassSuccessError)
                    } else {
                        completion?(false, obj, NSError(domain: "OPass Session can not get by return unexcepted response", code: 2, userInfo: nil))
                    }
            }
        } else {
            completion?(false, nil, NSError(domain: "OPass Session can not get, because event was not set", code: 1, userInfo: nil))
        }
    }

    private static func GetFavoritesStoreKey(_ event: String, _ token: String) -> String {
        return "\(event)|\(token)|favorites"
    }

    static func GetFavoritesList(_ event: String, _ token: String) -> [String] {
        let key = OPassAPI.GetFavoritesStoreKey(event, token)
        let ud = UserDefaults.standard
        ud.register(defaults: [key: Array<String>()])
        ud.synchronize()
        return ud.stringArray(forKey: key)!
    }

    static func PutFavoritesList(_ event: String, _ token: String, _ newList: [String]) {
        let key = OPassAPI.GetFavoritesStoreKey(event, token)
        let ud = UserDefaults.standard
        ud.set(newList, forKey: key)
        ud.synchronize()
    }

    static func CheckFavoriteState(_ event: String, _ token: String, _ session: String) -> Bool {
        return OPassAPI.GetFavoritesList(event, token).contains(session)
    }

    static func TriggerFavoriteSession(_ event: String, _ token: String, _ session: String) {
        let title = ""
        let content = ""
        let time = 10.seconds.fromNow
        var favList = OPassAPI.GetFavoritesList(event, token)
        let isDisable = favList.contains(session)
        OPassAPI.RegisteringNotification(
            id: "\(OPassAPI.GetFavoritesStoreKey(event, token))|\(session)",
            title: title,
            content: content,
            time: time,
            isDisable: isDisable
        )
        if !isDisable {
            favList += [ session ]
        } else {
            favList = favList.filter { $0 != session }
        }
        OPassAPI.PutFavoritesList(event, token, favList)
    }
}
