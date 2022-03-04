//
//  EventSessionsModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/2.
//

import Foundation

struct EventSessionModel: Hashable {
    var sessions = [[SessionModel()]]
    var speakers = [SpeakerModel()]
    var session_types = [Id_Name_DescriptionModel()]
    var rooms = [Id_Name_DescriptionModel()]
    var tags = [Id_Name_DescriptionModel()]
}

extension EventSessionModel: Decodable {
    enum CodingKeys: CodingKey {
        case sessions, speakers, session_types, rooms, tags
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        speakers = try container.decode([SpeakerModel].self, forKey: .speakers)
        session_types = try container.decode([Id_Name_DescriptionModel].self, forKey: .session_types)
        rooms = try container.decode([Id_Name_DescriptionModel].self, forKey: .rooms)
        tags = try container.decode([Id_Name_DescriptionModel].self, forKey: .tags)
        
        let sessions = try container.decode([SessionModel].self, forKey: .sessions)
        //transform sessions from [SessionModel] to a structed [[SessionModel]]
        self.sessions = sessions
            .sorted { $0.start < $1.start || $0.end <= $1.end }
            .reduce(into: [], { (sessionsAcrossDays: inout [[SessionModel]], currentSession) in
                if !sessionsAcrossDays.isEmpty && sessionsAcrossDays.last![0].onSameDay(as: currentSession) {
                    sessionsAcrossDays[sessionsAcrossDays.count-1].append(currentSession)
                } else {
                    sessionsAcrossDays.append([currentSession])
                }
            })
    }
}

extension SessionModel {
    func onSameDay(as session: SessionModel) -> Bool {
        //Note: we only compare its start time
        return self.start.sameDay(as: session.start)
    }
}

extension Date {
    func sameDay(as date: Date) -> Bool {
        let components = self.dateComponents
        let otherComponents = date.dateComponents
        
        return components.year == otherComponents.year &&
                components.month == otherComponents.month &&
                components.day == otherComponents.day
    }
}

struct SessionModel: Hashable, Codable {
    var id: String = ""
    var type: String? = nil
    var room: String = ""
    var broadcast: [String]? = nil
    var start: Date = Date()
    var end: Date = Date()
    var qa: String? = nil
    var slide: String? = nil
    var live: String? = nil
    var record: String? = nil
    var pad: String? = nil
    var language: String? = nil
    var zh = Title_DescriptionModel()
    var en = Title_DescriptionModel()
    var speakers: [String] = [""]
    var tags: [String] = [""]
}

struct SpeakerModel: Hashable, Codable {
    var id: String = ""
    var avatar: String = ""
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

struct Name_BioModel: Hashable, Codable {
    var name: String = ""
    var bio: String = ""
}

struct Name_DescriptionModel: Hashable, Codable {
    var name: String = ""
    var description: String? = nil
}
