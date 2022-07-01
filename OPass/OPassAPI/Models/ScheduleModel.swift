//
//  ScheduleModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//  2022 OPass.
//

import Foundation
import SwiftDate

struct ScheduleModel: Hashable, Codable {
    @TransformWith<SessionModelsTransform> var sessions = []
    @TransformWith<SpeakerTransform> var speakers = SpeakersModel()
    @TransformWith<TagsTransform> var session_types = TagsModel()
    @TransformWith<TagsTransform> var rooms = TagsModel()
    @TransformWith<TagsTransform> var tags = TagsModel()
}

struct SessionModelsTransform: TransformFunction {
    static func transform(_ sessions: [SessionDataModel]) -> [SessionModel] {
        return sessions
            .grouped(by: { [$0.start.year, $0.start.month, $0.start.day] })
            .sorted(by: { entry1, entry2 in
                let day1 = entry1.key
                let day2 = entry2.key
                if day1[0] != day2[0] {
                    return day1[0] < day2[0]
                } else if day1[1] != day2[1] {
                    return day1[1] < day2[1]
                } else {
                    return day1[2] < day2[2]
                }
            })
            .map { (_, session) in session }
            .map { $0.grouped(by: \.start) }
            .map { sessionsDict in
                SessionModel(header: Array(sessionsDict.keys.sorted()), data: sessionsDict)
            }
    }
}

fileprivate extension Sequence {
    func grouped<K>(by keyPath: KeyPath<Element, K>) -> Dictionary<K, [Element]> {
        return grouped(by: { $0[keyPath: keyPath] })
    }
    func grouped<K>(by key: ((Element) -> K)) -> Dictionary<K, [Element]> {
        Dictionary(grouping: self, by: key)
    }
}

struct SessionModel: Hashable, Codable {
    var header: [DateInRegion] = []
    var data: [DateInRegion : [SessionDataModel]] = [:]
}

                                   
extension SessionModel {
    func filter(_ filter: (SessionDataModel) -> Bool) -> SessionModel {
        let filteredHeader = header.filter { header in
            switch data[header]?.filter(filter) {
                case .none: return false
                case .some(let filtered): return !filtered.isEmpty
            }
        }
        return SessionModel(
            header: filteredHeader,
            data: data.filter { (k, _) in filteredHeader.contains(k) }
                .mapValues { sessions in sessions.filter(filter) }
        )
    }

    var isEmpty: Bool { header.isEmpty }
}

struct SessionDataModel: Hashable, Codable {
    var id: String = ""
    var type: String? = nil
    var room: String = ""
    var broadcast: [String]? = nil
    @TransformWith<StringToDateTransform> var start = DateInRegion()
    @TransformWith<StringToDateTransform> var end = DateInRegion()
    var co_write: String? = nil
    var qa: String? = nil
    var slide: String? = nil
    var live: String? = nil
    var record: String? = nil
    var language: String? = nil
    var uri: String? = nil
    var zh = Title_DescriptionModel()
    var en = Title_DescriptionModel()
    var speakers: [String] = [""]
    var tags: [String] = [""]
}

struct TagsTransform: TransformFunction {
    static func transform(_ array: [Id_Name_DescriptionModel]) -> TagsModel {
        return TagsModel(
            id: array.map { $0.id },
            data: Dictionary(uniqueKeysWithValues: array.map { element in
                (element.id, Name_DescriptionPair(zh: element.zh, en: element.en))
            }))
    }
}

struct TagsModel: Hashable, Codable {
    var id: [String] = []
    var data: [String: Name_DescriptionPair] = [:]
}

struct StringToDateTransform: TransformFunction {
    static func transform(_ dateString: String) -> DateInRegion {
        return dateString.toISODate()!
    }
    
}

struct Id_SpeakerModel: Hashable, Codable {
    var id: String = ""
    var avatar: String = ""
    var zh = RawName_BioModel()
    var en = RawName_BioModel()
}

struct SpeakerTransform: TransformFunction {
    static func transform(_ speakers: [Id_SpeakerModel]) -> SpeakersModel {
        return SpeakersModel(
            id: speakers.map { $0.id },
            data: Dictionary(uniqueKeysWithValues: speakers.map { element in
                (element.id, SpeakerModel(avatar: element.avatar,
                                          zh: Name_BioModel(name: element.zh.name, bio: element.zh.bio),
                                          en: Name_BioModel(name: element.en.name, bio: element.en.bio)))
            })
        )
    }
}

struct SpeakersModel: Hashable, Codable {
    var id: [String] = []
    var data: [String : SpeakerModel] = [:]
}

struct SpeakerModel: Hashable, Codable {
    var avatar: String = ""
    var avatarData: Data?
    var zh = Name_BioModel()
    var en = Name_BioModel()
}

struct Id_Name_DescriptionModel: Hashable, Codable {
    var id: String = ""
    var zh = Name_DescriptionModel()
    var en = Name_DescriptionModel()
}

struct Title_DescriptionModel: Hashable, Codable {
    var title: String = ""
    var description: String = ""
}


struct RawName_BioModel: Hashable, Codable {
    var name: String = ""
    var bio: String = ""
}

struct Name_BioModel: Hashable, Codable {
    var name: String = ""
    var bio = ""
}

struct Name_DescriptionPair: Hashable, Codable {
    var zh: Name_DescriptionModel
    var en: Name_DescriptionModel
}

struct Name_DescriptionModel: Hashable, Codable {
    var name: String = ""
    var description: String? = nil
}
