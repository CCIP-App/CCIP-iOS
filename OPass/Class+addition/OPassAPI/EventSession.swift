//
//  EventSession.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/6/17.
//  2019 OPass.
//

import Foundation
import SwiftyJSON
import SwiftDate
import UICKeyChainStore

struct Programs: OPassData {
    var _data: JSON
    var Sessions: [ProgramSession]
    var Speakers: [ProgramSpeaker]
    var SessionTypes: [ProgramSessionType]
    var Rooms: [ProgramRoom]
    var Tags: [ProgramsTag]
    var _sessions = Dictionary<String, SessionInfo>()
    init(_ data: JSON) {
        self._data = data
        self.Sessions = self._data["sessions"].arrayValue.map { obj -> ProgramSession in
            return ProgramSession(obj)
        }
        self.Speakers = self._data["speakers"].arrayValue.map { obj -> ProgramSpeaker in
            return ProgramSpeaker(obj)
        }
        self.SessionTypes = self._data["session_types"].arrayValue.map { obj -> ProgramSessionType in
            return ProgramSessionType(obj)
        }
        self.Rooms = self._data["rooms"].arrayValue.map { obj -> ProgramRoom in
            return ProgramRoom(obj)
        }
        self.Tags = self._data["tags"].arrayValue.map { obj -> ProgramsTag in
            return ProgramsTag(obj)
        }
        self._regenSessions()
    }

    mutating func _regenSessions() {
        self._sessions.removeAll()
        self.Sessions.forEach { s in
            self._sessions[s.Id] = SessionInfo(s, self)
        }
    }

    func GetSession(_ sessionId: String) -> SessionInfo? {
        return self._sessions[sessionId]
    }

    func GetSessionIds(byDateString: String) -> Array<String> {
        return self.Sessions.filter { Constants.DateToDisplayDateString(Constants.DateFromString($0.Start)) == byDateString }.map { $0.Id }
    }
}

struct SessionInfo: OPassData {
    var _data: JSON
    var _sessionData: ProgramSession
    var Id: String
    var _types: [ProgramSessionType]
    var `Type`: String? {
        return self._types.filter { $0.Id == self._sessionData.Type }.first?.Name
    }
    var _rooms: [ProgramRoom]
    var Room: String? {
        let roomName = self._rooms.filter { $0.Id == self._sessionData.Room }.first?.Name ?? ""
        return roomName.count > 0 ? roomName : self._sessionData.Room
    }
    var Broadcast: String?
    var Start: String
    var End: String
    var Language: String
    var CoWrite: String?
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
    init(_ data: JSON) {
        // don't use
        self._data = data
        self._sessionData = ProgramSession(JSON(""))
        self.Id = self._sessionData.Id
        self._types = Programs(JSON("")).SessionTypes
        self.Broadcast = self._sessionData.Broadcast
        self.Start = self._sessionData.Start
        self.End = self._sessionData.End
        self.Language = self._sessionData.Language
        self.CoWrite = self._sessionData.CoWrite
        self.QA = self._sessionData.QA
        self.Slide = self._sessionData.Slide
        self.Live = self._sessionData.Live
        self.Record = self._sessionData.Record
        self._rooms = Programs(JSON("")).Rooms
        self._speakers = Programs(JSON("")).Speakers
        self._tags = Programs(JSON("")).Tags
    }
    init(_ data: ProgramSession, _ programs: Programs) {
        self._data = JSON("")
        self._sessionData = data
        self.Id = self._sessionData.Id
        self._types = programs.SessionTypes
        self.Broadcast = self._sessionData.Broadcast
        self.Start = self._sessionData.Start
        self.End = self._sessionData.End
        self.Language = self._sessionData.Language
        self.CoWrite = self._sessionData.CoWrite
        self.QA = self._sessionData.QA
        self.Slide = self._sessionData.Slide
        self.Live = self._sessionData.Live
        self.Record = self._sessionData.Record
        self._rooms = programs.Rooms
        self._speakers = programs.Speakers
        self._tags = programs.Tags
    }
    subscript(_ member: String) -> String {
        return self._sessionData[member]
    }
}

struct ProgramSession: OPassData {
    var _data: JSON
    var Id: String
    var `Type`: String?
    var Room: String?
    var Broadcast: String?
    var Start: String
    var End: String
    var Language: String
    var CoWrite: String?
    var QA: String?
    var Slide: String?
    var Live: String?
    var Record: String?
    var Rooms: [String?]
    var Speakers: [String?]
    var Tags: [String?]
    init(_ data: JSON) {
        self._data = data
        self.Id = self._data["id"].stringValue
        self.Type = self._data["type"].stringValue
        self.Room = self._data["room"].string
        self.Broadcast = self._data["broadcast"].string
        self.Start = self._data["start"].stringValue
        self.End = self._data["end"].stringValue
        self.Language = self._data["language"].stringValue
        self.CoWrite = self._data["co_write"].stringValue
        self.QA = self._data["qa"].string
        self.Slide = self._data["slide"].string
        self.Live = self._data["live"].string
        self.Record = self._data["record"].string
        self.Rooms = self._data["rooms"].arrayValue.map({ obj -> String? in
            return obj.string
        })
        self.Speakers = self._data["speakers"].arrayValue.map({ obj -> String? in
            return obj.string
        })
        self.Tags = self._data["tags"].arrayValue.map({ obj -> String? in
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
            return self._data[Constants.shortLangUI].dictionaryValue[name]?.stringValue ?? ""
        default:
            return ""
        }
    }
}

struct ProgramSpeaker: OPassData {
    var _data: JSON
    var Id: String
    var Avatar: URL?
    init(_ data: JSON) {
        self._data = data
        self.Id = self._data["id"].stringValue
        self.Avatar = self._data["avatar"].url
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
            return self._data[Constants.shortLangUI].dictionaryValue[name]?.stringValue ?? ""
        default:
            return ""
        }
    }
}

struct OPassTagData: OPassData {
    var _data: JSON
    var Id: String
    var Name: String {
        return self._data[Constants.shortLangUI].dictionaryValue["name"]?.stringValue ?? ""
    }
    init(_ data: JSON) {
        self._data = data
        self.Id = self._data["id"].stringValue
    }
}

typealias ProgramSessionType = OPassTagData
typealias ProgramRoom = OPassTagData
typealias ProgramsTag = OPassTagData

extension OPassAPI {
    static func GetSessionData(_ event: String, _ sessionKey: String, _ completion: OPassCompletionCallback) {
        if event.count > 0 {
            OPassAPI.InitializeRequest(Constants.URL_SESSION(sessionKey)) { _, _, error, _ in
                completion?(false, nil, error)
                }.then { (obj: Any?) -> Void in
                    if let o = obj {
                        if obj != nil {
                            let prog = Programs(JSON(o))
                            completion?(true, prog, OPassSuccessError)
                        } else {
                            completion?(false, RawOPassData(o), NSError(domain: "OPass Session can not get by return unexcepted response", code: 2, userInfo: nil))
                        }
                    }
            }
        } else {
            completion?(false, nil, NSError(domain: "OPass Session can not get, because event was not set", code: 1, userInfo: nil))
        }
    }

    private static func GetFavoritesStoreKey(_ event: String, _ token: String) -> String {
        return "\(event)|\(token)|favorites"
    }

    private static var favoritesLists: Dictionary<String, [String]> = [:]

    static func GetFavoritesList(_ event: String, _ token: String) -> [String] {
        let key = OPassAPI.GetFavoritesStoreKey(event, token)
        if let favoritesList = self.favoritesLists[key] {
            return favoritesList
        }
        if let favData = UICKeyChainStore.string(forKey: key) {
            if let favList = JSON(parseJSON: favData).object as? [String] {
                self.favoritesLists[key] = favList
                return favList
            }
        }
        self.favoritesLists[key] = []
        UICKeyChainStore.setString("[]", forKey: key)
        return []
    }

    static func PutFavoritesList(_ event: String, _ token: String, _ newList: [String]) {
        let key = OPassAPI.GetFavoritesStoreKey(event, token)
        UICKeyChainStore.setString(JSON(newList).rawString([.castNilToNSNull: true]), forKey: key)
        self.favoritesLists[key] = newList
    }

    static func CheckFavoriteState(_ event: String, _ token: String, _ session: String) -> Bool {
        return OPassAPI.GetFavoritesList(event, token).contains(session)
    }

    static func TriggerFavoriteSession(_ event: String, _ token: String, _ session: String, _ sessionData: SessionInfo) {
        let title = NSLocalizedString("SessionWillStartIn5Minutes", comment: "")
        let content = String.init(format: NSLocalizedString("SessionWillStartIn5MinutesContent", comment: ""), sessionData["Title"], sessionData.Room ?? "")
        guard let secs = sessionData.Start.toDate(style: .iso(.init())) else { return }
        let time = Date.init(seconds: secs.timeIntervalSince1970) - 5.minutes
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
        favList = favList.filter { $0.count > 0 }
        OPassAPI.PutFavoritesList(event, token, favList)
    }
}
