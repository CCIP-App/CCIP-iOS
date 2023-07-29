//
//  Schedule.swift
//  OPass
//
//  Created by Brian Chang on 2022/3/2.
//  2023 OPass.
//

import SwiftDate
import OrderedCollections

struct Schedule: Hashable, Codable {
    @TransformWith<SessionModelsTransform> var sessions = []
    @Transform<Speaker> var speakers: OrderedDictionary<String, Speaker> = [:]
    @Transform<Tag> var types: OrderedDictionary<String, Tag> = [:]
    @Transform<Tag> var rooms: OrderedDictionary<String, Tag> = [:]
    @Transform<Tag> var tags: OrderedDictionary<String, Tag> = [:]
    
    enum CodingKeys: String, CodingKey {
        case sessions
        case speakers
        case types = "session_types"
        case rooms
        case tags
    }
}

struct SessionModelsTransform: TransformFunction {
    static func transform(_ sessions: [SessionDataModel]) -> [SessionModel] {
        return sessions
            .grouped(by: \.start.timeTruncated)
            .sorted { $0.key < $1.key }
            .map { (_, session) in session }
            .map { $0.grouped(by: \.start) }
            .map { sessionsDict in
                SessionModel(header: Array(sessionsDict.keys.sorted()), data: sessionsDict)
            }
    }
}

private extension DateInRegion {
    var timeTruncated: DateInRegion { self.dateTruncated(from: .hour)! }
}

private extension Sequence {
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
            case .some(let filtered): return filtered.isNotEmpty
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

struct SessionDataModel: Hashable, Codable, Localizable {
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

struct StringToDateTransform: TransformFunction {
    static func transform(_ dateString: String) -> DateInRegion {
        return dateString.toISODate()!
    }
    
}

struct Title_DescriptionModel: Hashable, Codable {
    var title: String = ""
    var description: String = ""
}
